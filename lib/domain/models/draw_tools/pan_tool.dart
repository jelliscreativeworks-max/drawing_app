import 'dart:ui';

import 'package:drawing_app/domain/models/canvas_command/canvas_command.dart';
import 'package:drawing_app/domain/models/draw_command/draw_command.dart';
import 'package:drawing_app/domain/models/draw_tools/draw_tool.dart';
import 'package:flutter/material.dart';

class PanTool extends DrawTool{
  PanTool({required super.toolName, required super.toolIcon}); 

  @override
  bool get isNavigationTool => true;

  @override
  void draw(Canvas canvas, CanvasCommand drawCommand){}



  @override
  CanvasCommand? onDrawStart({required Offset startPoint, required Paint strokeSettings, required Paint fillSettings, required String layerId, required List<CanvasCommand> drawHistory, required Map<String, List<CanvasCommand>> layerDrawHistory, required ToolMatrixPayload camera}) {
    return null;
  }

  @override
  CanvasCommand? onUpdateTool({required CanvasCommand activeCommand, required Offset newPoint, required List<CanvasCommand> drawHistory, required Map<String, List<CanvasCommand>> layerDrawHistory, required ToolMatrixPayload camera, required int pointerCount, required double gestureScale}) {
  if (pointerCount <= 1) {
      final Offset screenDelta = newPoint - camera.panStartOrigin;
      if (screenDelta == Offset.zero) return null;

      // Translate the camera matrix instance cleanly relative to current uniform magnification scale
      camera.transform = camera.transform.clone()
        ..translate(screenDelta.dx / camera.currentScale, screenDelta.dy / camera.currentScale);
      
      camera.panStartOrigin = newPoint; // Reset touch anchor path
      return null;
    }

    // 2. ROUTE TO COMPREHENSIVE 2-FINGER MULTI-TOUCH PINCH ZOOMING
    final double proposedScale = camera.scaleStart * gestureScale;
    final double clampedScale = proposedScale.clamp(0.2, 5.0);
    
    if ((clampedScale - camera.currentScale).abs() < 1e-6) return null;
    final double scaleMultiplier = clampedScale / camera.currentScale;

    // Mutate the transformation matrix uniformly around the exact starting pinch focal layout anchor
    camera.transform = camera.transform.clone()
      ..translate(camera.focalPointAtStart.dx, camera.focalPointAtStart.dy)
      ..scale(scaleMultiplier, scaleMultiplier)
      ..translate(-camera.focalPointAtStart.dx, -camera.focalPointAtStart.dy);

    // Reposition the pan transformation to keep artwork locked under the dynamic hand focal movement
    final Offset currentScreenPos = MatrixUtils.transformPoint(camera.transform, camera.focalPointAtStart);
    final Offset structuralDelta = newPoint - currentScreenPos;
    
    camera.transform.translate(structuralDelta.dx / camera.currentScale, structuralDelta.dy / camera.currentScale);
    return null;
  }

  @override
  void onDrawEnd({required CanvasCommand? activeCommand, required String layerId, required List<DrawCommand> drawHistory, required List<CanvasCommand> undoHistory, required List<CanvasCommand> redoHistory, required Map<String, List<DrawCommand>> layerDrawHistory, required ToolMatrixPayload camera}){}



}