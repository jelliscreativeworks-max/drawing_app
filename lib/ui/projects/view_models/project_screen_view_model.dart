import 'package:drawing_app/data/repositories/canvas_data_repository/canvas_data_repository.dart';
import 'package:drawing_app/domain/models/canvas_data/canvas_data.dart';
import 'package:drawing_app/utils/command.dart';
import 'package:drawing_app/utils/result.dart';
import 'package:flutter/material.dart';

class ProjectScreenViewModel extends ChangeNotifier{
  ProjectScreenViewModel({required CanvasDataRepository canvasDataRepository}) : _canvasDataRepository = canvasDataRepository
  {
    loadProjectList = Command0(_loadProjects)..execute();
  }

  late final Command0 loadProjectList;

  final CanvasDataRepository _canvasDataRepository;

  List<CanvasData> _canvasDataList = [];

  List<CanvasData> get canvasDataList => List.unmodifiable(_canvasDataList);

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

}