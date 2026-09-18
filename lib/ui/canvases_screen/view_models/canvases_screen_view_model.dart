import 'package:drawing_app/data/repositories/canvas_data_repository/canvas_data_repository.dart';
import 'package:drawing_app/data/repositories/layer_data_repository/layer_data_repository.dart';
import 'package:drawing_app/domain/models/canvas_data/canvas_data.dart';
import 'package:drawing_app/domain/models/layer_data/layer_data.dart';
import 'package:drawing_app/utils/command.dart';
import 'package:drawing_app/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const Uuid uuid = Uuid();

class CanvasesScreenViewModel extends ChangeNotifier{
  CanvasesScreenViewModel({
    required CanvasDataRepository canvasDataRepository,
    required LayerDataRepository layerDataRepository}) : _canvasDataRepository = canvasDataRepository, _layerDataRepository = layerDataRepository
  {
    loadCanvasesList = Command0(_loadProjects)..execute();
    createNewCanvas = Command2(_createNewCanvas);
  }

  late final Command0 loadCanvasesList;
  late final Command2<void ,String, Size> createNewCanvas;

  final CanvasDataRepository _canvasDataRepository;
  
  final LayerDataRepository _layerDataRepository;

  List<CanvasDataCreated> _canvasDataList = [];

  List<CanvasDataCreated> get canvasDataList => List.unmodifiable(_canvasDataList);

  Future<Result<void>> _loadProjects() async{
    final result = await _canvasDataRepository.getCanvasDataList();

    switch(result){
      case Ok():
        _canvasDataList = result.value;
        return Result.ok(null);
      case Error():
        return Result.error(result.error);
    }
  }

  Future<Result<void>> _createNewCanvas(String name, Size size) async {

    final String initialCanvasId = uuid.v4();
    final String initialLayerId = uuid.v4();

    final templateCanvas = CanvasDataCreated(
      canvasSize: size,
      id: initialCanvasId, 
      name: name,
      layerIds: [initialLayerId], 
    );

        final initialLayer = LayerData(
          id: initialLayerId,
          index: 0,
          name: 'Layer 1',
          canvasId: initialCanvasId,
          isDirty: true, 
          isVisible: true,
          layerDrawHistory: const [],
        );

    Result result = Result.ok(null);
    final createCanvasResult = await _canvasDataRepository.createCanvasData(templateCanvas);
    final layerResult = await _layerDataRepository.saveDirtyLayers([initialLayer]);
    final refreshCanvasList = await _canvasDataRepository.getCanvasDataList();

    if(createCanvasResult is Error) result = createCanvasResult as Error;
    if(layerResult is Error) result = layerResult;
    if(refreshCanvasList is Error) result = refreshCanvasList as Error;
  
    notifyListeners();
    return result;
  }


}