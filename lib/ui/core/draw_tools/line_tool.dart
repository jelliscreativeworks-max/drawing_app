

import 'dart:ui';

import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/domain/models/property_data/property_data.dart';
import 'package:drawing_app/domain/models/property_data/property_type.dart';
import 'package:drawing_app/domain/models/tool_input_data/tool_input_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/commands/draw_command.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';

class LineTool extends DrawTool with StrokeTool{
  bool _isDrawing = false;
  LineData? _activeLine;


  LineTool({required super.toolName, required super.toolIcon});

  @override
  List<DrawData> get activePreview => _activeLine != null ? [_activeLine!] : const [];

  @override
  bool get isActive => _isDrawing;

 @override
  CanvasCommand? onToolEnd() {
    if(!_isDrawing || _activeLine == null) return null;

    _isDrawing = false;

    final completedLine = _activeLine;
    _activeLine = null;

    return DrawCommand(drawData: completedLine!);

  }



  @override
  void onToolStart(ToolStartInput toolStartInput, String layerId, int strokeIndex) {
    _isDrawing = true;
    _activeLine = LineData(layerId: layerId, index: strokeIndex, strokePaint: Paint.from(strokePaint), id: uuid.v4(), startPoint: toolStartInput.snappedWorldPoint, endPoint: toolStartInput.snappedWorldPoint, strokeType: strokeTypeOptions);
  }

  @override
  void onToolUpdate(ToolUpdateInput toolUpdateInput, String layerId) {
    if(!_isDrawing) return;

    _activeLine = _activeLine!.copyWith(endPoint: toolUpdateInput.snappedWorldPoint);
  }

    @override
  List<PropertyData> get toolProperties {
    return [
      ...strokeProperties
    ];
  }

  @override
  void updatePropertyStateValue(PropertyId<dynamic> targetId, newValue) {
    if(updateStrokeProperty(targetId, newValue)) return;
  }
  
  }