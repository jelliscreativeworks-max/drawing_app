import 'dart:ui';

import 'package:drawing_app/domain/models/canvas_command/canvas_command.dart';
import 'package:drawing_app/domain/models/draw_command/draw_command.dart';
import 'package:drawing_app/domain/models/draw_tools/draw_tool.dart';
import 'package:drawing_app/domain/models/erase_command/erase_command.dart';

class EraseTool extends DrawTool {
  EraseTool({required super.toolName, required super.toolIcon});

  final Map<int, CanvasCommand> _erasedCommands = {};
  Offset? previousPoint;

  @override
  void draw(Canvas canvas, CanvasCommand drawCommand) {}

  // Adjust eraser thickness: a 25-pixel touch radius = 25 * 25 = 625.0
  final double kEraserRadiusSq = 625.0;

  void _checkEraserCollision(
    Offset prevEraser,
    Offset newEraser,
    List<DrawCommand> history,
  ) {
    for (int i = 0; i < history.length; i++) {
      final points = history[i].points;
      if (points.length < 2) continue; // Skip empty paths

      // Loop through every line segment of the freehand drawing
      for (int j = 0; j < points.length - 1; j++) {
        final p1 = points[j];
        final p2 = points[j + 1];

        // 1. Check if the current eraser position is near this sketch segment
        double distToSketchSeg = distanceToSegment(newEraser, p1, p2);
        if (distToSketchSeg <= kEraserRadiusSq) {
          _erasedCommands.putIfAbsent(i, () => history[i]);
          break; // Instantly stop checking THIS stroke; move to history[i+1]
        }

        // Check if the sketch segment is near the path the eraser traveled
        double distToEraserPath = distanceToSegment(p1, prevEraser, newEraser);
        if (distToEraserPath <= kEraserRadiusSq) {
          _erasedCommands.putIfAbsent(i, () => history[i]);
          break; // Instantly stop checking THIS stroke
        }
      }
    }
  }

  @override
  void onDrawEnd({
    required CanvasCommand? activeCommand,
    required String layerId,
    required List<DrawCommand> drawHistory,
    required List<CanvasCommand> undoHistory,
    required List<CanvasCommand> redoHistory,
    required Map<String, List<DrawCommand>> layerDrawHistory,
    required ToolMatrixPayload camera,
  }) {
    if (activeCommand != null && activeCommand is EraseCommand) {
      activeCommand.addCommand(
        drawHistory: drawHistory,
        undoHistory: undoHistory,
        redoHistory: redoHistory,
      );
      previousPoint = null;
      _erasedCommands.clear();
    }
  }

  @override
  CanvasCommand? onDrawStart({
    required Offset startPoint,
    required Paint strokeSettings,
    required Paint fillSettings,
    required String layerId,
    required List<DrawCommand> drawHistory,
    required Map<String, List<DrawCommand>> layerDrawHistory,
    required ToolMatrixPayload camera,
  }) {
    _erasedCommands.clear();
    previousPoint = startPoint;
    return EraseCommand(
      layerId: layerId,
      toolName: toolName,
      erasedCommands: {},
    );
  }

  @override
  CanvasCommand? onUpdateTool({
    required CanvasCommand activeCommand,
    required Offset newPoint,
    required List<DrawCommand> drawHistory,
    required Map<String, List<DrawCommand>> layerDrawHistory,
    required ToolMatrixPayload camera,
    required int pointerCount,
    required double gestureScale,
  }) {
    if (activeCommand is EraseCommand) {
      final history = layerDrawHistory[activeCommand.layerId]!;

      _checkEraserCollision(previousPoint ?? newPoint, newPoint, history);

      previousPoint = newPoint;

       final updatedCmd = activeCommand.copyWith(
        erasedCommands: Map<int, CanvasCommand>.from(_erasedCommands),
      );
      
      return updatedCmd;
    } else {
      return null;
    }
  }
}
