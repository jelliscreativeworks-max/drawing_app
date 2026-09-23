import 'dart:ui';

import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/domain/models/tool_input_data/tool_input_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/commands/draw_command.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';


class RectangleTool extends DrawTool implements StrokeToolType, FillToolType {
  Paint _strokePaint;
  Paint _fillPaint;

  bool _renderStroke;
  bool _renderFill;

  bool _isDrawing = false;
  RectData? _activeRect;

  RectangleTool({required super.toolName, required super.toolIcon, required Paint defaultStrokePaint, required Paint defaultFillPaint, required bool renderStroke, required bool renderFill}) : _renderFill = renderFill, _renderStroke = renderStroke, _fillPaint = defaultFillPaint, _strokePaint = defaultStrokePaint;

  @override
  DrawData? get activePreview => _activeRect;
  @override
  bool get isActive => _isDrawing;
  @override
  Paint get fillPaint => _fillPaint;
    @override
  bool get renderFill => _renderFill;
  @override
  bool get renderStroke => _renderStroke;
  @override
  Paint get strokePaint => _strokePaint;

  @override
  void toggleRenderFill(bool enabled) => _renderFill = enabled;
  @override
  void toggleRenderStroke(bool enabled) => _renderStroke = enabled;
  @override
  void updateFillPaint(Paint updatedFillPaint) => _fillPaint = updatedFillPaint;
  @override
  void updateStrokePaint(Paint updatedStrokePaint) => _strokePaint = strokePaint;

  @override
  void onToolStart(ToolStartInput toolStartInput, String layerId, int strokeIndex) {
    _isDrawing = true;
    _activeRect = RectData(layerId: layerId, index: strokeIndex, fillPaint: fillPaint, strokePaint: strokePaint, id: uuid.v4(), topLeft: toolStartInput.worldPoint, botRight: toolStartInput.worldPoint, renderFill: _renderFill, renderStroke: _renderStroke);
  }

  @override
  void onToolUpdate(ToolUpdateInput toolUpdateInput, String layerId) {
    if(!_isDrawing) return;
    _activeRect = _activeRect!.copyWith(botRight: toolUpdateInput.worldPoint);
  }

  @override
  CanvasCommand? onToolEnd() {
    if(!_isDrawing || _activeRect == null) return null;

    _isDrawing = false;

    final completedRect = _activeRect;
    _activeRect = null;

    return DrawCommand(drawData: completedRect!);
  }
}
