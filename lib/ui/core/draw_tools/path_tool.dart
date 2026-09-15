import 'dart:ui';

import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/commands/draw_command.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:drawing_app/utils/extensions.dart';
import 'package:flutter/material.dart';

class PathTool extends DrawTool {
  PathTool({
    required super.toolName,
    required super.toolIcon,
     super.fillPaint,
     super.strokePaint,
  });

  bool _isDrawing = false;
  DrawData? _activePath;
  int _pointCount = 0;
  PointerDeviceKind _lastDeviceKind = PointerDeviceKind.unknown;

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

  @override
  void draw(Canvas canvas, DrawData drawData) {
    if (drawData.points.isEmpty) return;
    _drawPath(canvas, drawData);
  }

  void _drawPath(Canvas canvas, DrawData data) {
    final points = data.points;

    // 1. Single Point Case (Dot)
    if (points.length == 1) {
      canvas.drawPoints(PointMode.points, points, data.strokeSettings!);
      return;
    }

    // 2. Build the base vector path
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // 3. Render Fill Layer vs Stroke Layer safely
    final isClosed = points.first == points.last;
    if (isClosed) {
      // Create an independent copy to isolate fill & closed stroke geometry
      final closedPath = Path.from(path)..close();
      canvas.drawPath(closedPath, data.fillSettings!);
      canvas.drawPath(closedPath, data.strokeSettings!);
    } else {
      // Keep stroke open during the active drag/draw sequence
      canvas.drawPath(path, data.strokeSettings!);
    }

    double previewSize = _lastDeviceKind == PointerDeviceKind.touch ? 40 : data.strokeSettings!.strokeWidth;
    // 4. Render Active Tool Target Previews (Only on the drawing instance)
    if (data == _activePath) {
      final previewPaint = Paint()
        ..style = PaintingStyle.fill
        ..strokeWidth = data.strokeSettings!.strokeWidth;

      // prioritize loop closing detection over termination detection
      if (shouldClosePath(data)) {
        canvas.drawCircle(points.first, previewSize, previewPaint..color = Colors.green);
      } else if (withinEnd(data)) {
        canvas.drawCircle(
          points[points.length - 2],
          previewSize,
          previewPaint..color = points.length <= 3 ? Colors.red : Colors.green,
        );
      } else {
        canvas.drawCircle(points.last, previewSize, previewPaint..color = Colors.grey);
        canvas.drawCircle(
          points.last,
           previewSize,
          previewPaint
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0,
        );
      }
    }
  }

  @override
  CanvasCommand? onDrawEnd() {
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

  bool shouldClosePath(DrawData data) {
    if (data.points.length < 4) return false;

    final distance = (data.points.first - data.points.last).distance;
    return distance <= data.strokeSettings!.strokeWidth;
  }

  bool withinEnd(DrawData data) {
    final points = data.points;
    if (points.length < 2) return false;

    // Direct lookback index rather than copying/reversing arrays in memory
    final distance =
        (points[points.length - 1] - points[points.length - 2]).distance;
    return distance <= data.strokeSettings!.strokeWidth;
  }

  void _resetDrawingState() {
    _activePath = null;
    _pointCount = 0;
    _isDrawing = false;
  }

  @override
  void onDrawStart({
    required PointerDeviceKind deviceKind,
    required Offset startPoint,
    required String layerId,
    required int nextStrokeIndex,
    required Color color,
    required double strokeWidth,
  }) {
    _lastDeviceKind = deviceKind;
    if (_isDrawing && _activePath != null) {
      _activePath = _activePath!.copyWith(
        points: [..._activePath!.points, startPoint],
      );
    } else {
      _isDrawing = true;
      _activePath = DrawData(
        layerId: layerId,
        toolName: toolName,
        index: nextStrokeIndex,
        id: uuid.v4(),
        strokeSettings: strokePaint,
        fillSettings: fillPaint,
        points: [startPoint],
      );
    }
    _pointCount++;
  }

  @override
  void onUpdateTool({
    required Offset newPoint,
    required double gestureScale,
    required PointerDeviceKind deviceKind,
  }) {
    if (_isDrawing) {
      final points = [..._activePath!.points.take(_pointCount), newPoint];
      _activePath = _activePath!.copyWith(points: points);
    }
  }
}
