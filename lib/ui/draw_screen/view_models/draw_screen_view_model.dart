import 'dart:async';
import 'dart:typed_data';

import 'package:drawing_app/data/repositories/canvas_data_repository/canvas_data_repository.dart';
import 'package:drawing_app/data/repositories/layer_data_repository/layer_data_repository.dart';
import 'package:drawing_app/domain/models/canvas/canvas_data.dart';
import 'package:drawing_app/domain/models/draw_command/draw_command.dart';
import 'package:drawing_app/domain/models/draw_layer/draw_layer.dart';
import 'package:drawing_app/domain/models/draw_tools/draw_tool.dart';
import 'package:drawing_app/domain/models/draw_tools/freehand_tool.dart';
import 'package:drawing_app/utils/command.dart';
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
    _currentTool = tools.values.first;

    loadProject = Command1(_loadProject);
    initProject = Command0(_initializeNewProject);
    createLayer = Command0(_createAndAddLayer);
    saveDirtyProgress = Command0(_saveDirtyProgress);

    // generateSnapshot = Command1(_getLayerSnapshot);
    // saveLayerSnapshot = Command1(_getLayerSnapshot);
  }

  Logger log = Logger();

  final LayerDataRepository _layerDataRepository;
  final CanvasDataRepository _canvasDataRepository;
  final CanvasToImageProcessor canvasToImageProcessor = CanvasToImageProcessor();

  late final Command1<void, String> loadProject;
  // late final Command1<void, String> saveLayerSnapshot;
  late final Command0 initProject;
  late final Command0 createLayer;
  late final Command0 saveDirtyProgress;

  // late final Command1<void, String> generateSnapshot;
  final Map<String, Command1<void, String>> _layerSnapshotCommands = {};

    Command1<void, String> getSnapshotCommandForLayer(String layerId) {
    return _layerSnapshotCommands.putIfAbsent(layerId, () {
      // Create a brand new, isolated command instance bound to this specific layer
      return Command1<void, String>(_getLayerSnapshot);
    });
  }

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
  final Map<String, GlobalKey> _layerGlobalKeys = {};
  final Map<String, Uint8List> _layerSnapshots = {};



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
    _redoHistory.clear(); 

    _cachedLayerHistories[_activeLayerId!] = [
      ...?_cachedLayerHistories[_activeLayerId!],
      finalizedCommand,
    ];
    _markLayerAsDirtyById(_activeLayerId!);
    _activeCommand = null;

    notifyListeners(); // 1. Draws vector lines instantly

    // 2. Safe post-frame background command execution
    final targetLayerId = _activeLayerId!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getSnapshotCommandForLayer(targetLayerId).execute(targetLayerId); 
    });

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
    notifyListeners();

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
        _layers = loadedLayersResult.value;
        
        // Safety Fallback: Ensure active cursor assignment handles empty layer bounds gracefully
        _activeLayerId = _layers.isNotEmpty ? _layers.last.id : null;

        // 3. Purge operational runtime memory tracks before reconstruction
        _cachedLayerHistories.clear();
        _drawHistory.clear();
        _redoHistory.clear();
        _layerSnapshots.clear();

        // 4. Reconstruct structural histories layer by layer
        for (var layer in _layers) {
          // Unpack persistent array models safely into fast memory buckets
          _cachedLayerHistories[layer.id] = List<DrawCommand>.from(
            layer.layerDrawHistory,
          );
          
          // Seed the master global unified command history track 
          _drawHistory.addAll(layer.layerDrawHistory);
        }

        // 5. Commit all structural changes to the widget tree to force an initial render cycle
        notifyListeners();

        // 6. Capture separate thumbnails for EACH layer after they finish rendering to screen
        for (var layer in _layers) {
          final currentLoopId = layer.id;
          
              final targetLayerId = currentLoopId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
        getSnapshotCommandForLayer(targetLayerId).execute(targetLayerId); 
    });
        }

      case Error():
        return Result.error(loadedLayersResult.error);
    }
    
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
      );
    }

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
        _activeLayerId = addResult.value.id; // Focus the cursor onto the added drawing target
        _cachedLayerHistories[addResult.value.id] = []; // Deploy a clean caching bucket map track
        
        await _canvasDataRepository.modifyCanvasData(
          _currentCanvas!.copyWith(layerIds: [..._currentCanvas!.layerIds, addResult.value.id])
        );
        
        // 1. Inflate the new layer's widget tree layout onto the active viewport first
        notifyListeners();

        // 2. Safely query the newly drawn widget bounds on the next post-frame slot
        final targetLayerId = _activeLayerId!;
        WidgetsBinding.instance.addPostFrameCallback((_) {

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

 Future<Result<void>> _getLayerSnapshot(String layerId) async {
    try {
      final GlobalKey layerKey = getGlobalLayerKey(layerId);

      // The command handles the 'running' state, we just execute the heavy lift
      final snapshot = await canvasToImageProcessor.processLayerSnapshotInBackground(
        layerKey: layerKey, 
        transparency: 1.0, 
      );
      
      if (snapshot == null) {
        return Result.error(Exception('Snapshot data returned null from processor.'));
      }

      // Update your cache map array directly
      _layerSnapshots[layerId] = snapshot;
      log.d('Added Layer: $layerId snapshot to _layerSnapshots, there are now ${_layerSnapshots.length} snapshots in total');
      // Notify so any UI components reading 'layerSnapshots' know data changed
      notifyListeners(); 
      
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to generate layer snapshot: $e'));
    }
  }




  GlobalKey getGlobalLayerKey(String layerId){
    GlobalKey key = _layerGlobalKeys.putIfAbsent(layerId, () => GlobalKey());
    
    return key;
  }

}
