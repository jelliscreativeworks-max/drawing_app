import 'dart:ui';
import 'package:drawing_app/domain/models/tool_input_data/tool_input_data.dart';
import 'package:flutter/material.dart';
import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/commands/draw_command.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:drawing_app/utils/extensions.dart';

class PathTool extends DrawTool implements StrokeToolType, FillToolType {
  Paint _strokePaint;
  Paint _fillPaint;
  bool _renderFill;
  bool _renderStroke;


  bool _isDrawing = false;
  bool _isPausedForPan = false; // Protects open paths during viewport scrolling
  PathData? _activePath;
  int _pointCount = 0; // Tracks your stable, click-down anchor limits cleanly

           final previewPaint = Paint()
        ..style = PaintingStyle.fill;
        

  PathTool({
    required super.toolName,
    required super.toolIcon,
    required Paint defaultStrokePaint,
    required Paint defaultFillPaint,
    required bool renderFill,
    required bool renderStroke,
  })  : _strokePaint = defaultStrokePaint,
        _fillPaint = defaultFillPaint,
        _renderFill = renderFill,
        _renderStroke = renderStroke;

  @override bool get renderFill => _renderFill;
  @override bool get renderStroke => _renderStroke;
  @override Paint get fillPaint => _fillPaint;
  @override Paint get strokePaint => _strokePaint;

  @override void updateFillPaint(Paint updatedFillPaint) => _fillPaint = updatedFillPaint;
  @override void updateStrokePaint(Paint updatedStrokePaint) => _strokePaint = updatedStrokePaint;

  @override
  DrawData? get activePreview => _activePath;

  @override bool get isActive => _isDrawing;

  bool shouldClosePath(PathData data) {
    if (data.points.length < 4) return false;
    final distance = (data.points.first - data.points.last).distance;
    return distance <= data.strokePaint.strokeWidth;
  }

  bool withinEnd(PathData data) {
    final points = data.points;
    if (points.length < 2) return false;
    final distance = (points[points.length - 1] - points[points.length - 2]).distance;
    return distance <= data.strokePaint.strokeWidth;
  }

  void _resetDrawingState() {
    _activePath = null;
    _pointCount = 0;
    _isDrawing = false;
    _isPausedForPan = false;
  }

  @override void onPanOverrideStart() => _isPausedForPan = true;
  @override void onPanOverrideEnd() => _isPausedForPan = false;
  @override void cancel() => _resetDrawingState();

  @override
  void onToolStart(ToolStartInput toolInputStart, String layerId, int strokeIndex) {
    if (_isPausedForPan) return;

    if (_isDrawing && _activePath != null) {
      _activePath = _activePath!.copyWith(
        points: [..._activePath!.points, toolInputStart.worldPoint],
      );
    } else {
      // First click down: Initialize a fresh new path model sequence
      _isDrawing = true;
      _activePath = PathData(
        layerId: layerId,
        index: strokeIndex,
        id: uuid.v4(),
        strokePaint: strokePaint,
        fillPaint: fillPaint,
        renderFill: _renderFill,
        renderStroke: _renderStroke,
        points: [toolInputStart.worldPoint],
      );
    }
    _pointCount++; // Advance your stable anchor window boundary forward 1 notch
  }

  @override
  void onToolUpdate(ToolUpdateInput toolUpdateInput, String layerId) {
    if (!_isDrawing || _activePath == null || _isPausedForPan) return;
    final points = [..._activePath!.points.take(_pointCount), toolUpdateInput.worldPoint];
    _activePath = _activePath!.copyWith(points: points);
  }

  @override
  CanvasCommand? onToolEnd() {
    // Retain coordinates safely in memory if a temporal pinch-to-zoom override finishes
    if (_isPausedForPan) return null; 

    PathData? path = _activePath;
    if (!_isDrawing || path == null) return null;

    // Should be impossible as the moment you tap down it actually creates two points
    final pPoints = path.points;
    if (pPoints.length < 2) {
      _resetDrawingState();
      return null;
    }

    // 3. Tap on last point to complete or cancel path if 3 or less points are visible (includes preview)
    if (withinEnd(path)) {
      if (pPoints.length <= 3) {
        _resetDrawingState();
        return null;
      }
        path = _activePath!.copyWith(points: _activePath!.points.take(_pointCount).toList());
      _resetDrawingState();
      return DrawCommand(drawData: path);
    }

    // 4. Clicking over start node to finalize a closed polygon shape
    if (shouldClosePath(path)) {
      final completedPath = path.copyWith(
        points: pPoints.replaceAt(pPoints.length - 1, pPoints.first),
      );
      _resetDrawingState();
      return DrawCommand(drawData: completedPath);
    }

    // Return null to keep path going
    return null;
  }

  @override
  void drawToolOverlay(Canvas canvas, PointerDeviceKind device, double scale) {
    double nodeSize;
    if(device == PointerDeviceKind.touch){
      if(_strokePaint.strokeWidth < 40){
        nodeSize = 40;
      } else{
        nodeSize = _strokePaint.strokeWidth;
      }
    } else{
      nodeSize = _strokePaint.strokeWidth + 10;
    }

    if(_activePath != null){

      if(shouldClosePath(_activePath!)){
        canvas.drawCircle(_activePath!.points.first, nodeSize, previewPaint..color = Colors.green..style = PaintingStyle.fill);
          canvas.drawCircle(_activePath!.points.first, nodeSize, previewPaint..color = Colors.black38..style = PaintingStyle.stroke);
      }
      else if(withinEnd(_activePath!)){
          canvas.drawCircle(_activePath!.points.last, nodeSize, previewPaint..color = _activePath!.points.length > 3 ? Colors.green : Colors.red..style = PaintingStyle.fill);
          canvas.drawCircle(_activePath!.points.last, nodeSize, previewPaint..color = Colors.black38..style = PaintingStyle.stroke);
      } else{
        canvas.drawCircle(_activePath!.points.last, nodeSize, previewPaint..color = Colors.grey..style = PaintingStyle.fill);
        canvas.drawCircle(_activePath!.points.last, nodeSize, previewPaint..color = Colors.black..style = PaintingStyle.stroke);
      }
    }
  }

  @override void toggleRenderFill(bool enabled) => _renderFill = enabled;
  @override void toggleRenderStroke(bool enabled) => _renderStroke = enabled;
}
