import 'dart:async';
import 'dart:typed_data';

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
import 'package:drawing_app/utils/command.dart';
import 'package:drawing_app/utils/extensions.dart';
import 'package:drawing_app/utils/image_conversion.dart';
import 'package:drawing_app/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

const Uuid uuid = Uuid();

class DrawScreenViewModel extends ChangeNotifier {
  DrawScreenViewModel({
    required LayerDataRepository layerDataRepository,
    required CanvasDataRepository canvasDataRepository,
  }) : _layerDataRepository = layerDataRepository,
       _canvasDataRepository = canvasDataRepository {

    deleteLayer = Command1(_deleteLayer);
    loadProject = Command1(_loadProject);
    // initProject = Command1(_initializeNewProject);
    createLayer = Command0(_createAndAddLayer);
    saveDirtyProgress = Command0(_saveDirtyProgress);
  }

  static const canvasBackgroundColor = Colors.white;

  // Logger 
  Logger log = Logger();

  // Repository Fields 
  final LayerDataRepository _layerDataRepository;
  final CanvasDataRepository _canvasDataRepository;
  final CanvasToImageProcessor canvasToImageProcessor =
      CanvasToImageProcessor();

  // Async Commands
  late final Command1<void, String> loadProject;
  late final Command1<void, Size> initProject;
  late final Command0 createLayer;
  late final Command0 saveDirtyProgress;
  late final Command1<void, String> deleteLayer;

  // Map of commands storing calls to get layersnapshots to allow them to execute async
  final Map<String, Command1<void, String>> _layerSnapshotCommands = {};

 Command1<void, String> getSnapshotCommandForLayer(String layerId) {
    return _layerSnapshotCommands.putIfAbsent(layerId, () {
      return Command1<void, String>(
        _getLayerSnapshot,
        allowConcurrent: true, 
      );
    });
  }

  bool isLayerMenuOpen = false;
  final List<String> _pendingLayerDeletionsLog = [];

  CanvasDataCreated? _currentCanvas;
  List<LayerData> _layers = [];

  double _gridCellSize = 35;
  bool _gridEnabled = true;
  bool _gridSnapEnabled = true;

  CanvasData get currentCanvas => _currentCanvas ?? CanvasData.placeholder();
  List<LayerData> get layers => _layers;
  Map<String, Uint8List> get layerSnapshots => _layerSnapshots;
  List<DrawData> get drawHistory => _drawHistory;
  List<CanvasCommand> get redoHistory => _redoHistory;
  bool get canUndo => _undoHistory.isNotEmpty;
  bool get canRedo => _redoHistory.isNotEmpty;
  
  double get gridCellSize => _gridCellSize;
  bool get gridEnabled => _gridEnabled;
  bool get gridSnapEnabled => _gridSnapEnabled;

  int _activeLayerIndex = 0;

  final List<DrawData> _drawHistory = [];
   final List<CanvasCommand>_undoHistory = [];
  final List<CanvasCommand> _redoHistory = [];
  final Map<String, Uint8List> _layerSnapshots = {};

  int _transformRevision = 0;
  int get transformRevision => _transformRevision;


  final Map<String, List<DrawData>> _cachedLayerHistories = {};

  final ToolMatrixPayload camera = ToolMatrixPayload();

  Offset? _lastSnappedWorldPoint;

  void clearSnappingSession() {
    _lastSnappedWorldPoint = null;
  }

  Offset getSnappedWorldPoint(Offset rawScreenPoint) {
    final Offset worldPoint = rawScreenPoint.screenToWorld(camera.transform);

    if (!gridSnapEnabled) {
      return worldPoint;
    }

    // 2. Initialize the very first coordinate anchor when the user lands their finger
    if (_lastSnappedWorldPoint == null) {
      final double initialX = (worldPoint.dx / gridCellSize).round() * gridCellSize;
      final double initialY = (worldPoint.dy / gridCellSize).round() * gridCellSize;
      _lastSnappedWorldPoint = Offset(initialX, initialY);
      return _lastSnappedWorldPoint!;
    }

    // 3. 🟢 COMPUTE LOCAL DELTAS FROM THE LAST STEP NODE:
    // This evaluates your movement intent step-by-step, removing the rubber-band bug!
    final Offset stepVector = worldPoint - _lastSnappedWorldPoint!;
    final double absX = stepVector.dx.abs();
    final double absY = stepVector.dy.abs();

    // Dead-zone safety gate: If the pointer hasn't moved at least halfway 
    // to a new grid cell threshold step, keep it locked on the active node.
    if (absX < gridCellSize * 0.5 && absY < gridCellSize * 0.5) {
      return _lastSnappedWorldPoint!;
    }

    double snappedX = _lastSnappedWorldPoint!.dx;
    double snappedY = _lastSnappedWorldPoint!.dy;

    // 4. 🟢 THE LOCALIZED DIRECTION DETECTOR
    // Check the aspect ratio of the short step to lock clean 45 or straight paths
    if (absX > 0.0 && absY / absX > 0.6 && absY / absX < 1.4) {
      // Intentional Diagonal: Advance BOTH axes symmetrically by exactly 1 grid cell step!
      snappedX += stepVector.dx.sign * gridCellSize;
      snappedY += stepVector.dy.sign * gridCellSize;
    } 
    // Cardinal locks: advance only the primary movement axis
    else if (absX > absY) {
      // Primary Horizontal: Step only along the X axis, keeping Y locked flat
      snappedX += stepVector.dx.sign * gridCellSize;
    } else {
      // Primary Vertical: Step only along the Y axis, keeping X locked flat
      snappedY += stepVector.dy.sign * gridCellSize;
    }

    final Offset newSnap = Offset(snappedX, snappedY);
    
    // 5. Update our step anchor baseline tracking context for the next frame
    _lastSnappedWorldPoint = newSnap;
    return newSnap;
  }



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

    command.execute(context);

    _undoHistory.add(command);
    _redoHistory.clear(); 
    final bool targetLayerStillExists = _layers.any((l) => l.id == command.layerId);
    if (targetLayerStillExists) {
      _rebuildCacheForLayer(command.layerId);
      _markLayerAsDirtyById(command.layerId);
    } else {
      _pendingLayerDeletionsLog.add(command.layerId);
      _cachedLayerHistories.remove(command.layerId);
      layerSnapshots.remove(command.layerId);
    }

    final int verifiedIndex = _layers.indexWhere((l) => l.id == activeIdBeforeExecution);
    if (verifiedIndex != -1) {
      _activeLayerIndex = verifiedIndex;
    } else {
      _activeLayerIndex = _activeLayerIndex.clamp(0, _layers.length - 1);
    }

    notifyListeners();

    if (!saveDirtyProgress.running) {
      saveDirtyProgress.execute();
    }
  }

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

    command.undo(context);
    _redoHistory.add(command);

    final bool targetLayerStillExists = _layers.any((l) => l.id == command.layerId);
    if (targetLayerStillExists) {
      _rebuildCacheForLayer(command.layerId);
      _markLayerAsDirtyById(command.layerId);
    } else {
      _pendingLayerDeletionsLog.add(command.layerId);
      _cachedLayerHistories.remove(command.layerId);
      layerSnapshots.remove(command.layerId);
    }

    final int verifiedIndex = _layers.indexWhere((l) => l.id == activeIdBeforeUndo);
    if (verifiedIndex != -1) {
      _activeLayerIndex = verifiedIndex;
    } else {
      _activeLayerIndex = _activeLayerIndex.clamp(0, _layers.length - 1);
    }

    notifyListeners();

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
    
    command.execute(context);
    _undoHistory.add(command);

    if (command is DeleteLayerCommand) {
      _pendingLayerDeletionsLog.add(command.layerId);
    }

    final bool targetLayerStillExists = _layers.any((l) => l.id == command.layerId);

    if (targetLayerStillExists) {
      _rebuildCacheForLayer(command.layerId);
      _markLayerAsDirtyById(command.layerId);
    }

 
    final int verifiedIndex = _layers.indexWhere((l) => l.id == activeIdBeforeRedo);
    if (verifiedIndex != -1) {
      _activeLayerIndex = verifiedIndex;
    } else {
      _activeLayerIndex = _activeLayerIndex.clamp(0, _layers.length - 1);
    }

    _layers = List<LayerData>.from(_layers);

    notifyListeners();

    if (!saveDirtyProgress.running) {
      saveDirtyProgress.execute();
    }
  }

  void resizeCanvas(double newWidth, double newHeight) async {

    // Potect against zero or negative dimensions
    if (newWidth <= 0 || newHeight <= 0 || _currentCanvas == null) return;

    CanvasDataCreated prevData = _currentCanvas!.copyWith(canvasSize: Size(newWidth, newHeight));


    final modResult = await _canvasDataRepository.modifyCanvasData(prevData);

    switch(modResult){
      case Ok<CanvasDataCreated>():
        _currentCanvas = modResult.value;
      case Error():
        log.e(modResult.error);
        return;
    }
    _transformRevision++;
    // Increment the revision counter to force the RepaintBoundary to clear its texture cache
    notifyListeners();

    // 4. Force refresh layer snapshot previews to update background framing aspect ratios
    for (var layer in _layers) {
      getSnapshotCommandForLayer(layer.id).execute(layer.id);
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
    // Calculate the empty padding space remaining when scale is exactly 1.0
    final double extraWidth = viewportSize.width - currentCanvas.currentWidth;
    final double extraHeight = viewportSize.height - currentCanvas.currentHeight;

    // Divide by 2 to find the exact midpoint coordinates
    final double centerX = extraWidth / 2.0;
    final double centerY = extraHeight / 2.0;

    // Reset the master camera matrix back to default 100% scale and centered pan
    // Instantiate a new Identity matrix, which naturally resets scale components to 1.0.
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
    final loadedCanvasResult = await _canvasDataRepository.getCanvasData(
      canvasId,
    );

    switch (loadedCanvasResult) {
      case Ok():
        _currentCanvas = loadedCanvasResult.value;
      case Error():
        return Result.error(loadedCanvasResult.error);
    }

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

        _cachedLayerHistories.clear();
        _drawHistory.clear();
        _undoHistory.clear();
        _redoHistory.clear();
        _layerSnapshots.clear();

        for (var layer in _layers) {
          _cachedLayerHistories[layer.id] = List<DrawData>.from(
            layer.layerDrawHistory,
          );
          _drawHistory.addAll(layer.layerDrawHistory);
        }

        _activeLayerIndex = 0;

        notifyListeners();

      case Error():
        return Result.error(loadedLayersResult.error);
    }
    return Result.ok(null);
  }

  void reorderLayers(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _layers.length) return;
    if (newIndex < 0 || newIndex > _layers.length) return;

    final reorderCommand = ReorderLayerCommand(
      layerId: _layers[oldIndex].id,
      oldIndex: oldIndex,
      newIndex: newIndex,
      currentHistoryLength: _drawHistory.length, 
    );

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
      

      final List<String> layersToPurgeThisPass = [];

      while (working) {
        if (_pendingLayerDeletionsLog.isNotEmpty) {
          layersToPurgeThisPass.addAll(_pendingLayerDeletionsLog);
          _pendingLayerDeletionsLog.clear(); 
        }

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


        if (dirtyLayers.isEmpty && _pendingLayerDeletionsLog.isEmpty && layersToPurgeThisPass.isEmpty) {
          working = false;
          break;
        }

        if (dirtyLayers.isNotEmpty) {
          final Result<void> saveResult = await _layerDataRepository.saveDirtyLayers(dirtyLayers);
          
          if (saveResult is Error) {
            return Result.error(saveResult.error);
          }

          _layers = packagedLayers
              .map((LayerData layer) => layer.copyWith(isDirty: false))
              .toList();
        }

        await _synchronizeCanvasMetadata();

        if (layersToPurgeThisPass.isNotEmpty) {
          // Deduplicate the list using a set to stop identical concurrent IDs
          final List<String> deletionsBatch = layersToPurgeThisPass.toSet().toList();
          layersToPurgeThisPass.clear();

          final String activeCanvasId = _currentCanvas!.id;

          for (final String layerIdToDelete in deletionsBatch) {
            final Result<void> deleteResult = await _layerDataRepository.deleteLayer(
              canvasId: activeCanvasId,
              id: layerIdToDelete,
            );
            
            if (deleteResult is Error) {
              log.w('Failed to purge disk record file for deleted layer $layerIdToDelete: ${(deleteResult).error}');
              _pendingLayerDeletionsLog.add(layerIdToDelete); 
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

    final deleteCommand = DeleteLayerCommand(
      layerId: layerId, 
      index: targetIndex, 
      deletedLayer: deletedLayer,
    );

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

  /// Creates a new, empty layer directly above the current active layer
  Future<Result<void>> _createAndAddLayer() async {
    if (_currentCanvas == null) {
      return Result.error(
        Exception("Canvas must not be null before creating layers"),
      );
    }

    final String newUniqueId = uuid.v4();

    final int targetedInsertionIndex = _activeLayerIndex + 1;
    final int nextDisplayNumber = _layers.length + 1;

    final LayerData newLayer = LayerData(
      id: newUniqueId,
      index: targetedInsertionIndex,
      name: 'Layer $nextDisplayNumber',
      canvasId: _currentCanvas!.id,
      isDirty: true, 
      isVisible: true,
      layerDrawHistory: const [],
    );

    final command = AddLayerCommand(
      layerId: newUniqueId,
      index: targetedInsertionIndex,
      layerData: newLayer,
    );

    executeCommand(command);
    _activeLayerIndex = targetedInsertionIndex;
    notifyListeners();

    return Result.ok(null);
  }

  /*LEAVING HERE IN THE EVENT OF NEEDING TO CREATE NEW PROJECTS FROM WITHIN THE PROJECT SCREEN
  // Future<Result<void>> _initializeNewProject(Size canvasSize) async {

  //   final String initialCanvasId = uuid.v4();
  //   final String initialLayerId = uuid.v4();

  //   final templateCanvas = CanvasDataNew(
  //     canvasSize: canvasSize,
  //     id: initialCanvasId, 
  //     name: 'Untitled Drawing',
  //     layerIds: [initialLayerId], 
  //   );

  //       final initialLayer = LayerData(
  //         id: initialLayerId,
  //         index: 0,
  //         name: 'Layer 1',
  //         canvasId: initialCanvasId,
  //         isDirty: true, 
  //         isVisible: true,
  //         layerDrawHistory: const [],
  //       );


  //   final result = await _canvasDataRepository.createCanvasData(templateCanvas);

  //   switch (result) {
  //     case Ok<CanvasDataNew>():

  //     final layerResult = await _layerDataRepository.saveDirtyLayers([initialLayer]);

  //     switch(layerResult){
  //       case Ok():
  //         _currentCanvas = result.value;
          
  //       _layers = [initialLayer];
        
  //       _cachedLayerHistories.clear();
  //       _cachedLayerHistories[initialLayerId] = [];
        
  //       _drawHistory.clear();
  //       _undoHistory.clear();
  //       _redoHistory.clear();
  //       _layerSnapshots.clear();
  //       _pendingLayerDeletionsLog.clear();
        
  //       _activeLayerIndex = 0;

  //       notifyListeners();

  //       return Result.ok(null);
  //       case Error():
  //         return Result.error(layerResult.error);
  //     }




  //     case Error():
  //       return Result.error(result.error);
  //   }
  // }
  */


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

  Future<void> _synchronizeCanvasMetadata() async {
    if (_currentCanvas == null) return;
    
    final updatedCanvas = _currentCanvas!.copyWith(
      layerIds: _layers.map((layer) => layer.id).toList(),
    );
    
    final canvasSaveResult = await _canvasDataRepository.modifyCanvasData(updatedCanvas);
    
    if (canvasSaveResult is Ok<CanvasDataCreated>) {
      _currentCanvas = canvasSaveResult.value;
    } else {
      log.w('Failed to synchronize project canvas structure metadata maps.');
    }
  }

  Future<Result> _getLayerSnapshot(
    String layerId) async {
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
