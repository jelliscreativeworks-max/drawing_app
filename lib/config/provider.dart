import 'package:drawing_app/data/repositories/canvas_data_repository/canvas_data_repository.dart';
import 'package:drawing_app/data/repositories/canvas_data_repository/canvas_data_repository_local.dart';
import 'package:drawing_app/data/repositories/layer_data_repository/layer_data_repository.dart';
import 'package:drawing_app/data/repositories/layer_data_repository/layer_data_repository_local.dart';
import 'package:drawing_app/data/services/local_data_service.dart';
import 'package:drawing_app/domain/models/draw_command/draw_command.dart';
import 'package:drawing_app/domain/models/draw_layer/draw_layer.dart';
import 'package:drawing_app/painter_controller.dart';
import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:uuid/uuid.dart';


List<SingleChildWidget> get providersLocal {
  return [
    Provider<LocalDataService>(
      create: (_) => LocalDataService(),
    ),

    Provider<LayerDataRepository>(
      create: (context) => LayerDataRepositoryLocal(
        localDataService: context.read<LocalDataService>(),
      ),
    ),

    Provider<CanvasDataRepository>(
      create: (context) => CanvasDataRepositoryLocal(
        localDataService: context.read<LocalDataService>(),
      ),
    ),
  ];
}
