
import 'package:drawing_app/data/repositories/layer_data_repository/layer_data_repository.dart';
import 'package:drawing_app/data/services/local_data_service.dart';
import 'package:drawing_app/domain/models/draw_layer/draw_layer.dart';
import 'package:drawing_app/utils/result.dart';

class LayerDataRepositoryLocal implements LayerDataRepository {
  LayerDataRepositoryLocal({required LocalDataService localDataService}) 
      : _localDataService = localDataService;

  final LocalDataService _localDataService;

  // In-memory layer cache scoped to the currently active project
  final List<DrawLayer> _cachedLayers = List<DrawLayer>.empty(growable: true);
  String? _cachedProjectId;

  /// Private helper to ensure the correct project's layers are loaded into memory cache
  Future<Result<void>> _ensureLoaded(String projectId) async {
    if (_cachedProjectId == projectId) return Result.ok(null);
    
    final loadResult = await getAllCanvasLayers(projectId);
    if (loadResult is Error) {
      return Result.error((loadResult as Error).error);
    }
    return Result.ok(null);
  }

  @override
  Future<Result<List<DrawLayer>>> getAllCanvasLayers(String projectId) async {
    // If already cached for this exact project, return the cache instantly
    if (_cachedProjectId == projectId) {
      return Result.ok(List<DrawLayer>.from(_cachedLayers));
    }

    try {
      // Stream layers from the optimized multi-file loader inside local service
      final layers = await _localDataService.loadDrawLayers(projectId);
      
      _cachedLayers.clear();
      _cachedLayers.addAll(layers);
      _cachedProjectId = projectId;
      
      return Result.ok(List<DrawLayer>.from(_cachedLayers));
    } catch (e) {
      return Result.error(Exception('Failed to load layers for project $projectId: $e'));
    }
  }

  @override
  Future<Result<DrawLayer>> getLayer(String id) async {
    // Look up in the active memory cache for extreme UI rendering speed
    final cached = _cachedLayers.where((l) => l.id == id).firstOrNull;
    if (cached != null) return Result.ok(cached);

    return Result.error(Exception('Layer $id not found in active project cache. Ensure project is loaded first.'));
  }

  @override
  Future<Result<DrawLayer>> addLayer(DrawLayer newLayer) async {
    final loadCheck = await _ensureLoaded(newLayer.canvasId);
    if (loadCheck is Error) return Result.error((loadCheck).error);

    try {
      // 1. Persist it onto disk immediately as its own file
      await _localDataService.saveDrawLayers([newLayer]);
      
      // 2. Add it to the local operational array cache if disk save completes
      _cachedLayers.add(newLayer);
      
      return Result.ok(newLayer);
    } catch (e) {
      return Result.error(Exception('Failed to write and add new layer to disk: $e'));
    }
  }
  @override
  Future<Result<DrawLayer>> modifyLayer(DrawLayer modifiedLayer) async {
    final loadCheck = await _ensureLoaded(modifiedLayer.canvasId);
    if (loadCheck is Error) return Result.error((loadCheck).error);

    int index = _cachedLayers.indexWhere((l) => l.id == modifiedLayer.id);
    if (index == -1) return Result.error(Exception('Layer not found for modification'));

    // 1. Keep original cache entry in case disk operations fail (Rollback Strategy)
    final originalLayer = _cachedLayers[index];
    
    try {
      // 2. Optimistically update the memory cache for immediate UI snap
      _cachedLayers[index] = modifiedLayer;
      
      // 3. Attempt to write the modified layer onto its explicit isolated file slot
      await _localDataService.saveDrawLayers([modifiedLayer]);
      return Result.ok(modifiedLayer);
    } catch (e) {
      // 4. FIXED: Roll back memory cache state using our saved reference if the file system fails
      _cachedLayers[index] = originalLayer; 
      return Result.error(Exception('Failed to modify layer on disk: $e'));
    }
  }


  @override
  Future<Result<void>> deleteLayer(String id) async {
    // Look up item in cache to access its embedded canvasId metadata
    final layerToDelete = _cachedLayers.where((l) => l.id == id).firstOrNull;
    if (layerToDelete == null) {
      return Result.error(Exception('Layer $id not found in cache. Cannot run deletion pipeline.'));
    }

    try {
      // 1. Delete physical JSON slot via your new service method
      await _localDataService.deleteDrawLayer(layerToDelete);
      
      // 2. Evict it from memory stack loop only after file is gone
      _cachedLayers.removeWhere((l) => l.id == id);
      
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to delete layer file $id: $e'));
    }
  }

  @override
  Future<Result<void>> saveDirtyLayers(List<DrawLayer> layers) async {
    // Short circuit if ViewModel evaluates that nothing was modified this stroke
    if (layers.isEmpty) return Result.ok(null);
    
    try {
      // Directly batch process file conversions via Future.wait inside your service
      await _localDataService.saveDrawLayers(layers);
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to batch save dirty layer segments: $e'));
    }
  }

  @override
  Future<Result<void>> deleteAllLayersInProject(String projectId) async {
    try {
      // Wipe the layer directory layout recursively
      await _localDataService.deleteAllLayersForProject(projectId);
      
      // Purge current operating cache if this was the open document session being wiped
      if (_cachedProjectId == projectId) {
        _cachedLayers.clear();
        _cachedProjectId = null;
      }
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to delete layers directory for project $projectId: $e'));
    }
  }
}
