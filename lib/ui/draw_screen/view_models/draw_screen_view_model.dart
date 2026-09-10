import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:drawing_app/data/repositories/canvas_data_repository/canvas_data_repository.dart';
import 'package:drawing_app/data/repositories/layer_data_repository/layer_data_repository.dart';
import 'package:drawing_app/domain/models/canvas_camera.dart';
import 'package:drawing_app/domain/models/canvas_data/canvas_data.dart';
import 'package:drawing_app/ui/core/commands/add_layer_command.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/domain/models/layer_data/layer_data.dart';
import 'package:drawing_app/ui/core/commands/delete_layer_command.dart';
import 'package:drawing_app/ui/core/commands/reorder_layer_command.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tools_list.dart';
import 'package:drawing_app/ui/core/commands/erase_draw_command.dart';
import 'package:drawing_app/utils/command.dart';
import 'package:drawing_app/utils/image_conversion.dart';
import 'package:drawing_app/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

const Uuid uuid = Uuid();

class DrawScreenViewModel extends ChangeNotifier {
  DrawScreenViewModel({
    required LayerDataRepository layerDataRepository,
    required CanvasDataRepository canvasDataRepository,
  }) : _layerDataRepository = layerDataRepository,
       _canvasDataRepository = canvasDataRepository {

    deleteLayer = Command1(_deleteLayer);
    loadProject = Command1(_loadProject);
    initProject = Command0(_initializeNewProject);
    createLayer = Command0(_createAndAddLayer);
    saveDirtyProgress = Command0(_saveDirtyProgress);
  }

  static const canvasBackgroundColor = Colors.white;

  // Canvas Dimensions Fields
  double _canvasWidth = 2000.0;
  double _canvasHeight = 2000.0;

  // Canvas Dimensions Getters
  double get canvasWidth => _canvasWidth;
  double get canvasHeight => _canvasHeight;

  // Logger 
  Logger log = Logger();

  // Repository Fields 
  final LayerDataRepository _layerDataRepository;
  final CanvasDataRepository _canvasDataRepository;
  final CanvasToImageProcessor canvasToImageProcessor =
      CanvasToImageProcessor();

  // Async Commands
  late final Command1<void, String> loadProject;
  late final Command0 initProject;
  late final Command0 createLayer;
  late final Command0 saveDirtyProgress;
  late final Command1<void, String> deleteLayer;

  // Map of commands storing calls to get layersnapshots to allow them to execute async
  final Map<String, Command2<void, String, Map<Type,DrawTool>>> _layerSnapshotCommands = {};

  // Create new command to getsnapshot for layerId and add it to layersnapshots
 Command2<void, String, Map<Type, DrawTool>> getSnapshotCommandForLayer(String layerId, Map<Type,DrawTool> tools) {
    return _layerSnapshotCommands.putIfAbsent(layerId, () {
      return Command2<void, String, Map<Type,DrawTool>>(
        _getLayerSnapshot,
        allowConcurrent: true, // 🟢 Allows multiple layers to process at once!
      );
    });
  }

  bool isLayerMenuOpen = false;
  final List<String> _pendingLayerDeletionsLog = [];

  CanvasData? _currentCanvas;
  List<LayerData> _layers = [];

  CanvasData? get currentCanvas => _currentCanvas;
  List<LayerData> get layers => _layers;
  Map<String, Uint8List> get layerSnapshots => _layerSnapshots;
  List<DrawData> get drawHistory => _drawHistory;
  List<CanvasCommand> get redoHistory => _redoHistory;
  bool get canUndo => _undoHistory.isNotEmpty;
  bool get canRedo => _redoHistory.isNotEmpty;

  int _activeLayerIndex = 0;

  final List<DrawData> _drawHistory = [];
   final List<CanvasCommand>_undoHistory = [];
  final List<CanvasCommand> _redoHistory = [];
  final Map<String, Uint8List> _layerSnapshots = {};

  int _transformRevision = 0;
  int get transformRevision => _transformRevision;


  final Map<String, List<DrawData>> _cachedLayerHistories = {};

  final ToolMatrixPayload camera = ToolMatrixPayload();

  String get activeLayerId {
    if (_layers.isEmpty) return '';
    return _layers[_activeLayerIndex].id;
  }

  List<DrawData> getHistoryForLayer(String layerId) =>
      _cachedLayerHistories[layerId] ?? const [];

  // =========================================================================
  // --- THE CENTRAL TRANSACTIONAL COMMAND EXECUTION PIPELINE ---
  // =========================================================================

  /// Executes ANY structural change (Drawing vectors, Vector Erasures, 
  /// Adding sheets, or Reordering Z-Indices) down a clean, transactional pipeline.
  void executeCommand(CanvasCommand command) {
    // 1. Pack your active memory arrays into a clean state context wrapper.
    // This keeps the command completely agnostic of your view model's architecture.
    final context = CanvasStateContext(
      layerData: _layers, 
      globalDrawHistory: _drawHistory,
    );
    
    // 2. Mutate the raw collection arrays atomically via the pure domain blueprint
    command.execute(context);

    // 3. Log history timelines tracking loops
    _undoHistory.add(command);
    _redoHistory.clear(); // Pure linear timeline constraint: fresh edits discard forward redo chains

    // 4. Synchronization Subroutines
    // Instantly sync the O(1) rendering cache and flag modifications for the affected layer sheet
    _rebuildCacheForLayer(command.layerId);
    _markLayerAsDirtyById(command.layerId); 

    // =========================================================================
    // --- 🟢 PURE MVVM LIFE-CYCLE MONITORING ---
    // =========================================================================
    // The View Model acts as the supervisor of the state. 
    // If a DeleteLayerCommand just ran, the VM intercepts the event here 
    // and records the ID to the disk deletion log so the auto-save knows to purge it.
    if (command is DeleteLayerCommand) {
      _pendingLayerDeletionsLog.add(command.layerId);
    }

    // 5. Request an immediate UI framework layout repaint pass
    notifyListeners();

    // 6. Automatic Background Autosave Dispatch Broker.
    // Because this maps to a custom Command0 tracking object, if the file system 
    // engine is already mid-write, it safely shields the disk from collision conflicts.
    if (!saveDirtyProgress.running) {
      saveDirtyProgress.execute();
    }
  }

  void undo(){
    if(_undoHistory.isEmpty) return;

    final command = _undoHistory.last;

    final bool layerExists = _layers.any((layerId) => layerId.id == command.layerId);

    if(!layerExists && command is !DeleteLayerCommand){
      log.w('Cannot undo commands on deleted layer');
      return;
    }

    _undoHistory.removeLast();
    final context = CanvasStateContext(layerData: layers, globalDrawHistory: drawHistory);
    final String activeIdBeforeUndo = activeLayerId;

    command.undo(context);
    _redoHistory.add(command);

    // 🛡️ SYNC FIX: If we roll back a deletion, drop the ID from the purge log instantly
    if (command is DeleteLayerCommand) {
      _pendingLayerDeletionsLog.remove(command.layerId);
    }

    _rebuildCacheForLayer(command.layerId);
    _markLayerAsDirtyById(command.layerId);
    _recalibrateActiveIndex(activeIdBeforeUndo);
    notifyListeners();
  }

void _recalibrateActiveIndex([String? preferredLayerId]) {
    if (_layers.isEmpty) {
      _activeLayerIndex = 0;
      return;
    }
    if (preferredLayerId != null) {
      final int lookupIndex = _layers.indexWhere((l) => l.id == preferredLayerId);
      if (lookupIndex != -1) {
        _activeLayerIndex = lookupIndex;
        return;
      }
    }
    _activeLayerIndex = _activeLayerIndex.clamp(0, _layers.length - 1);
  }

   void redo() {
    if (_redoHistory.isEmpty) return;

    final command = _redoHistory.last;

    // 🛡️ RECOVERY FIX: Check layer lifecycle gates during forward playback
    final bool layerExists = _layers.any((layer) => layer.id == command.layerId);
    if (!layerExists && command is! DeleteLayerCommand) {
      log.w('Cannot redo stroke operations on a deleted layer. Step blocked.');
      return;
    }

    _redoHistory.removeLast();
    final context = CanvasStateContext(layerData: _layers, globalDrawHistory: _drawHistory);

    final String activeIdBeforeRedo = activeLayerId;
    
    command.execute(context);
    _undoHistory.add(command);
    if (command is DeleteLayerCommand) {
      _pendingLayerDeletionsLog.add(command.layerId);
    }

    _rebuildCacheForLayer(command.layerId);
    _markLayerAsDirtyById(command.layerId);
    _recalibrateActiveIndex(activeIdBeforeRedo);
    notifyListeners();
  }

  // --- DEFINITIVE DYNAMIC ARTBOARD RESIZER ---
  void resizeCanvas(double newWidth, double newHeight, Map<Type,DrawTool> tools) {
    // 1. Safety guard rails protect against zero or negative dimensions
    if (newWidth <= 0 || newHeight <= 0) return;

    // 2. Assign the fresh bounding dimensions cleanly to your internal states
    _canvasWidth = newWidth;
    _canvasHeight = newHeight;
    _transformRevision++;
    // 3. Increment the revision counter to force the RepaintBoundary to clear its texture cache
    notifyListeners();

    // 4. Force refresh layer snapshot previews to update background framing aspect ratios
    for (var layer in _layers) {
      getSnapshotCommandForLayer(layer.id, tools).execute(layer.id, tools);
    }
  }

  void forceCanvasRefresh(){
    _transformRevision++;
    notifyListeners();
  }

  void toggleLayerMenu() {
    isLayerMenuOpen = !isLayerMenuOpen;
    notifyListeners();
  }

// TODO
  void resetView(Size viewportSize) {
    // 1. Calculate the empty padding space remaining when scale is exactly 1.0
    final double extraWidth = viewportSize.width - _canvasWidth;
    final double extraHeight = viewportSize.height - _canvasHeight;

    // 2. Divide by 2 to find the exact midpoint coordinates
    final double centerX = extraWidth / 2.0;
    final double centerY = extraHeight / 2.0;

    // 3. Reset the master camera matrix back to default 100% scale and centered pan!
    // We instantiate a fresh Identity matrix, which naturally resets scale components to 1.0.
    camera.transform = Matrix4.identity();

    // Index 12 is translation X, and Index 13 is translation Y in column-major layout.
    camera.transform[12] = centerX;
    camera.transform[13] = centerY;
    _transformRevision++;

    notifyListeners();
  }

  void setActiveLayer(int index) {
    if (index >= 0 && index < _layers.length) {
      _activeLayerIndex = index;
      notifyListeners();
    }
  }

  Future<Result<void>> _loadProject(String canvasId) async {
    // 1. Fetch the primary canvas aggregate meta-data container file
    final loadedCanvasResult = await _canvasDataRepository.getCanvasData(
      canvasId,
    );

    switch (loadedCanvasResult) {
      case Ok():
        _currentCanvas = loadedCanvasResult.value;
      case Error():
        return Result.error(loadedCanvasResult.error);
    }

    // 2. Load all historical drawing sub-layers allocated to this canvas ID
    final loadedLayersResult = await _layerDataRepository.getAllCanvasLayers(
      canvasId,
    );

    switch (loadedLayersResult) {
      case Ok():
        final loadedLayers = loadedLayersResult.value;

        final Map<String, int> orderMap = {
          for (int i = 0; i < _currentCanvas!.layerIds.length; i++)
            _currentCanvas!.layerIds[i]: i,
        };

        loadedLayers.sort(
          (a, b) => (orderMap[a.id] ?? 0).compareTo(orderMap[b.id] ?? 0),
        );

        _layers = loadedLayers;


        // 3. Clean out temporary state memory tracks before reconstruction
        _cachedLayerHistories.clear();
        _drawHistory.clear();
        _undoHistory.clear();
        _redoHistory.clear();
        _layerSnapshots.clear();

        // 4. Reconstruct structural histories layer by layer
        for (var layer in _layers) {
          _cachedLayerHistories[layer.id] = List<DrawData>.from(
            layer.layerDrawHistory,
          );
          _drawHistory.addAll(layer.layerDrawHistory);
        }

        _activeLayerIndex = 0;

        // ... (steps 1 to 4 loading and sorting layer arrays in _loadProject)

        // 5. Commit structural data vectors to screen
        notifyListeners();

      case Error():
        return Result.error(loadedLayersResult.error);
    }
    return Result.ok(null);
  }

    void reorderLayers(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;

    // 1. Identify the moving layer ID
    final movingLayerId = _layers[oldIndex].id;

    // 2. Wrap the move operation inside a transactional command block
    final command = ReorderLayerCommand(
      layerId: movingLayerId,
      oldIndex: oldIndex,
      newIndex: newIndex,
    );

    // 3. Keep track of your currently selected active layer index anchor!
    // If the layer we are moving is the one currently active, track its new index.
    final LayerData activeLayerBeforeMove = _layers[_activeLayerIndex];

    // 4. Pass the command directly down the execution timeline loop
    executeCommand(command);

    // 5. Correct the active index pointer location so selection doesn't jump onto a different layer
    _activeLayerIndex = _layers.indexOf(activeLayerBeforeMove);
    notifyListeners();
  }
  
    // =========================================================================
  // --- AUTOMATIC BACKGROUND AUTOSAVE FILE SYSTEM BROKERS ---
  // =========================================================================

  /// Collects modified layer vector pools and removed document handles, 
  /// writing updates to the local database file storage in the background.
  Future<Result<void>> _saveDirtyProgress() async {
    // 1. Structural Guard: Cancel file writes if project files haven't mounted yet
    if (_currentCanvas == null) {
      return Result.error(
        Exception("Canvas must not be null before saving workspace records"),
      );
    }

    try {
      bool working = true;

      // Continuous Execution Loop: Keeps processing storage operations as long 
      // as rapid user interactions (e.g. fast drawing or deleting) occur.
      while (working) {
        
        // =====================================================================
        // TASK A: CLEAN UP RETIRED TRACKS FROM THE STORAGE STORAGE DRIVE
        // =====================================================================
        if (_pendingLayerDeletionsLog.isNotEmpty) {
          // Create a thread-safe snapshot copy of the log to prevent collection mutation errors
          final List<String> deletionsBatch = List<String>.from(_pendingLayerDeletionsLog);

          for (final String layerIdToDelete in deletionsBatch) {
            // Tell your repository layer to execute a clean file purge operation on disk
            final Result<void> deleteResult = await _layerDataRepository.deleteLayer(layerIdToDelete);
            
            if (deleteResult is Ok) {
              // Wipe from local memory tracking log upon successful disk removal
              _pendingLayerDeletionsLog.remove(layerIdToDelete);
            } else {
              log.w('Failed to purge disk record file for deleted layer $layerIdToDelete: ${(deleteResult as Error).error}');
            }
          }
        }

        // =====================================================================
        // TASK B: PACK MEMORY HISTORY MAPS INTO REPOSITORY LAYER MODELS
        // =====================================================================
        // By creating clean deep unmodifiable copies of the current vector arrays up front,
        // we isolate active drawing thread modifications from background thread file writes.
        final List<LayerData> packagedLayers = _layers.map((LayerData layer) {
          return layer.copyWith(
            layerDrawHistory: List<DrawData>.from(_cachedLayerHistories[layer.id] ?? const []),
          );
        }).toList();

        // Filter for active layers that actually need a file-write
        // We evaluate against the main '_layers' collection to check original dirty flag statuses.
        final List<LayerData> dirtyLayers = packagedLayers.where((LayerData currentPackedLayer) {
          final originalLayerRecord = _layers.firstWhere((orig) => orig.id == currentPackedLayer.id);
          return originalLayerRecord.isDirty;
        }).toList();

        // =====================================================================
        // LOOP EXIT GATEWAY
        // =====================================================================
        // If no new drawings were added and deletion logs are empty, exit the loop!
        if (dirtyLayers.isEmpty && _pendingLayerDeletionsLog.isEmpty) {
          working = false;
          break;
        }

        // =====================================================================
        // TASK C: COMMIT VECTOR PACKAGES TO THE REPOSITORY DISK
        // =====================================================================
        if (dirtyLayers.isNotEmpty) {
          final Result<void> saveResult = await _layerDataRepository.saveDirtyLayers(dirtyLayers);
          
          if (saveResult is Error) {
            return Result.error(saveResult.error);
          }

          // Reset dirty flag status markers on successfully synchronized collection maps
          _layers = packagedLayers
              .map((LayerData layer) => layer.copyWith(isDirty: false))
              .toList();
        }

        // =====================================================================
        // TASK D: UPDATE CANVAS LAYER ID INDEX SEQUENCE MANIFESTS
        // =====================================================================
        // Every pass guarantees your canvas ordering catalog always mirrors your active workspace layouts.
        await _synchronizeCanvasMetadata();
      }

      // Rebuild peripheral UI trackers or toolbar status banners
      notifyListeners();
      return Result.ok(null);

    } catch (e) {
      log.e('Critical breakdown encountered during automated workspace storage save task: $e');
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }



  Future<Result<void>> _deleteLayer(String layerId) async {
    if (_currentCanvas == null) {
      return Result.error(Exception("Canvas must not be null before deleting layers"));
    }
    if (_layers.length <= 1) return Result.ok(null); 

    final int targetIndex = _layers.indexWhere((l) => l.id == layerId);
    if (targetIndex == -1) {
      return Result.error(Exception("No layer found while attempting to delete layer with id of: $layerId"));
    }

    final deletedLayer = _layers[targetIndex];
    final String currentActiveLayerId = activeLayerId;

    // 🟢 FIXED: Match exact domain capsule parameters footprint
    final deleteCommand = DeleteLayerCommand(
      layerId: layerId, 
      index: targetIndex, 
      deletedLayer: deletedLayer,
    );

    // 🟢 FIXED: Fire purely down the memory pipeline loop to support clean reversible time travel
    executeCommand(deleteCommand);

    if (currentActiveLayerId == layerId) {
      _activeLayerIndex = targetIndex >= _layers.length ? _layers.length - 1 : targetIndex;
    } else {
      _activeLayerIndex = _layers.indexWhere((layer) => layer.id == currentActiveLayerId);
    }

    _cachedLayerHistories.remove(layerId);
    notifyListeners();
    return Result.ok(null);
  }

  // =========================================================================
  // --- STRUCTURAL LAYER MUTATION PIPELINES ---
  // =========================================================================

  /// Instantiates a pristine, empty drawing sheet directly above the current active 
  /// layer selection slot, dropping it down the central execution pipeline loop.
  Future<Result<void>> _createAndAddLayer() async {
    // 1. Context Validation Guard: Verify a project canvas is actively mounted
    if (_currentCanvas == null) {
      return Result.error(
        Exception("Canvas must not be null before creating layers"),
      );
    }

    final String newUniqueId = uuid.v4();
    
    // 2. Position calculation: We insert it exactly 1 visual layer depth slot 
    // above our current active focus layer row index
    final int targetedInsertionIndex = _activeLayerIndex + 1;
    final int nextDisplayNumber = _layers.length + 1;

    // 3. Construct your clean domain model record matching your terminologies
    final LayerData pristineLayer = LayerData(
      id: newUniqueId,
      index: targetedInsertionIndex,
      name: 'Layer $nextDisplayNumber',
      canvasId: _currentCanvas!.id,
      isDirty: true, // Flagged true so the auto-save registers its initial blueprint
      isVisible: true,
      layerDrawHistory: const [],
    );

    // 4. Instantiate the transaction command using your explicit parameter footprint
    final command = AddLayerCommand(
      layerId: newUniqueId,
      index: targetedInsertionIndex,
      layerData: pristineLayer,
    );

    // 5. Fire it down your centralized transactional pipeline loop.
    // This handles memory tracking updates, logs histories, clears cache maps,
    // and automatically schedules your background asynchronous autosave block daemon.
    executeCommand(command);

    // 6. Automatically shift the user's active focus selection onto their brand new drawing sheet
    _activeLayerIndex = targetedInsertionIndex;
    
    // 7. Request immediate UI panel redraw
    notifyListeners();

    return Result.ok(null);
  }

  Future<Result<void>> _initializeNewProject() async {
    // 1. Generate unique identity structural keys upfront 
    final String initialCanvasId = uuid.v4();
    final String initialLayerId = uuid.v4();

    // 2. Draft the blueprint for the primary metadata container manifest
    final templateCanvas = CanvasData(
      id: initialCanvasId, // Safe from database key overwriting deadlocks
      name: 'Untitled Drawing',
      layerIds: [initialLayerId], // Pre-populate the initial layout token mapping
    );

    // 3. Commit the aggregate blueprint down to the local file storage repository
    final result = await _canvasDataRepository.createCanvasData(templateCanvas);

    switch (result) {
      case Ok<CanvasData>():
        _currentCanvas = result.value;

        // 4. Construct the pristine baseline drawing layer model container
        final initialLayer = LayerData(
          id: initialLayerId,
          index: 0, // Hardcoded structural index 0 is safe from list range crashes
          name: 'Layer 1',
          canvasId: initialCanvasId,
          isDirty: true, // Flagged true so the file system writes its initialization parameters
          isVisible: true,
          layerDrawHistory: const [],
        );

        // 5. ATOMIC STATE RECONSTRUCTION
        // Directly overwrite the memory trackers, completely isolating this 
        // baseline setup step from polluting the user's Undo/Redo timelines!
        _layers = [initialLayer];
        
        _cachedLayerHistories.clear();
        _cachedLayerHistories[initialLayerId] = [];
        
        _drawHistory.clear();
        _undoHistory.clear(); // Flawless clean timeline history on startup
        _redoHistory.clear();
        _layerSnapshots.clear();
        
        _activeLayerIndex = 0;

        // 6. Request immediate UI layout view tree redraw
        notifyListeners();

        // 7. Schedule the automated background autosave macro daemon loop 
        // to immediately author the layer file records on disk
        if (!saveDirtyProgress.running) {
          saveDirtyProgress.execute();
        }

        return Result.ok(null);

      case Error():
        return Result.error(result.error);
    }
  }


  void _rebuildCacheForLayer(String layerId) {
    _cachedLayerHistories[layerId] = _drawHistory
        .where((cmd) => cmd.layerId == layerId)
        .toList();
  }

 void _markLayerAsDirtyById(String layerId) {
    final int index = _layers.indexWhere((layer) => layer.id == layerId);
    if (index == -1) return;

    // Mutate the unmodifiable Freezed record cleanly using a copyWith assignment
    _layers[index] = _layers[index].copyWith(isDirty: true);
  }

    // =========================================================================
  // --- METADATA SYNCHRONIZATION BROKERS ---
  // =========================================================================

  /// Keeps the master canvas metadata file updated with the exact current 
  /// layer order and saves it to the database repository.
  Future<void> _synchronizeCanvasMetadata() async {
    // 1. Safety Guard: Skip execution if the project hasn't initialized yet
    if (_currentCanvas == null) return;
    
    // 2. Map your active layers list down to an array of just their unique string IDs.
    // This perfectly captures the physical stacking order (z-index) of your layers.
    final List<String> updatedLayerIdsList = _layers.map((layer) => layer.id).toList();
    
    // 3. Create an immutable deep copy update of your canvas container model using Freezed copyWith
    final CanvasData updatedCanvasManifest = _currentCanvas!.copyWith(
      layerIds: updatedLayerIdsList,
    );
    
    // 4. Commit the fresh sorting manifest keys down to your canvas database repository disk files
    // Note: If your repository class uses the name 'modifyCanvasData' instead of 'updateCanvasData',
    // swap this call to match your specific repository signature!
    final canvasSaveResult = await _canvasDataRepository.modifyCanvasData(updatedCanvasManifest);
    
    switch (canvasSaveResult) {
      case Ok():
        // Securely update our live working reference model pointer upon disk success
        _currentCanvas = updatedCanvasManifest;
        log.d('Canvas ordering layout indexes mapping manifests synchronized successfully.');
      case Error():
        log.w('Failed to synchronize canvas layer index order manifest properties: ${canvasSaveResult.error}');
    }
  }


  Future<Result> _getLayerSnapshot(
    String layerId,
    Map<Type,DrawTool> tools) async {
    final List<DrawData> layerHistory =
        _cachedLayerHistories[layerId] ?? const [];
    if (layerHistory.isEmpty) {
      _layerSnapshots.remove(layerId);
      notifyListeners();
      return Result.ok(null);
    }
    try {
      final Uint8List? bytes = await canvasToImageProcessor
          .generateLayerSnapshotFromVectors(
            layerHistory: layerHistory,
            drawTools: tools,
          );
      if (bytes != null && bytes.isNotEmpty) {
        _layerSnapshots[layerId] = bytes;
        notifyListeners();
      }
      return Result.ok(null);
    } catch (e) {
      log.e('Failed to author vector-to-image snapshot: $e');
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }
}
