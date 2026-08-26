import 'package:drawing_app/domain/models/canvas/canvas_data.dart';
import 'package:drawing_app/utils/result.dart';

abstract class CanvasDataRepository {
  Future<Result<CanvasData>> modifyCanvasData(CanvasData canvasData);
  Future<Result<void>> delete(String id);
  Future<Result<List<CanvasData>>> getCanvasDataList();
  Future<Result<CanvasData>> getCanvasData(String id);
  Future<Result<CanvasData>> createCanvasData(CanvasData canvasData);

}