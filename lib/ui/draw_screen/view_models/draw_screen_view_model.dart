import 'package:drawing_app/data/repositories/canvas_data_repository/canvas_data_repository.dart';
import 'package:drawing_app/data/repositories/layer_data_repository/layer_data_repository.dart';
import 'package:drawing_app/domain/models/canvas/canvas_data.dart';
import 'package:drawing_app/domain/models/draw_command/draw_command.dart';
import 'package:drawing_app/domain/models/draw_layer/draw_layer.dart';
import 'package:drawing_app/domain/models/draw_tools/draw_tool.dart';
import 'package:drawing_app/domain/models/draw_tools/freehand_tool.dart';
import 'package:drawing_app/utils/command.dart';
import 'package:drawing_app/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const Uuid uuid = Uuid();

class DrawScreenViewModel extends ChangeNotifier {
  DrawScreenViewModel({
    required LayerDataRepository layerDataRepository,
    required CanvasDataRepository canvasDataRepository,
  }) : _layerDataRepository = layerDataRepository,
       _canvasDataRepository = canvasDataRepository {
    _currentTool = tools.values.first;

    loadProject = Command1(_loadProject);
    initProject = Command0(_initializeNewProject);
    createLayer = Command0(_createAndAddLayer);
    saveDirtyProgress = Command0(_saveDirtyProgress);
  }

  final LayerDataRepository _layerDataRepository;
  final CanvasDataRepository _canvasDataRepository;

  late final Command1<void, String> loadProject;
  late final Command0 initProject;
  late final Command0 createLayer;
  late final Command0 saveDirtyProgress;
  CanvasData? _currentCanvas;
  List<DrawLayer> _layers = [];
  String? _activeLayerId;

  CanvasData? get currentCanvas => _currentCanvas;
  List<DrawLayer> get layers => _layers;
  String? get activeLayerId => _activeLayerId;
  DrawTool get currentTool => _currentTool;
  DrawCommand? get activeCommand => _activeCommand;
  List<DrawCommand> get drawHistory => _drawHistory;
  List<DrawCommand> get redoHistory => _redoHistory;
  Color get strokeColor => _strokeColor;
  double get strokeWidth => _strokeWidth;
  bool get canUndo => _drawHistory.isNotEmpty;
  bool get canRedo => _redoHistory.isNotEmpty;

  final Map<String, DrawTool> tools = {
    'Freehand Tool': const FreehandTool(
      toolName: 'Freehand Tool',
      toolIcon: Icon(Icons.draw),
    ),
  };

  late DrawTool _currentTool;
  DrawCommand? _activeCommand;

  final List<DrawCommand> _drawHistory = [];
  final List<DrawCommand> _redoHistory = [];

  final Map<String, List<DrawCommand>> _cachedLayerHistories = {};

  Color _strokeColor = Colors.black;
  double _strokeWidth = 5.0;

  DrawLayer? get activeLayer =>
      _layers.where((l) => l.id == _activeLayerId).firstOrNull;

  List<DrawCommand> getHistoryForLayer(String layerId) =>
      _cachedLayerHistories[layerId] ?? const [];

  void handlePanStart(Offset startPoint) {
    if (_activeLayerId == null) return;

    final strokeSettings = Paint()
      ..color = _strokeColor
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Instantiate an isolated fresh DrawCommand linked cleanly to the target layerId boundary
    _activeCommand = _currentTool.onDrawStart(
      startPoint,
      strokeSettings,
      Paint(),
      _activeLayerId!,
    );
    notifyListeners();
  }

  void handlePanUpdate(Offset usePoint) {
    if (_activeCommand == null) return;
    _activeCommand = _currentTool.onUpdateTool(_activeCommand!, usePoint);
    notifyListeners();
  }

  void handlePanEnd() {
    if (_activeCommand == null || _activeLayerId == null) return;

    final finalizedCommand = _currentTool.onDrawEnd(_activeCommand!);
    _drawHistory.add(finalizedCommand);
    _redoHistory
        .clear(); // Wipes alternate redo timelines when a fresh stroke drops

    // Append to fast volatile layout memory cache instantly
    _cachedLayerHistories[_activeLayerId!] = [
      ...?_cachedLayerHistories[_activeLayerId!],
      finalizedCommand,
    ];

    // Mark current target layer modified in the main array track
    _markLayerAsDirtyById(_activeLayerId!);

    _activeCommand = null;
    notifyListeners(); // Refresh UI layout canvas surface vectors instantly

    // AUTOMATIC BACKGROUND PERSISTENCE TICK
    // Fires asynchronously without causing frame drops or freezing the user touch stream.
    
    if (!saveDirtyProgress.running) {
      saveDirtyProgress.execute();
    }
  }

  void executeUndo() {
    if (_drawHistory.isEmpty) return;

    final cmd = _drawHistory.removeLast();
    _redoHistory.add(cmd);

    _rebuildCacheForLayer(cmd.layerId);
    _markLayerAsDirtyById(cmd.layerId);
    notifyListeners();

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
    notifyListeners();

    if (!saveDirtyProgress.running) {
      saveDirtyProgress.execute();
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
        _layers = loadedLayersResult.value;
        _activeLayerId = _layers.last.id;

        _cachedLayerHistories.clear();
        _drawHistory.clear();
        _redoHistory.clear();

        for (var layer in _layers) {
          _cachedLayerHistories[layer.id] = List<DrawCommand>.from(
            layer.layerDrawHistory,
          );
          _drawHistory.addAll(layer.layerDrawHistory);
        }
      case Error():
        return Result.error(loadedLayersResult.error);
    }

    notifyListeners();
    return Result.ok(null);
  }

Future<Result<void>> _saveDirtyProgress() async {
  if (_currentCanvas == null) return Result.error(Exception('Canvas cannot be empty'));

  // 1. BRIDGE THE GAP: Pack memory cache into the immutable layer models
  final packagedLayers = _layers.map((layer) {
    if (layer.isDirty) {
      // Pull the specific history for this layer from your fast memory cache
      final currentHistory = _cachedLayerHistories[layer.id] ?? const [];
      
      // Update the actual model with the history before saving
      return layer.copyWith(
        layerDrawHistory: currentHistory,
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
      _layers = packagedLayers.map((layer) => layer.copyWith(isDirty: false)).toList();
      notifyListeners();
    case Error():
      return Result.error(result.error);
  }
  return Result.ok(null);
}

  Future<Result<void>> _createAndAddLayer() async {
    if (_currentCanvas == null){
      return Result.error(
        Exception('Canvas must not be null when adding new layer'),
      );}

    final newLayer = DrawLayer(
      id: uuid.v4(),
      name: 'Layer ${_layers.length}',
      canvasId: _currentCanvas!.id,
      zIndex: _layers.length,
      isDirty: false, // Starts fresh on disk
    );

    final addResult = await _layerDataRepository.addLayer(newLayer);

    switch (addResult) {
      case Ok():
        _layers = [..._layers, addResult.value];
        _activeLayerId = addResult
            .value
            .id; // Focus the cursor onto the added drawing target
        _cachedLayerHistories[addResult.value.id] =
            []; // Deploy a clean caching bucket map track
        await _canvasDataRepository.modifyCanvasData(_currentCanvas!.copyWith(layerIds: [..._currentCanvas!.layerIds, addResult.value.id]));
        notifyListeners();
      case Error():
        return Result.error(addResult.error);
    }
    return Result.ok(null);
  }

  Future<Result<void>> _initializeNewProject() async {
    // 1. Create a default shell model (the repository handles assigning the actual unique Uuid)
    final templateCanvas = CanvasData(
      id: 'temp', // Left blank, repository will overwrite with uuid.v4()
      name: 'Untitled Drawing',
      layerIds: [],
    );

    // 2. Persist the parent aggregate file structure via the repository
    final result = await _canvasDataRepository.createCanvasData(templateCanvas);

    switch (result) {
      case Ok<CanvasData>():
        _currentCanvas = result.value;

        // 3. Automatically spin up the first default base layer for this new canvas
        final createBaseLayerResult =
            await _createAndAddLayer(); // Sets up Layer 0 and marks active layer ID

        switch (createBaseLayerResult) {
          case Ok():
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
}
