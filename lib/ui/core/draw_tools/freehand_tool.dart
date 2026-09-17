import 'dart:ui';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/commands/draw_command.dart';
import 'package:drawing_app/ui/core/draw_tools/canvas_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';

class FreehandTool extends DrawTool implements StrokeToolType {
  bool _renderStroke;
  FreehandData? _activeStroke;
  bool _isDrawing = false;

  Paint _strokePaint;

  FreehandTool({
    required super.toolName,
    required super.toolIcon,
    required Paint defaultStrokePaint,
    required bool renderStroke,
  }) : _strokePaint = defaultStrokePaint,
       _renderStroke = renderStroke;

  @override
  bool get isActive => _isDrawing;
  @override
  DrawData? get activePreview => _activeStroke;
  @override
  bool get renderStroke => _renderStroke;
  @override
  Paint get strokePaint => _strokePaint;

  @override
  void updateStrokePaint(Paint updatedStrokePaint) =>
      _strokePaint = updatedStrokePaint;
  @override
  void toggleRenderStroke(bool enabled) => _renderStroke = enabled;

  @override
  void onToolStart(ToolStartFrame toolFrame) {
    _isDrawing = true;
    _activeStroke = FreehandData(
      layerId: toolFrame.activeLayerId,
      strokePaint: _strokePaint,
      id: uuid.v4(),
      index: toolFrame.nextStrokeIndex,
      points: [toolFrame.worldPoint],
      renderStroke: _renderStroke,
    );
  }

  @override
  void onToolUpdate(ToolUpdateFrame toolFrame) {
    if (!_isDrawing) return;
    final updatedPoints = List<Offset>.from(_activeStroke!.points)
      ..add(toolFrame.worldPoint);
    _activeStroke = _activeStroke!.copyWith(points: updatedPoints);
  }

  @override
  CanvasCommand? onToolEnd() {
    if (!_isDrawing || _activeStroke == null) return null;

    _isDrawing = false;

    final completedStroke = _activeStroke;
    _activeStroke = null;

    return DrawCommand(drawData: completedStroke!);
  }
}
