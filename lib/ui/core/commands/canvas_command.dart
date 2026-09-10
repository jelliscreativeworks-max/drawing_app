import 'dart:ui';

import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/domain/models/layer_data/layer_data.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';



abstract class CanvasCommand {
  final String layerId;
  final int index;

  CanvasCommand({required this.layerId, required this.index});

  void execute(CanvasStateContext context);

  void undo(CanvasStateContext context);
}

class CanvasStateContext{
  final List<LayerData> layerData;
  final List<DrawData> globalDrawHistory;

  CanvasStateContext({required this.layerData, required this.globalDrawHistory});
}