import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/draw_tools/canvas_tool.dart';
import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';

const Uuid uuid = Uuid();
abstract class DrawTool extends CanvasTool{

  DrawTool({required super.toolName, required super.toolIcon});

  DrawData? get activePreview;

}

abstract class StrokeToolType{
  Paint get strokePaint;
  bool get renderStroke;

  void updateStrokePaint(Paint updatedStrokePaint);

  void toggleRenderStroke(bool enabled);
}

abstract class FillToolType{
  Paint get fillPaint;
  bool get renderFill;

  void updateFillPaint(Paint updatedFillPaint);
  void toggleRenderFill(bool enabled);
}

