

import 'package:drawing_app/domain/models/layer_data/layer_data.dart';
import 'package:drawing_app/utils/result.dart';

abstract class LayerDataRepository {
  Future<Result<void>> deleteLayer(String id);
  Future<Result<void>> deleteAllLayersInProject(String projectId);
  Future<Result<void>> saveDirtyLayers(List<LayerData> layers);
  Future<Result<LayerData>> getLayer(String id);
  Future<Result<List<LayerData>>> getAllCanvasLayers(String projectId);
  Future<Result<LayerData>> addLayer(LayerData newLayer);
  // Future<Result<DrawLayer>> modifyLayer(DrawLayer modifiedLayer);

}