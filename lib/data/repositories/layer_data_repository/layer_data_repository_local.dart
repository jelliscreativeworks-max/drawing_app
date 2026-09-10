import 'package:drawing_app/data/repositories/layer_data_repository/layer_data_repository.dart';
import 'package:drawing_app/data/services/local_data_service.dart';
import 'package:drawing_app/domain/models/layer_data/layer_data.dart';
import 'package:drawing_app/utils/result.dart';
import 'package:logger/logger.dart';


class LayerDataRepositoryLocal implements LayerDataRepository {
  LayerDataRepositoryLocal({required LocalDataService localDataService}) 
      : _localDataService = localDataService;

  final LocalDataService _localDataService;


  // In-memory layer cache scoped to the currently active project
  final List<LayerData> _cachedLayers = List<LayerData>.empty(growable: true);

  final Logger log = Logger();
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
  Future<Result<List<LayerData>>> getAllCanvasLayers(String projectId) async {
    // If already cached for this exact project, return the cache instantly
    if (_cachedProjectId == projectId) {
      return Result.ok(List<LayerData>.from(_cachedLayers));
    }

    try {
      // Stream layers from the optimized multi-file loader inside local service
      final layers = await _localDataService.loadDrawLayers(projectId);
      
      _cachedLayers.clear();
      _cachedLayers.addAll(layers);
      _cachedProjectId = projectId;
      
      return Result.ok(List<LayerData>.from(_cachedLayers));
    } catch (e) {
      return Result.error(Exception('Failed to load layers for project $projectId: $e'));
    }
  }

  @override
  Future<Result<LayerData>> getLayer(String id) async {
    // Look up in the active memory cache for extreme UI rendering speed
    final cached = _cachedLayers.where((l) => l.id == id).firstOrNull;
    if (cached != null) return Result.ok(cached);

    return Result.error(Exception('Layer $id not found in active project cache. Ensure project is loaded first.'));
  }

  @override
  Future<Result<LayerData>> addLayer(LayerData newLayer) async {
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
  // @override
  // Future<Result<DrawLayer>> modifyLayer(DrawLayer modifiedLayer) async {
  //   final loadCheck = await _ensureLoaded(modifiedLayer.canvasId);
  //   if (loadCheck is Error) return Result.error((loadCheck).error);

  //   int index = _cachedLayers.indexWhere((l) => l.id == modifiedLayer.id);
  //   if (index == -1) return Result.error(Exception('Layer not found for modification'));

  //   // 1. Keep original cache entry in case disk operations fail (Rollback Strategy)
  //   final originalLayer = _cachedLayers[index];
    
  //   try {
  //     // 2. Optimistically update the memory cache for immediate UI snap
  //     _cachedLayers[index] = modifiedLayer;
      
  //     // 3. Attempt to write the modified layer onto its explicit isolated file slot
  //     await _localDataService.saveDrawLayers([modifiedLayer]);
  //     return Result.ok(modifiedLayer);
  //   } catch (e) {
  //     // 4. FIXED: Roll back memory cache state using our saved reference if the file system fails
  //     _cachedLayers[index] = originalLayer; 
  //     return Result.error(Exception('Failed to modify layer on disk: $e'));
  //   }
  // }


  @override
  Future<Result<void>> deleteLayer(String id) async {
    // 1. Attempt to look up the item in our temporary memory list cache
    final layerToDelete = _cachedLayers.where((l) => l.id == id).firstOrNull;

    try {
      if (layerToDelete != null) {
        // --- CASE A: Standard Cached Layer Deletion ---
        // The file was previously written to disk, so delete it normally
        await _localDataService.deleteDrawLayer(layerToDelete);
        
        // Evict it from the memory stack cache array loop
        _cachedLayers.removeWhere((l) => l.id == id);
      } else {
        // --- CASE B: 🟢 THE UNCACHED PATH SHIELD (FIXES UNDO ADD-LAYER) ---
        // If the layer is missing from the cache because it was pristine/blank,
        // we synthesize a lightweight token carrying your local project tracking string!
        // This gives your local data service a flawless path mapping to clear the directory.
        final mockLayerToken = LayerData(
          id: id,
          canvasId: _cachedProjectId ?? '', // 🟢 Bypasses the null cache block!
          index: 0,
          name: 'Temporary Cleanup Token',
          layerDrawHistory: const [],
        );

        log.i('Uncached deletion intercept running for layer $id inside project $_cachedProjectId.');
        
        // Command your local service to physically delete the file structure off the disk drive!
        await _localDataService.deleteDrawLayer(mockLayerToken);
      }
      
      return Result.ok(null);
    } catch (e) {
      log.e('Failed to execute hard disk file erasure for layer $id: $e');
      return Result.error(Exception('Failed to delete layer file $id: $e'));
    }
  }



  @override
  Future<Result<void>> saveDirtyLayers(List<LayerData> layers) async {
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
