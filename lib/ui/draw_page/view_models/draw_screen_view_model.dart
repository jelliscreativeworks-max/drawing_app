import 'package:drawing_app/data/repositories/canvas_data_repository/canvas_data_repository.dart';
import 'package:drawing_app/data/repositories/layer_data_repository/layer_data_repository.dart';
import 'package:drawing_app/domain/models/canvas/canvas_data.dart';
import 'package:drawing_app/domain/models/draw_layer/draw_layer.dart';
import 'package:drawing_app/utils/command.dart';
import 'package:drawing_app/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const Uuid uuid = Uuid();

class DrawScreenViewModel extends ChangeNotifier{
  DrawScreenViewModel({required LayerDataRepository layerDataRepository, required CanvasDataRepository canvasDataRepository}) : _layerDataRepository = layerDataRepository, _canvasDataRepository = canvasDataRepository{
    loadProject = Command1(_loadProject);
    initProject = Command0(_initializeNewProject);
    createLayer = Command0(_createAndAddLayer);
    saveDirtyProgress = Command0(_saveDirtyProgress);
  }

  final LayerDataRepository _layerDataRepository;
  final CanvasDataRepository _canvasDataRepository;

  late final Command1<void, String> loadProject;
  late final Command0 initProject;
  late final Command0 saveProject;
  late final Command0 createLayer;
  late final Command0 saveDirtyProgress;

  CanvasData? _currentCanvas;
  List<DrawLayer> _layers = [];
  String? _activeLayerId;

  CanvasData? get currentCanvas => _currentCanvas;
  List<DrawLayer> get layers => _layers;
  String? get activeLayerId => _activeLayerId;


  DrawLayer? get activeLayer => 
    _layers.where((l) => l.id == _activeLayerId).firstOrNull;


  Future<Result<void>> _loadProject(String canvasId) async{
    final loadedCanvasResult =  await _canvasDataRepository.getCanvasData(canvasId);

    switch(loadedCanvasResult){
      case Ok():
        _currentCanvas = loadedCanvasResult.value;
      case Error():
        return Result.error(loadedCanvasResult.error);
    }

    final loadedLayersResult = await _layerDataRepository.getAllCanvasLayers(canvasId);

    switch(loadedLayersResult){
      case Ok():
        _layers = loadedLayersResult.value;
        _activeLayerId = _layers.last.id;
      case Error():
        return Result.error(loadedLayersResult.error);
    }

    notifyListeners();
    return Result.ok(null);
  }
  
    Future<Result<void>> _saveDirtyProgress() async {
    if (_currentCanvas == null) return Result.error(Exception('Canvas cannot be empty'));

    // 1. Isolate ONLY layers that have changed
    final dirtyLayers = _layers.where((l) => l.isDirty).toList();
    if (dirtyLayers.isEmpty) return Result.ok(null);

    // 2. Offload the file-write to the repository parallel system
    final result = await _layerDataRepository.saveDirtyLayers(dirtyLayers);

    switch(result){
      case Ok():
        _layers = _layers.map((layer){
          if(layer.isDirty){
            return layer.copyWith(isDirty: false);
          }
          return layer;
        }).toList();
      case Error():
      return Result.error(result.error);
    }

    return Result.ok(null);
  }

   Future<Result<void>> _createAndAddLayer() async {
    if (_currentCanvas == null) return Result.error(Exception('Canvas must not be null when adding new layer'));

    final newLayer = DrawLayer(
      id: uuid.v4(),
      name: 'Layer ${_layers.length}',
      canvasId: _currentCanvas!.id,
      zIndex: _layers.length,
      isDirty: false, // Starts fresh on disk
    );

    final addResult = await _layerDataRepository.addLayer(newLayer);

    switch(addResult){
      case Ok():
        _layers = [..._layers, addResult.value];
      case Error():
        return Result.error(addResult.error);
    }
    return Result.ok(null);
   }
  

  Future<Result<void>> _initializeNewProject() async {

    // 1. Create a default shell model (the repository handles assigning the actual unique Uuid)
    final templateCanvas = CanvasData(
      id: '', // Left blank, repository will overwrite with uuid.v4()
      name: 'Untitled Drawing',
      layerIds: []
    );

    // 2. Persist the parent aggregate file structure via the repository
    final result = await _canvasDataRepository.createCanvasData(templateCanvas);

    switch (result) {
      case Ok<CanvasData>():
        _currentCanvas = result.value;
        
        // 3. Automatically spin up the first default base layer for this new canvas
        final createBaseLayerResult = await _createAndAddLayer(); // Sets up Layer 0 and marks active layer ID
        
        switch(createBaseLayerResult){
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

}