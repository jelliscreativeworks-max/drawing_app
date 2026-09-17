import 'dart:ui';

import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/commands/draw_command.dart';
import 'package:drawing_app/ui/core/draw_tools/canvas_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:drawing_app/utils/extensions.dart';

import 'package:flutter/material.dart';

class PathTool extends DrawTool implements StrokeToolType, FillToolType{
  Paint _strokePaint;
  Paint _fillPaint;

  bool _renderFill;
  bool _renderStroke;


  PathTool({
    required super.toolName,
    required super.toolIcon,
    required Paint defaultStrokePaint,
    required Paint defaultFillPaint,
    required bool renderFill,
    required bool renderStroke
  }) : _strokePaint = defaultStrokePaint, _fillPaint = defaultFillPaint, _renderFill = renderFill, _renderStroke = renderStroke;

  
  @override
  bool get renderFill => _renderFill;
  @override
  bool get renderStroke => _renderStroke;
  @override
  Paint get fillPaint => _fillPaint;
    @override
  Paint get strokePaint => _strokePaint;

  @override
  void updateFillPaint(Paint updatedFillPaint) => _fillPaint = updatedFillPaint;

  @override
  void updateStrokePaint(Paint updatedStrokePaint) => _strokePaint = strokePaint;

  bool _isDrawing = false;
  PathData? _activePath;
  int _pointCount = 0;

  @override
  DrawData? get activePreview => _activePath;


  // double get nodeDisplaySize{
  //   if(_lastDeviceKind == PointerDeviceKind.touch){
  //     if(strokePaint!.strokeWidth < 40) return 40;
      
  //     return strokePaint!.strokeWidth + 20;
  //   } else{
  //     return strokePaint!.strokeWidth;
  //   }
  // }

  //   double get nodeHitSize{
  //   if(_lastDeviceKind == PointerDeviceKind.touch){
  //     if(strokePaint!.strokeWidth < 10) return 10;
      
  //     return strokePaint!.strokeWidth + 10;
  //   } else{
  //     return strokePaint!.strokeWidth;
  //   }
  // }

  @override
  bool get isActive => _isDrawing;


  bool shouldClosePath(PathData data) {
    if (data.points.length < 4) return false;

    final distance = (data.points.first - data.points.last).distance;
    return distance <= data.strokePaint.strokeWidth;
  }

  bool withinEnd(PathData data) {
    final points = data.points;
    if (points.length < 2) return false;

    // Direct lookback index rather than copying/reversing arrays in memory
    final distance =
        (points[points.length - 1] - points[points.length - 2]).distance;
    return distance <= data.strokePaint.strokeWidth;
  }

  void _resetDrawingState() {
    _activePath = null;
    _pointCount = 0;
    _isDrawing = false;
  }

    @override
  void onToolStart(ToolStartFrame toolFrame) {
    if(_isDrawing){ 
      _activePath = _activePath!.copyWith(points: [..._activePath!.points, toolFrame.worldPoint]);
    } else{
      _isDrawing = true;
      _activePath = PathData(layerId: toolFrame.activeLayerId, index: toolFrame.nextStrokeIndex, id: uuid.v4(), strokePaint: strokePaint, fillPaint: fillPaint, renderFill: _renderFill, renderStroke: _renderStroke, points: [toolFrame.worldPoint]);
    }
    _pointCount++;
  }


  @override
  void onToolUpdate(ToolUpdateFrame toolFrame) {
    if(_isDrawing){
      final points = [..._activePath!.points.take(_pointCount), toolFrame.worldPoint];
      _activePath = _activePath!.copyWith(points: points);
    }
  }

  @override
  CanvasCommand? onToolEnd() {
    final path = _activePath;
    if (!_isDrawing || path == null) return null;

    final points = path.points;
    if (points.length < 2) {
      _resetDrawingState();
      return null;
    }

    if (withinEnd(path)) {
      if (points.length <= 3) {
        _resetDrawingState();
        return null;
      }

      // Complete open path
      _resetDrawingState();
      return DrawCommand(drawData: path);
    }

    if (shouldClosePath(path)) {
      // Complete and return closed path snapped perfectly to the start
      final completedPath = path.copyWith(
        points: points.replaceAt(points.length - 1, points.first),
      );

      _resetDrawingState();
      return DrawCommand(drawData: completedPath);
    }

    return null;
  }

  @override
  void toggleRenderFill(bool enabled) => _renderFill = enabled;

  @override
  void toggleRenderStroke(bool enabled) => _renderStroke = enabled;

}
