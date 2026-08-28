import 'dart:typed_data';

import 'package:drawing_app/domain/models/draw_layer/draw_layer.dart';
import 'package:drawing_app/utils/result.dart';
import 'package:flutter/material.dart';

abstract class LayerDataRepository {
  Future<Result<void>> deleteLayer(String id);
  Future<Result<void>> deleteAllLayersInProject(String projectId);
  Future<Result<void>> saveDirtyLayers(List<DrawLayer> layers);
  Future<Result<DrawLayer>> getLayer(String id);
  Future<Result<List<DrawLayer>>> getAllCanvasLayers(String projectId);
  Future<Result<DrawLayer>> addLayer(DrawLayer newLayer);
  Future<Result<DrawLayer>> modifyLayer(DrawLayer modifiedLayer);

}