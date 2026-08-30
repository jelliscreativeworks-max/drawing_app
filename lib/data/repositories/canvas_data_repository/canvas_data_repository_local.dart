import 'package:drawing_app/data/repositories/canvas_data_repository/canvas_data_repository.dart';
import 'package:drawing_app/data/services/local_data_service.dart';
import 'package:drawing_app/domain/models/canvas/canvas_data.dart';
import 'package:drawing_app/utils/result.dart';
import 'package:uuid/uuid.dart';

const Uuid uuid = Uuid();

class CanvasDataRepositoryLocal extends CanvasDataRepository{
  CanvasDataRepositoryLocal({required LocalDataService localDataService}) : _localDataService = localDataService;

  final LocalDataService _localDataService;
  final _canvasDataList = List<CanvasData>.empty(growable: true);
  bool _loaded = false;

    Future<Result<void>> _ensureLoaded() async {
    if (_loaded) return Result.ok(null);
    final loadResult = await getCanvasDataList();
    if (loadResult is Error) {
      return Result.error((loadResult as Error).error);
    }
    return Result.ok(null);
  }

  @override
  Future<Result<CanvasData>> createCanvasData(CanvasData data) async {
    final loadCheck = await _ensureLoaded();
    if (loadCheck is Error) return Result.error((loadCheck).error);

    if(data.name.isEmpty){
      return Result.error(Exception('Name must not be empty'));
    }

  try{
    CanvasData newData = data.copyWith(id: uuid.v4());
    _canvasDataList.add(newData);
    final saveResult = await _saveCanvasData(newData);
    switch(saveResult){
      case Ok():
        return Result.ok(newData);
      case Error():
        return Result.error(saveResult.error);
    
  }
  } catch(e){
      return Result.error(Exception('Failed to create new Canvas Data: $e'));
  }
  }

  @override
  Future<Result<List<CanvasData>>> getCanvasDataList() async {
    if(!_loaded){
      try{
        List<CanvasData> list = await _localDataService.loadCanvasDataList();
        _canvasDataList.clear();
        _canvasDataList.addAll(list);
        _loaded = true;
        return Result.ok(_canvasDataList);
      } catch (e){
        return Result.error(Exception('Failed to load canvas data with exception: $e'));
      }
    }
    return Result.ok(_canvasDataList);
  }

  @override
  Future<Result<CanvasData>> getCanvasData(String id) async {
    final loadCheck = await _ensureLoaded();
    if (loadCheck is Error) return Result.error((loadCheck).error);

    final canvasData = _canvasDataList.where((canvasData) => canvasData.id == id).firstOrNull;
    if(canvasData == null){
      return Result.error(Exception('Canvas data not found with id: $id'));
    } 

    return Result.ok(canvasData);
  }

  Future<Result<void>> _saveCanvasData(CanvasData data) async{
    final loadCheck = await _ensureLoaded();
    if (loadCheck is Error) return Result.error((loadCheck).error);


    try{
      await _localDataService.saveCanvasData(data);
      return Result.ok(null);
    } catch (e){
      return Result.error(Exception("Failed to save CanvasData to disk: $e"));
    }
    
  }

  @override
  Future<Result<void>> delete(String id) async {
    if(!_loaded){
      final loadResult = await getCanvasDataList();
      switch(loadResult){
        case Ok():;
        case Error():
          return Result.error(loadResult.error);
      }
    }
    try{
      
      int index = _canvasDataList.indexWhere((canvasData) => canvasData.id == id);
      if(index == -1) return Result.error(Exception('No Canvas Data found with id $id'));
      await _localDataService.deleteCanvas(id);
      _canvasDataList.removeAt(index);
      
      return Result.ok(null);
    } catch(e){
      return Result.error(Exception('Failed to delete canvasData with id $id: $e'));
    }
  }

  @override
  Future<Result<CanvasData>> modifyCanvasData(CanvasData canvasData) async {
    if(!_loaded){
      final loadResult = await getCanvasDataList();
      switch (loadResult){
        case Ok():;
        case Error():
        return Result.error(loadResult.error);
      }
    }

    try{
      int index = _canvasDataList.indexWhere((data) => data.id == canvasData.id);

      _canvasDataList[index] = canvasData;
      final saveResult = await _saveCanvasData(canvasData);

      switch(saveResult){
        case Ok():
          return Result.ok(canvasData);
        case Error():
          return Result.error(saveResult.error);
      } 
    } catch (e){
        return Result.error(Exception('Failed to modify canvasData: $e'));
    }
  }
}