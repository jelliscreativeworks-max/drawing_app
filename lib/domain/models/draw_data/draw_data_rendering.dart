  part of 'draw_data.dart';
  
  
  void _drawPath(Canvas canvas, PathData data) {
    final points = data.points;

    // 1. Single Point Case (Dot)
    if (points.length == 1) {
      canvas.drawPoints(PointMode.points, points, data.strokePaint);
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
      canvas.drawPath(closedPath, data.fillPaint);
      canvas.drawPath(closedPath, data.strokePaint);
    } else {
      // Keep stroke open during the active drag/draw sequence
      canvas.drawPath(path, data.strokePaint);
    }
// TODO: Preview System Needs to Know Active State/Device Info
    // // double previewSize = _lastDeviceKind == PointerDeviceKind.touch ? 40 : data.strokeSettings!.strokeWidth;
    // // 4. Render Active Tool Target Previews (Only on the drawing instance)
    // if (data == _activePath) {
    //   final previewPaint = Paint()
    //     ..style = PaintingStyle.fill
    //     ..strokeWidth = data.strokeSettings!.strokeWidth;

    //   // prioritize loop closing detection over termination detection
    //   if (shouldClosePath(data)) {
    //     canvas.drawCircle(points.first, previewSize, previewPaint..color = Colors.green);
    //   } else if (withinEnd(data)) {
    //     canvas.drawCircle(
    //       points[points.length - 2],
    //       previewSize,
    //       previewPaint..color = points.length <= 3 ? Colors.red : Colors.green,
    //     );
    //   } else {
    //     canvas.drawCircle(points.last, previewSize, previewPaint..color = Colors.grey);
    //     canvas.drawCircle(
    //       points.last,
    //        previewSize,
    //       previewPaint
    //         ..color = Colors.black
    //         ..style = PaintingStyle.stroke
    //         ..strokeWidth = 0,
    //     );
    //   }
    // }
  }

  void _drawLine(Canvas canvas, LineData data){
    canvas.drawLine(data.startPoint, data.endPoint, data.strokePaint);
  }

  void _drawFreehand(Canvas canvas, FreehandData data) {
    if (data.points.length == 1) {
      canvas.drawPoints(PointMode.points, data.points, data.strokePaint);
    } else {
      final path = Path()..moveTo(data.points.first.dx, data.points.first.dy);
      for (int i = 1; i < data.points.length; i++) {
        path.lineTo(data.points[i].dx, data.points[i].dy);
      }
      canvas.drawPath(path, data.strokePaint);
    }
  }

  void _drawCircle(Canvas canvas, CircleData data){
      if(data.renderFill){
        canvas.drawCircle(data.center, data.radius, data.fillPaint);
      }

      if(data.renderStroke){
         canvas.drawCircle(data.center, data.radius, data.fillPaint);
      }
  }

    void _drawRectangle(Canvas canvas, RectData data){
    final Rect rect = Rect.fromPoints(data.topLeft, data.botRight);
    if(data.renderStroke) {canvas.drawRect(rect, data.strokePaint);}
    if(data.renderFill){ canvas.drawRect(rect, data.fillPaint);}
    
  }
