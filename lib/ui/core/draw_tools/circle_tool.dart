import 'dart:ui';
import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/domain/models/property_data/property_data.dart';
import 'package:drawing_app/domain/models/property_data/property_type.dart';
import 'package:drawing_app/domain/models/tool_input_data/tool_input_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/commands/draw_command.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:flutter/material.dart';

class CircleTool extends DrawTool with StrokeTool, FillTool {
  bool _isDrawing = false;
  CircleData? _circlePreview;
  


  CircleTool({
    required super.toolName,
    required super.toolIcon,
    Paint? strokePaintOverride,
    Paint? fillPaintOverride,
    FillTypeOptions? fillTypeOverride,
    StrokeTypeOptions? strokeTypeOverride
  });

  @override
  List<DrawData> get activePreview =>
      _circlePreview != null ? [_circlePreview!] : const [];
  @override
  bool get isActive => _isDrawing;

  @override
  void onToolStart(
    ToolStartInput toolStartInput,
    String layerId,
    int strokeIndex,
  ) {
    _isDrawing = true;
    _circlePreview = CircleData(
      layerId: layerId,
      fillPaint: Paint.from(fillPaint),
      strokePaint: Paint.from(strokePaint),
      index: strokeIndex,
      id: uuid.v4(),
      center: toolStartInput.snappedWorldPoint,
      radius: double.minPositive,
      strokeType: strokeTypeOptions,
      fillType: fillTypeOptions
    );
  }

  @override
  void onToolUpdate(ToolUpdateInput toolUpdateInput, String layerId) {
    if (!_isDrawing) return;
    final double radius =
        (toolUpdateInput.snappedPoints.world - _circlePreview!.center).distance;
    _circlePreview = _circlePreview!.copyWith(radius: radius);
  }

  @override
  CanvasCommand? onToolEnd() {
    if (!_isDrawing || _circlePreview == null) return null;

    _isDrawing = false;

    final completedRect = _circlePreview;
    _circlePreview = null;

    return DrawCommand(drawData: completedRect!);
  }

  @override
  List<PropertyData> get toolProperties{
    return [
      ...strokeProperties,
      ...fillProperties
    ];
  }

  @override
  void updatePropertyStateValue(PropertyId<dynamic> targetId, newValue) {
    if(updateStrokeProperty(targetId, newValue)) return;
    if(updateFillProperties(targetId, newValue)) return;
  }


}



/// Circle properties:
/// Stroke color
/// Stroke enabled
/// Stroke width
/// Fill color
/// Fill enabled
