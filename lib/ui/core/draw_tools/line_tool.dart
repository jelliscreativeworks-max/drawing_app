import 'dart:ui';

import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/domain/models/property_data/property_data.dart';
import 'package:drawing_app/domain/models/tool_input_data/tool_input_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/commands/draw_command.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';

class LineTool extends DrawTool implements StrokeToolType{
  bool _renderStroke;
  bool _isDrawing = false;
  LineData? _activeLine;

  Paint _strokePaint;

  @override
  Paint get strokePaint => _strokePaint;

  LineTool({required super.toolName, required super.toolIcon, required Paint defaultStrokePaint, required bool renderStroke}) : _strokePaint = defaultStrokePaint, _renderStroke = renderStroke;

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
    _activeLine = LineData(layerId: layerId, index: strokeIndex, strokePaint: _strokePaint, id: uuid.v4(), startPoint: toolStartInput.snappedWorldPoint, endPoint: toolStartInput.snappedWorldPoint, renderStroke: _renderStroke);
  }

  @override
  void onToolUpdate(ToolUpdateInput toolUpdateInput, String layerId) {
    if(!_isDrawing) return;

    _activeLine = _activeLine!.copyWith(endPoint: toolUpdateInput.snappedWorldPoint);
  }

  @override
  void updateStrokePaint(Paint updatedStrokePaint) =>  _strokePaint = updatedStrokePaint;

  @override
  bool get renderStroke => _renderStroke;
  
  @override
  void toggleRenderStroke(bool enabled) => _renderStroke = enabled;

    @override
  List<PropertyData> getToolProperties() {
    return [
      PropertyData<double>(
        displayName: 'Stroke Size',
        propertyValue: _strokePaint.strokeWidth,
        onChanged: (strokeWidth) {
          _strokePaint = _strokePaint..strokeWidth = strokeWidth;
        },
      ),
       PropertyData<Color>(
        displayName: 'Stroke Color',
        propertyValue: _strokePaint.color,
        onChanged: (strokeColor) {
          _strokePaint = _strokePaint..color = strokeColor;
        },
      ),
    ];
  }
  
  }