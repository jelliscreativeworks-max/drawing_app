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
  void executeCommand(CanvasCommand command) {
    final context = CanvasStateContext(
      layerData: _layers, 
      globalDrawHistory: _drawHistory,
    );
    
    final String activeIdBeforeExecution = activeLayerId;

    // 1. Run the command mutation logic pass (e.g. AddLayerCommand.undo pulls the layer out)
    command.execute(context);

    _undoHistory.add(command);
    _redoHistory.clear(); 

    // Verify if the layer specified by the command still actually exists in our visual list
    final bool targetLayerStillExists = _layers.any((l) => l.id == command.layerId);

    if (targetLayerStillExists) {
      _rebuildCacheForLayer(command.layerId);
      _markLayerAsDirtyById(command.layerId);
    } else {
      // =========================================================================
      // 🟢 FIX: LOG THE DELETION TO PURGE THE PHYSICAL FILE SYSTEM
      // =========================================================================
      // If the layer was removed from memory (like undoing an AddLayerCommand),
      // log its ID straight into your pending deletions queue tracker!
      // This tells your background daemon to completely delete the file from the disk.
      _pendingLayerDeletionsLog.add(command.layerId);
      
      // Clean up internal runtime caching lookups instantly
      _cachedLayerHistories.remove(command.layerId);
      layerSnapshots.remove(command.layerId);
    }

    // Capture explicit forward DeleteLayerCommand signals uniformly
    if (command is DeleteLayerCommand) {
      _pendingLayerDeletionsLog.add(command.layerId);
    }

    // 2. Heal your index pointer channels safely inside the reduced boundaries
    final int verifiedIndex = _layers.indexWhere((l) => l.id == activeIdBeforeExecution);
    if (verifiedIndex != -1) {
      _activeLayerIndex = verifiedIndex;
    } else {
      _activeLayerIndex = _activeLayerIndex.clamp(0, _layers.length - 1);
    }

    notifyListeners();

    // 3. Wake up the background auto-save loop to process the file deletions!
    if (!saveDirtyProgress.running) {
      saveDirtyProgress.execute();
    }
  }


  // =========================================================================
  // --- GLOBAL HISTORICAL TIME TRAVEL ACTIONS (STATE-HEALED) ---
  // =========================================================================

  void undo() {
    if (_undoHistory.isEmpty) return;

    final command = _undoHistory.last;
    final bool layerExistsBeforeUndo = _layers.any((l) => l.id == command.layerId);

    if (!layerExistsBeforeUndo && command is! DeleteLayerCommand && command is! AddLayerCommand) {
      log.w('Cannot undo commands on an untracked layer.');
      return;
    }

    _undoHistory.removeLast();
    final context = CanvasStateContext(layerData: _layers, globalDrawHistory: _drawHistory);
    final String activeIdBeforeUndo = activeLayerId;

    // 1. Execute the rollback mutation
    command.undo(context);
    _redoHistory.add(command);

    // =========================================================================
    // 🟢 THE STRUCTURAL SNAPSHOT SHIELD (FIXES UNDO LEAKING FILES)
    // =========================================================================
    // Verify if the layer specified by the command still exists AFTER the undo pass.
    // If we just undid an AddLayerCommand, this evaluates to false!
    final bool targetLayerStillExists = _layers.any((l) => l.id == command.layerId);

    if (targetLayerStillExists) {
      _rebuildCacheForLayer(command.layerId);
      _markLayerAsDirtyById(command.layerId);
    } else {
      // 🟢 THE FIX: If the layer was removed by the undo action, 
      // queue its ID straight into your pending file system deletions log!
      _pendingLayerDeletionsLog.add(command.layerId);
      
      // Clear out internal runtime tracking lookups instantly
      _cachedLayerHistories.remove(command.layerId);
      layerSnapshots.remove(command.layerId);
    }

    if (command is DeleteLayerCommand) {
      _pendingLayerDeletionsLog.remove(command.layerId);
    }

    // =========================================================================
    // 2. THE IDENTITY INDEX POINTER HEALER
    // =========================================================================
    final int verifiedIndex = _layers.indexWhere((l) => l.id == activeIdBeforeUndo);
    if (verifiedIndex != -1) {
      _activeLayerIndex = verifiedIndex;
    } else {
      _activeLayerIndex = _activeLayerIndex.clamp(0, _layers.length - 1);
    }

    notifyListeners();

    // Wake up the background auto-save loop to purge the file off your hard drive!
    if (!saveDirtyProgress.running) {
      saveDirtyProgress.execute();
    }
  }

  void redo() {
    if (_redoHistory.isEmpty) return;

    final command = _redoHistory.last;
    final bool layerExistsBeforeRedo = _layers.any((l) => l.id == command.layerId);
    
    if (!layerExistsBeforeRedo && command is! DeleteLayerCommand && command is! AddLayerCommand) {
      log.w('Cannot redo operations on an untracked layer.');
      return;
    }

    _redoHistory.removeLast();
    final context = CanvasStateContext(layerData: _layers, globalDrawHistory: _drawHistory);
    final String activeIdBeforeRedo = activeLayerId;
    
    // 3. Execute the forward recreation step
    command.execute(context);
    _undoHistory.add(command);

    if (command is DeleteLayerCommand) {
      _pendingLayerDeletionsLog.add(command.layerId);
    }

    // =========================================================================
    // 🟢 THE REDO RE-SYNC SHIELD (FIXES RE-INSERTION COLD STANDSTILL)
    // =========================================================================
    final bool targetLayerStillExists = _layers.any((l) => l.id == command.layerId);

    if (targetLayerStillExists) {
      _rebuildCacheForLayer(command.layerId);
      _markLayerAsDirtyById(command.layerId);
    }

    // Recalculate index focus pointers to latch focus securely by identity
    final int verifiedIndex = _layers.indexWhere((l) => l.id == activeIdBeforeRedo);
    if (verifiedIndex != -1) {
      _activeLayerIndex = verifiedIndex;
    } else {
      _activeLayerIndex = _activeLayerIndex.clamp(0, _layers.length - 1);
    }

    // 🟢 THE RE-INSTANTIATION CLONE REFOCUS:
    // Force a fresh collection update layout reference to trick Flutter's 
    // change detection system into seeing the newly re-inserted redo row!
    _layers = List<LayerData>.from(_layers);

    notifyListeners();

    if (!saveDirtyProgress.running) {
      saveDirtyProgress.execute();
    }
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
    if (oldIndex < 0 || oldIndex >= _layers.length) return;
    if (newIndex < 0 || newIndex > _layers.length) return;

    // 1. Package the move operation cleanly into your command architecture
    final reorderCommand = ReorderLayerCommand(
      layerId: _layers[oldIndex].id,
      oldIndex: oldIndex,
      newIndex: newIndex,
      currentHistoryLength: _drawHistory.length, // 🟢 Binds chronologically to the top of the timeline
    );

    // 2. Dispatch straight down your unified execution command engine pipeline pass!
    // This handles moving the item, flushing layer caches, marking files dirty, 
    // and waking up your automated disk-write autosave loops automatically!
    executeCommand(reorderCommand);
  }
   Future<Result<void>> _saveDirtyProgress() async {
    if (_currentCanvas == null) {
      return Result.error(
        Exception("Canvas must not be null before saving workspace records"),
      );
    }

    try {
      bool working = true;
      
      // Local transaction tracking array to hold onto target keys during this pass
      final List<String> layersToPurgeThisPass = [];

      while (working) {
        // =====================================================================
        // TASK A: RE-ROUTE DELETIONS QUEUE
        // =====================================================================
        if (_pendingLayerDeletionsLog.isNotEmpty) {
          // Move the IDs into our deferred tracking loop block, but wait to clear 
          // files until after the structural canvas metadata flushes safely.
          layersToPurgeThisPass.addAll(_pendingLayerDeletionsLog);
          _pendingLayerDeletionsLog.clear(); 
        }

        // =====================================================================
        // TASK B: PACK MEMORY HISTORY MAPS INTO REPOSITORY LAYER MODELS
        // =====================================================================
        final List<LayerData> packagedLayers = _layers.map((LayerData layer) {
          return layer.copyWith(
            layerDrawHistory: List<DrawData>.from(_cachedLayerHistories[layer.id] ?? const []),
          );
        }).toList();

        final List<LayerData> dirtyLayers = packagedLayers.where((LayerData currentPackedLayer) {
          final originalLayerRecord = _layers.firstWhere(
            (orig) => orig.id == currentPackedLayer.id,
            orElse: () => currentPackedLayer,
          );
          return originalLayerRecord.isDirty;
        }).toList();

        // =====================================================================
        // LOOP EXIT GATEWAY
        // =====================================================================
        if (dirtyLayers.isEmpty && _pendingLayerDeletionsLog.isEmpty && layersToPurgeThisPass.isEmpty) {
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

          _layers = packagedLayers
              .map((LayerData layer) => layer.copyWith(isDirty: false))
              .toList();
        }

        // =====================================================================
        // TASK D: UPDATE CANVAS LAYER ID INDEX SEQUENCE MANIFESTS
        // =====================================================================
        await _synchronizeCanvasMetadata();

        // =====================================================================
        // 🟢 TASK E: RUN HARD DISK PURGES LAST (PREVENTS GHOST RE-WRITES)
        // =====================================================================
        // Executing file erasures strictly after all canvas metadata alterations 
        // have concluded guarantees that your local filesystem services never 
        // accidentally auto-generate or re-write empty folders for the removed layer!
        if (layersToPurgeThisPass.isNotEmpty) {
          final List<String> deletionsBatch = List<String>.from(layersToPurgeThisPass);
          layersToPurgeThisPass.clear();

          for (final String layerIdToDelete in deletionsBatch) {
            final Result<void> deleteResult = await _layerDataRepository.deleteLayer(layerIdToDelete);
            
            if (deleteResult is Error) {
              log.w('Failed to purge disk record file for deleted layer $layerIdToDelete: ${(deleteResult).error}');
              _pendingLayerDeletionsLog.add(layerIdToDelete); // Re-queue if severe system lock
            }
          }
        }
      }

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


    // 3. Commit the aggregate blueprint down to the local file storage repository
    final result = await _canvasDataRepository.createCanvasData(templateCanvas);

    switch (result) {
      case Ok<CanvasData>():

      final layerResult = await _layerDataRepository.saveDirtyLayers([initialLayer]);

      switch(layerResult){
        case Ok():
          _currentCanvas = result.value;
          
        _layers = [initialLayer];
        
        _cachedLayerHistories.clear();
        _cachedLayerHistories[initialLayerId] = [];
        
        _drawHistory.clear();
        _undoHistory.clear(); // Flawless clean timeline history on startup
        _redoHistory.clear();
        _layerSnapshots.clear();
        _pendingLayerDeletionsLog.clear();
        
        _activeLayerIndex = 0;

        // 6. Request immediate UI layout view tree redraw
        notifyListeners();

        return Result.ok(null);
        case Error():
          return Result.error(layerResult.error);
      }
        // _currentCanvas = result.value;



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

  Future<void> _synchronizeCanvasMetadata() async {
    if (_currentCanvas == null) return;
    
    // 🟢 THE RESOLUTION: Rebuild the manifest layer mapping strictly using 
    // the live, active elements currently sitting inside your _layers array!
    // If an AddLayer undo step just removed the layer from memory, this ensures 
    // its ID string token is completely purged from the document description block.
    final updatedCanvas = _currentCanvas!.copyWith(
      layerIds: _layers.map((layer) => layer.id).toList(),
    );
    
    // Push the clean, pruned manifest down to your local storage files
    final canvasSaveResult = await _canvasDataRepository.modifyCanvasData(updatedCanvas);
    
    if (canvasSaveResult is Ok<CanvasData>) {
      _currentCanvas = canvasSaveResult.value;
    } else {
      log.w('Failed to synchronize project canvas structure metadata maps.');
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
