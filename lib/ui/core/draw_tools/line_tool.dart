import 'dart:ui';

import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/commands/draw_command.dart';
import 'package:drawing_app/ui/core/draw_tools/canvas_tool.dart';
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
  DrawData? get activePreview => _activeLine;

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
  void onToolStart(ToolStartFrame toolFrame) {
    _isDrawing = true;
    _activeLine = LineData(layerId: toolFrame.activeLayerId, index: toolFrame.nextStrokeIndex, strokePaint: _strokePaint, id: uuid.v4(), startPoint: toolFrame.initialPoint, endPoint: toolFrame.initialPoint, renderStroke: _renderStroke);
  }

  @override
  void onToolUpdate(ToolUpdateFrame toolFrame) {
    if(!_isDrawing) return;

    _activeLine = _activeLine!.copyWith(endPoint: toolFrame.newestPoint);
  }

  @override
  void updateStrokePaint(Paint updatedStrokePaint) =>  _strokePaint = updatedStrokePaint;

  @override
  bool get renderStroke => _renderStroke;
  
  @override
  void toggleRenderStroke(bool enabled) => _renderStroke = enabled;
  
  }