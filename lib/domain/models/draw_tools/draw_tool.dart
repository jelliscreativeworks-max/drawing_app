import 'package:drawing_app/domain/models/draw_command/draw_command.dart';
import 'package:flutter/material.dart';

class ToolMatrixPayload {
  Matrix4 transform;
  Offset panStartOrigin;
  double scaleStart;
  Offset focalPointAtStart;
  final double currentScale;

  ToolMatrixPayload({
    required this.transform,
    required this.panStartOrigin,
    required this.scaleStart,
    required this.focalPointAtStart,
    required this.currentScale,
  });
}

abstract class DrawTool {
  final String toolName;
  final Icon toolIcon;

  const DrawTool({required this.toolName, required this.toolIcon});

  bool get isNavigationTool => false;

  // Pure functions: Accept a command, return a brand new updated Freezed command instance
  DrawCommand? onDrawStart({
    required Offset startPoint,
    required Paint strokeSettings,
    required Paint fillSettings,
    required String layerId,
    required List<DrawCommand> drawHistory,
    required Map<String, List<DrawCommand>> layerDrawHistory,
    required ToolMatrixPayload camera
    }
  );
  DrawCommand? onUpdateTool({
    required DrawCommand activeCommand,
    required Offset newPoint,
    required List<DrawCommand> drawHistory,
    required Map<String,List<DrawCommand>> layerDrawHistory,
    required ToolMatrixPayload camera,
    required int pointerCount,
    required double gestureScale,
  });

  void onDrawEnd({
    required DrawCommand? activeCommand,
    required String layerId,
    required List<DrawCommand> drawHistory,
    required Map<String, List<DrawCommand>> layerDrawHistory,
    required ToolMatrixPayload camera
  });

  // The rendering logic
  void draw(Canvas canvas, DrawCommand drawCommand);
}
