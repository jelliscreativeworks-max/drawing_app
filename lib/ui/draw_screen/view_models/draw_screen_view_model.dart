import 'dart:async';
import 'dart:typed_data';

import 'package:drawing_app/data/repositories/canvas_data_repository/canvas_data_repository.dart';
import 'package:drawing_app/data/repositories/layer_data_repository/layer_data_repository.dart';
import 'package:drawing_app/domain/models/canvas/canvas_data.dart';
import 'package:drawing_app/domain/models/draw_command/draw_command.dart';
import 'package:drawing_app/domain/models/draw_layer/draw_layer.dart';
import 'package:drawing_app/domain/models/draw_tools/draw_tool.dart';
import 'package:drawing_app/domain/models/draw_tools/draw_tools_list.dart';
import 'package:drawing_app/utils/command.dart';
import 'package:drawing_app/utils/image_conversion.dart';
import 'package:drawing_app/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

const Uuid uuid = Uuid();
// TODO: SHOULDNT BE ABLE TO UNDO OPERATIONS ON A DELETED LAYER

class DrawScreenViewModel extends ChangeNotifier {
  DrawScreenViewModel({
    required LayerDataRepository layerDataRepository,
    required CanvasDataRepository canvasDataRepository,
  }) : _layerDataRepository = layerDataRepository,
       _canvasDataRepository = canvasDataRepository {
    _currentTool = DrawToolsList.pan;

    deleteLayer = Command1(_deleteLayer);
    loadProject = Command1(_loadProject);
    initProject = Command0(_initializeNewProject);
    createLayer = Command0(_createAndAddLayer);
    saveDirtyProgress = Command0(_saveDirtyProgress);

    // generateSnapshot = Command1(_getLayerSnapshot);
    // saveLayerSnapshot = Command1(_getLayerSnapshot);
  }

  static const canvasBackgroundColor = Colors.white;

  double _canvasWidth = 2000.0;
  double _canvasHeight = 2000.0;

  double get canvasWidth => _canvasWidth;
  double get canvasHeight => _canvasHeight;

  Logger log = Logger();

  final LayerDataRepository _layerDataRepository;
  final CanvasDataRepository _canvasDataRepository;
  final CanvasToImageProcessor canvasToImageProcessor =
      CanvasToImageProcessor();

  late final Command1<void, String> loadProject;
  // late final Command1<void, String> saveLayerSnapshot;
  late final Command0 initProject;
  late final Command0 createLayer;
  late final Command0 saveDirtyProgress;
  late final Command1<void, String> deleteLayer;

  bool isLayerMenuOpen = false;

  Offset _panStartOrigin = Offset.zero;

  int get transformRevision => _transformRevision;

  bool get isPanAndZoomActive => _currentTool.isNavigationTool;

  // late final Command1<void, String> generateSnapshot;
  final Map<String, Command1<void, String>> _layerSnapshotCommands = {};

  Command1<void, String> getSnapshotCommandForLayer(String layerId) {
    return _layerSnapshotCommands.putIfAbsent(layerId, () {
      return Command1<void, String>(
        _getLayerSnapshot,
        allowConcurrent: true, // 🟢 Allows multiple layers to process at once!
      );
    });
  }

  Offset? _drawingStartPoint;
  bool _isStrokeStabilized = false;

  CanvasData? _currentCanvas;
  List<DrawLayer> _layers = [];
  String? _activeLayerId;

  CanvasData? get currentCanvas => _currentCanvas;
  List<DrawLayer> get layers => _layers;
  Map<String, Uint8List> get layerSnapshots => _layerSnapshots;
  String? get activeLayerId => _activeLayerId;
  DrawTool get currentTool => _currentTool;
  DrawCommand? get activeCommand => _activeCommand;
  List<DrawCommand> get drawHistory => _drawHistory;
  List<DrawCommand> get redoHistory => _redoHistory;
  Color get strokeColor => _strokeColor;
  double get strokeWidth => _strokeWidth;
  bool get canUndo => _drawHistory.isNotEmpty;
  bool get canRedo => _redoHistory.isNotEmpty;

  late DrawTool _currentTool;
  DrawCommand? _activeCommand;

  final List<DrawCommand> _drawHistory = [];
  final List<DrawCommand> _redoHistory = [];
  final Map<String, Uint8List> _layerSnapshots = {};

  final GlobalKey canvasKey = GlobalKey();

  final Map<String, List<DrawCommand>> _cachedLayerHistories = {};

  Color _strokeColor = Colors.blue;
  double _strokeWidth = 5.0;

  DrawLayer? get activeLayer =>
      _layers.where((l) => l.id == _activeLayerId).firstOrNull;

  List<DrawCommand> getHistoryForLayer(String layerId) =>
      _cachedLayerHistories[layerId] ?? const [];

  Matrix4 _transform = Matrix4.identity();
  double _scaleStart = 1.0;
  int _transformRevision = 0;
  Offset _focalPointAtStart = Offset.zero;

  Matrix4 get transform => _transform;
  double get scale => _transform.getMaxScaleOnAxis();

  // --- ADOPTED FROM CANVAS_KIT: PIXEL-PERFECT SCREEN-TO-WORLD ENGINE ---
  Offset getTransformedOffset(Offset screenPoint) {
    if (_transform == Matrix4.identity()) return screenPoint;
    if (_transform.determinant().abs() < 1e-6) return screenPoint;

    try {
      // Invert the camera matrix completely to translate viewport pixels into canvas geometry
      final Matrix4 invertedMatrix = Matrix4.inverted(_transform);
      final vm.Vector3 vector = vm.Vector3(screenPoint.dx, screenPoint.dy, 0.0)
        ..applyMatrix4(invertedMatrix);
      return Offset(vector.x, vector.y);
    } catch (e) {
      return screenPoint;
    }
  }

  // --- DEFINITIVE DYNAMIC ARTBOARD RESIZER ---
  void resizeCanvas(double newWidth, double newHeight) {
    // 1. Safety guard rails protect against zero or negative dimensions
    if (newWidth <= 0 || newHeight <= 0) return;

    // 2. Assign the fresh bounding dimensions cleanly to your internal states
    _canvasWidth = newWidth;
    _canvasHeight = newHeight;

    // 3. Increment the revision counter to force the RepaintBoundary to clear its texture cache
    _transformRevision++;
    notifyListeners();

    // 4. Force refresh layer snapshot previews to update background framing aspect ratios
    for (var layer in _layers) {
      getSnapshotCommandForLayer(layer.id).execute(layer.id);
    }
  }

  void changeTool(DrawTool newTool) {
    if (_currentTool == newTool) return;

    _currentTool = newTool;
    notifyListeners();
  }

  void toggleLayerMenu() {
    isLayerMenuOpen = isLayerMenuOpen == true ? false : true;
    notifyListeners();
  }
  void handleScaleStart(ScaleStartDetails details) {
    _scaleStart = scale;
    final Offset rawCanvasPoint = getTransformedOffset(details.localFocalPoint);
    
    _focalPointAtStart = Offset(
      rawCanvasPoint.dx.clamp(0.0, _canvasWidth),
      rawCanvasPoint.dy.clamp(0.0, _canvasHeight),
    );
    _panStartOrigin = details.localFocalPoint;

    _drawingStartPoint = _focalPointAtStart;
    _isStrokeStabilized = false;

    // Pack up camera state matrices for tool consumption
    final cameraPayload = ToolMatrixPayload(
      transform: _transform,
      panStartOrigin: _panStartOrigin,
      scaleStart: _scaleStart,
      focalPointAtStart: _focalPointAtStart,
      currentScale: scale,
    );

    // Let the current strategy safely prepare its initialization data
    _currentTool.onDrawStart(
      startPoint: _focalPointAtStart,
      strokeSettings: Paint(),
      fillSettings: Paint(),
      layerId: _activeLayerId ?? '',
      drawHistory: _drawHistory,
      layerDrawHistory: _cachedLayerHistories,
      camera: cameraPayload,
    );
  }

    void handleScaleUpdate(ScaleUpdateDetails details) {
    // 1. 🌟 CAMERA NAVIGATION (PAN/ZOOM) STRATEGY ENFORCER
    // This block must live at the ABSOLUTE TOP to ensure multi-touch signals 
    // are never blocked or absorbed by drawing stabilization gates!
    final bool forceNavigation = details.pointerCount > 1;

    if (isPanAndZoomActive || forceNavigation) {
      if (_activeCommand != null || _drawingStartPoint != null) {
        _activeCommand = null;
        _drawingStartPoint = null;
        _isStrokeStabilized = false;
        notifyListeners();
      }

      if (details.pointerCount <= 1) {
        final Offset screenDelta = details.localFocalPoint - _panStartOrigin;
        if (screenDelta == Offset.zero) return;

        final cameraPayload = ToolMatrixPayload(
          transform: _transform,
          panStartOrigin: _panStartOrigin,
          scaleStart: _scaleStart,
          focalPointAtStart: _focalPointAtStart,
          currentScale: scale,
        );

        _currentTool.onUpdateTool(
          activeCommand: DrawCommand.data(toolName: '', layerId: '', points: const []),
          newPoint: details.localFocalPoint, 
          drawHistory: _drawHistory,
          layerDrawHistory: _cachedLayerHistories,
          camera: cameraPayload,
          pointerCount: details.pointerCount,
          gestureScale: details.scale,
        );

        _transform = cameraPayload.transform;
        _panStartOrigin = cameraPayload.panStartOrigin;
        _transformRevision++;
        notifyListeners();
        return;
      }

      // --- TWO-FINGER MULTI-TOUCH ZOOM MECHANICS ---
      final double proposedScale = _scaleStart * details.scale;
      final double clampedScale = proposedScale.clamp(0.2, 5.0);
      final double currentScale = scale;
      
      if ((clampedScale - currentScale).abs() < 1e-6) return;
      final double scaleMultiplier = clampedScale / currentScale;

      _transform = _transform.clone()
        ..translate(_focalPointAtStart.dx, _focalPointAtStart.dy)
        ..scale(scaleMultiplier, scaleMultiplier)
        ..translate(-_focalPointAtStart.dx, -_focalPointAtStart.dy);

      final Offset currentScreenPos = MatrixUtils.transformPoint(_transform, _focalPointAtStart);
      final Offset structuralDelta = details.localFocalPoint - currentScreenPos;
      _transform.translate(structuralDelta.dx / scale, structuralDelta.dy / scale);

      _transformRevision++;
      notifyListeners();
      return;
    }

    // 2. ROUTE TO LIVE DRAWING INK STRATEGY (Guaranteed 1-finger operation)
    if (_activeLayerId == null || _drawingStartPoint == null) return;

    final Offset rawCanvasPoint = getTransformedOffset(details.localFocalPoint);
    final Offset clampedCanvasPoint = Offset(
      rawCanvasPoint.dx.clamp(0.0, _canvasWidth),
      rawCanvasPoint.dy.clamp(0.0, _canvasHeight),
    );

    // 🌟 MOVE THE GESTURE STABILIZATION GATES HERE:
    // It now safely wraps ONLY single-finger draw paths, completely clearing out zoom locks!
    if (!_isStrokeStabilized) {
      final double travelDistance = (clampedCanvasPoint - _drawingStartPoint!).distance;
      
      // If a single finger hasn't moved 4 pixels, ignore this microframe to block landing dots
      if (travelDistance < 4.0) return;
      
      _isStrokeStabilized = true;
    }

    // Initialize the line command safely now that single-finger draw intent is verified
    if (_activeCommand == null) {
      final strokeSettings = Paint()
        ..color = _strokeColor
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final cameraPayload = ToolMatrixPayload(
        transform: _transform,
        panStartOrigin: _panStartOrigin,
        scaleStart: _scaleStart,
        focalPointAtStart: _focalPointAtStart,
        currentScale: scale,
      );

      _activeCommand = _currentTool.onDrawStart(
        startPoint: _drawingStartPoint!,
        strokeSettings: strokeSettings,
        fillSettings: Paint(),
        layerId: _activeLayerId!,
        drawHistory: _drawHistory,
        layerDrawHistory: _cachedLayerHistories,
        camera: cameraPayload,
      );
      notifyListeners();
      return;
    }

    final cameraPayload = ToolMatrixPayload(
      transform: _transform,
      panStartOrigin: _panStartOrigin,
      scaleStart: _scaleStart,
      focalPointAtStart: _focalPointAtStart,
      currentScale: scale,
    );

    final updatedCommand = _currentTool.onUpdateTool(
      activeCommand: _activeCommand!,
      newPoint: clampedCanvasPoint,
      drawHistory: _drawHistory,
      layerDrawHistory: _cachedLayerHistories,
      camera: cameraPayload,
      pointerCount: details.pointerCount,
      gestureScale: details.scale,
    );

    if (updatedCommand != null) {
      _activeCommand = updatedCommand;
      notifyListeners();
    }
  }


  void handleScaleEnd() {
    _drawingStartPoint = null;
    _isStrokeStabilized = false;

    if (_activeLayerId == null) return;

    final cameraPayload = ToolMatrixPayload(
      transform: _transform,
      panStartOrigin: _panStartOrigin,
      scaleStart: _scaleStart,
      focalPointAtStart: _focalPointAtStart,
      currentScale: scale,
    );

    _currentTool.onDrawEnd(
      activeCommand: _activeCommand,
      layerId: _activeLayerId!,
      drawHistory: _drawHistory,
      layerDrawHistory: _cachedLayerHistories,
      camera: cameraPayload,
    );

    _transform = cameraPayload.transform;
    _panStartOrigin = cameraPayload.panStartOrigin;

    if (isPanAndZoomActive) {
      _transformRevision++;
      notifyListeners();
      return;
    }

    _redoHistory.clear();
    _markLayerAsDirtyById(_activeLayerId!);
    _activeCommand = null;
    
    _transformRevision++;
    notifyListeners();

    final targetLayerId = _activeLayerId!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getSnapshotCommandForLayer(targetLayerId).execute(targetLayerId);
    });

    if (!saveDirtyProgress.running) {
      saveDirtyProgress.execute();
    }
  }


  void resetView(Size viewportSize) {
    // 1. Calculate the empty padding space remaining when scale is exactly 1.0
    final double extraWidth = viewportSize.width - _canvasWidth;
    final double extraHeight = viewportSize.height - _canvasHeight;

    // 2. Divide by 2 to find the exact midpoint coordinates
    final double centerX = extraWidth / 2.0;
    final double centerY = extraHeight / 2.0;

    // 3. Reset the master camera matrix back to default 100% scale and centered pan!
    // We instantiate a fresh Identity matrix, which naturally resets scale components to 1.0.
    _transform = Matrix4.identity();

    // Index 12 is translation X, and Index 13 is translation Y in column-major layout.
    _transform[12] = centerX;
    _transform[13] = centerY;

    // 4. Increment your revision and repaint the UI instantly
    _transformRevision++;
    notifyListeners();
  }

  void setActiveLayer(String layerId) {
    if (activeLayerId == layerId) return;

    _activeLayerId = layerId;

    _activeCommand = null;

    notifyListeners();
  }

  // Inside drawing_app/lib/ui/draw_screen/view_models/draw_screen_view_model.dart

  void executeUndo() {
    if (_drawHistory.isEmpty) return;

    final cmd = _drawHistory.removeLast();
    _redoHistory.add(cmd);

    _rebuildCacheForLayer(cmd.layerId);
    _markLayerAsDirtyById(cmd.layerId);

    _transformRevision++; // Invalidate RepaintBoundary texture cache
    notifyListeners();

    // 🌟 RESTORED SNAPSHOT LOGIC: Update snapshot previews to match the undone history state
    final targetLayerId = cmd.layerId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getSnapshotCommandForLayer(targetLayerId).execute(targetLayerId);
    });

    if (!saveDirtyProgress.running) {
      saveDirtyProgress.execute();
    }
  }

  void executeRedo() {
    if (_redoHistory.isEmpty) return;

    final cmd = _redoHistory.removeLast();
    _drawHistory.add(cmd);

    _rebuildCacheForLayer(cmd.layerId);
    _markLayerAsDirtyById(cmd.layerId);

    _transformRevision++; // Invalidate RepaintBoundary texture cache
    notifyListeners();

    // 🌟 RESTORED SNAPSHOT LOGIC: Update snapshot previews to match the redone history state
    final targetLayerId = cmd.layerId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getSnapshotCommandForLayer(targetLayerId).execute(targetLayerId);
    });

    if (!saveDirtyProgress.running) {
      saveDirtyProgress.execute();
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

        // Safety Fallback: Ensure active cursor assignment handles empty layer bounds gracefully
        _activeLayerId = _layers.lastOrNull?.id;

        // 3. Clean out temporary state memory tracks before reconstruction
        _cachedLayerHistories.clear();
        _drawHistory.clear();
        _redoHistory.clear();
        _layerSnapshots.clear();

        // 4. Reconstruct structural histories layer by layer
        for (var layer in _layers) {
          _cachedLayerHistories[layer.id] = List<DrawCommand>.from(
            layer.layerDrawHistory,
          );
          _drawHistory.addAll(layer.layerDrawHistory);
        }

        // ... (steps 1 to 4 loading and sorting layer arrays in _loadProject)

        // 5. Commit structural data vectors to screen
        notifyListeners();

        // 🟢 MENU FIX: Force background pre-warm on project loads
        for (var layer in _layers) {
          final currentLoopId = layer.id;

          WidgetsBinding.instance.addPostFrameCallback((_) async {
            // Give Flutter one engine loop tick to paint layout bounding boxes
            // before we attempt to snapshot them
            await Future.delayed(Duration.zero);

            // Warm up the snapshot map cache instantly in the background!
            getSnapshotCommandForLayer(currentLoopId).execute(currentLoopId);
          });
        }

      case Error():
        return Result.error(loadedLayersResult.error);
    }
    return Result.ok(null);
  }

  void reorderLayers(int oldIndex, int newIndex) {
    if (currentCanvas == null) return;
    // Flutter's internal adjustment for dragging downward
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    // Guard bounds just in case
    if (oldIndex == newIndex || newIndex < 0 || newIndex >= layers.length)
      return;

    // 1. Get a mutable copy of the current visible layers array to keep the UI in sync
    final updatedLayers = List<DrawLayer>.from(_layers);

    // Move the actual layer object in the runtime memory list
    final DrawLayer movedLayer = updatedLayers.removeAt(oldIndex);
    updatedLayers.insert(newIndex, movedLayer);
    _layers = updatedLayers;

    // 2. EXTRACT THE NEW ID TIMELINE ORDER FOR PERSISTENCE
    final List<String> newLayerIds = _layers.map((l) => l.id).toList();

    // 3. Update the parent canvas metadata model cleanly
    _currentCanvas = _currentCanvas!.copyWith(layerIds: newLayerIds);

    _canvasDataRepository.modifyCanvasData(
      currentCanvas!.copyWith(layerIds: newLayerIds),
    );

    notifyListeners(); // Triggers the 'viewModel' listenable
  }

  Future<Result<void>> _saveDirtyProgress() async {
    if (_currentCanvas == null)
      return Result.error(Exception('Canvas cannot be empty'));

    // 1. BRIDGE THE GAP: Pack memory cache into the immutable layer models
    final packagedLayers = _layers.map((layer) {
      if (layer.isDirty) {
        // Pull the specific history for this layer from your fast memory cache
        // Update the actual model with the history before saving
        return layer.copyWith(
          layerDrawHistory: _cachedLayerHistories[layer.id] ?? const [],
        );
      }
      return layer;
    }).toList();

    // 2. Filter for only the layers that actually need a file-write
    final dirtyLayers = packagedLayers.where((l) => l.isDirty).toList();
    if (dirtyLayers.isEmpty) return Result.ok(null);

    // 3. Offload to the repository for the background auto-save
    final result = await _layerDataRepository.saveDirtyLayers(dirtyLayers);

    switch (result) {
      case Ok():
        // 4. Update your local _layers list so they are no longer dirty
        _layers = packagedLayers
            .map((layer) => layer.copyWith(isDirty: false))
            .toList();
        notifyListeners();
      case Error():
        return Result.error(result.error);
    }
    return Result.ok(null);
  }

  Future<Result<void>> _deleteLayer(String layerId) async {
    if (_currentCanvas == null) {
      return Result.error(
        Exception("Canvas must not be null before deleting layers"),
      );
    }

    if (_layers.length <= 1)
      return Result.ok(null); //So we don't delete the last layer

    final deleteResult = await _layerDataRepository.deleteLayer(layerId);

    switch (deleteResult) {
      case Ok():
        _layers.removeWhere((layer) => layer.id == layerId);
        _activeLayerId = layerId == _activeLayerId
            ? _layers.last.id
            : _activeLayerId;
        // _cachedLayerHistories.remove(layerId);
        _cachedLayerHistories.remove(layerId);
        _drawHistory.removeWhere((drawCMD) => drawCMD.layerId == layerId);

        await _canvasDataRepository.modifyCanvasData(
          _currentCanvas!.copyWith(
            layerIds: _currentCanvas!.layerIds
                .where((id) => id != layerId)
                .toList(),
          ),
        );
        notifyListeners();
        return Result.ok(null);
      case Error():
        return Result.error(deleteResult.error);
    }
  }

  Future<Result<void>> _createAndAddLayer() async {
    if (_currentCanvas == null) {
      return Result.error(
        Exception('Canvas must not be null when adding new layer'),
      );
    }

    final newLayer = DrawLayer(
      id: uuid.v4(),
      name: 'Layer ${_layers.length}',
      canvasId: _currentCanvas!.id,
      isDirty: false,
    );

    final addResult = await _layerDataRepository.addLayer(newLayer);

    switch (addResult) {
      case Ok():
        _layers = [..._layers, addResult.value];
        _activeLayerId = addResult.value.id;
        _cachedLayerHistories[addResult.value.id] = [];

        await _canvasDataRepository.modifyCanvasData(
          _currentCanvas!.copyWith(
            layerIds: [..._currentCanvas!.layerIds, addResult.value.id],
          ),
        );

        // 1. Inflate layer onto view tree
        notifyListeners();

        // 🟢 MENU FIX: Force background pre-warm on new layer additions
        final targetLayerId = _activeLayerId!;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await Future.delayed(Duration.zero);
          getSnapshotCommandForLayer(targetLayerId).execute(targetLayerId);
        });

      case Error():
        return Result.error(addResult.error);
    }
    return Result.ok(null);
  }

  Future<Result<void>> _initializeNewProject() async {
    final templateCanvas = CanvasData(
      id: 'temp',
      name: 'Untitled Drawing',
      layerIds: [],
    );

    final result = await _canvasDataRepository.createCanvasData(templateCanvas);

    switch (result) {
      case Ok<CanvasData>():
        _currentCanvas = result.value;

        final createBaseLayerResult = await _createAndAddLayer();

        switch (createBaseLayerResult) {
          case Ok():
            // Guarantee layout sync down to the rendering tree
            notifyListeners();
            break;
          case Error():
            return Result.error(createBaseLayerResult.error);
        }
      case Error():
        return Result.error(result.error);
    }
    return Result.ok(null);
  }

  void _rebuildCacheForLayer(String layerId) {
    _cachedLayerHistories[layerId] = _drawHistory
        .where((cmd) => cmd.layerId == layerId)
        .toList();
  }

  void _markLayerAsDirtyById(String layerId) {
    _layers = _layers.map((layer) {
      if (layer.id == layerId) {
        return layer.copyWith(isDirty: true);
      }
      return layer;
    }).toList();
  }

  Future<Result> _getLayerSnapshot(String layerId) async {
    final List<DrawCommand> layerHistory =
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
            drawTools: DrawToolsList.map,
            transparency: _activeLayerId == layerId ? 1.0 : 0.6,
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
