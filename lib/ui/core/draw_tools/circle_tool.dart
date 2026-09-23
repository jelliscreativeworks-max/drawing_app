import 'dart:ui';
import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/domain/models/tool_input_data/tool_input_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/commands/draw_command.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';

class CircleTool extends DrawTool implements StrokeToolType, FillToolType {
  bool _isDrawing = false;
  CircleData? _circlePreview;

  bool _renderStroke;
  bool _renderFill;

  Paint _strokePaint;
  Paint _fillPaint;

  CircleTool({
    required super.toolName,
    required super.toolIcon,
    required defaultStrokePaint,
    required defaultFillPaint,
    required bool renderStroke,
    required renderFill,
  }) : _strokePaint = defaultStrokePaint,
       _fillPaint = defaultFillPaint,
       _renderFill = renderFill,
       _renderStroke = renderStroke;

  @override
  DrawData? get activePreview => _circlePreview;
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
  void updateStrokePaint(Paint updatedStrokePaint) =>
      _strokePaint = updatedStrokePaint;

  @override
  void onToolStart(ToolStartInput toolStartInput, String layerId, int strokeIndex) {
    _isDrawing = true;
    _circlePreview = CircleData(
      layerId: layerId,
      fillPaint: fillPaint,
      strokePaint: _strokePaint,
      index: strokeIndex,
      id: uuid.v4(),
      center: toolStartInput.worldPoint,
      radius: double.minPositive,
      renderFill: _renderFill,
      renderStroke: _renderFill,
    );
  }

  @override
  void onToolUpdate(ToolUpdateInput toolUpdateInput, String layerId) {
    if (!_isDrawing) return;
    final double radius =
        (toolUpdateInput.points.world - _circlePreview!.center).distance;
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
}
