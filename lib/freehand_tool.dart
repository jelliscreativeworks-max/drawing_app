import 'dart:ui';
import 'package:drawing_app/draw_command.dart';
import 'package:drawing_app/draw_tool.dart';

class FreehandTool extends DrawTool {
  const FreehandTool({required super.toolName, required super.toolIcon});

  @override
  void draw(Canvas canvas, DrawCommand drawCommand) {
    if (drawCommand.points.isEmpty) return;
  
    _drawIndividualLine(canvas, drawCommand.points, drawCommand.strokeSettings);
  }

  void _drawIndividualLine(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.length == 1) {
      canvas.drawPoints(PointMode.points, points, paint);
    } else {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  DrawCommand onDrawStart(Offset startPoint, Paint strokeSettings, Paint fillSettings) {
    // Generate a fresh Freezed data block instantly
    return DrawCommand.data(
      toolName: toolName,
      points: [startPoint],
      strokeSettings: strokeSettings,
      fillSettings: fillSettings,
    );
  }

  @override
  DrawCommand onUpdateTool(DrawCommand currentCommand, Offset newPoint) {
    // Return a cleanly copied Freezed snapshot
    return currentCommand.copyWith(
      points: [...currentCommand.points, newPoint],
    );
  }

  @override
  DrawCommand onDrawEnd(DrawCommand currentCommand) {
    return currentCommand; // Freehand doesn't need end-of-stroke processing adjustments
  }
}
