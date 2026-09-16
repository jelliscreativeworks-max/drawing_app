import 'dart:ui';

import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/commands/draw_command.dart';
import 'package:drawing_app/ui/core/draw_tools/canvas_tool.dart';
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
  void onToolStart(ToolStartFrame toolFrame) {
    _isDrawing = true;
    _activeRect = RectData(layerId: toolFrame.activeLayerId, index: toolFrame.nextStrokeIndex, fillPaint: fillPaint, strokePaint: strokePaint, id: uuid.v4(), topLeft: toolFrame.initialPoint, botRight: toolFrame.initialPoint, renderFill: _renderFill, renderStroke: _renderStroke);
  }

  @override
  void onToolUpdate(ToolUpdateFrame toolFrame) {
    if(!_isDrawing) return;
    _activeRect = _activeRect!.copyWith(botRight: toolFrame.newestPoint);
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
