import 'package:drawing_app/domain/models/canvas_data/canvas_data.dart';
import 'package:drawing_app/utils/result.dart';

abstract class CanvasDataRepository {
  Future<Result<CanvasDataCreated>> modifyCanvasData(CanvasDataCreated canvasData);
  Future<Result<void>> delete(String id);
  Future<Result<List<CanvasDataCreated>>> getCanvasDataList();
  Future<Result<CanvasDataCreated>> getCanvasData(String id);
  Future<Result<CanvasDataCreated>> createCanvasData(CanvasDataCreated canvasData);

}