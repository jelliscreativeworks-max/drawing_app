import 'package:drawing_app/domain/models/tool_input_data/tool_input_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:flutter/material.dart';

import 'dart:ui';

typedef CanvasCoordinateSpace = ({Offset screen, Offset world}); 


class ToolStartFrame {
  final PointerDeviceKind pointerDeviceKind;
  final CanvasCoordinateSpace points;
  final String activeLayerId;
  final int nextStrokeIndex;

  Offset get screenPoint => points.screen;
  Offset get worldPoint => points.world;

  ToolStartFrame({
    required this.pointerDeviceKind,
    required this.points,
    required this.activeLayerId,
    required this.nextStrokeIndex,
  });

  factory ToolStartFrame.compute({
    required PointerDeviceKind deviceKind,
    required Offset rawScreenPoint,
    required String layerId,
    required int strokeIndex,
    required Offset Function(Offset) screenToWorldConverter,
  }) {
    return ToolStartFrame(
      pointerDeviceKind: deviceKind,
      activeLayerId: layerId,
      nextStrokeIndex: strokeIndex,
      points: (screen: rawScreenPoint, world: screenToWorldConverter(rawScreenPoint)),
    );
  }
}

class ToolUpdateFrame {
  final PointerDeviceKind pointerDeviceKind;
  final double rawScale;
  final CanvasCoordinateSpace points;
  final String activeLayerId;
  

  final Offset delta; 

  Offset get screenPoint => points.screen;
  Offset get worldPoint => points.world;

  ToolUpdateFrame({
    required this.pointerDeviceKind,
    required this.rawScale,
    required this.points,
    required this.activeLayerId,
    required this.delta,
  });

  /// Chains tracking updates from the prior frame execution matrix safely
  factory ToolUpdateFrame.computeUpdate({
    required PointerDeviceKind deviceKind,
    required Offset currentScreenPoint,
    required double currentScale,
    required String layerId,
    required Offset Function(Offset) screenToWorldConverter,
    required Offset priorScreenPoint,
    Offset? customDelta,
  }) {
    final CanvasCoordinateSpace computedPoints = (
      screen: currentScreenPoint, 
      world: screenToWorldConverter(currentScreenPoint)
    );
    
    // Calculates physical canvas spacing independent of tool logic boundaries
        final Offset computedDelta = customDelta ?? (currentScreenPoint - priorScreenPoint);

    return ToolUpdateFrame(
      pointerDeviceKind: deviceKind,
      rawScale: currentScale,
      points: computedPoints,
      activeLayerId: layerId,
      delta: computedDelta,
    );
  }
}


abstract class CanvasTool {
    final String toolName;
    final Icon toolIcon;
    bool get isActive;

    CanvasTool({required this.toolName, required this.toolIcon});

    void onToolStart(ToolStartInput toolStartInput, String layerId, int strokeIndex);
    void onToolUpdate(ToolUpdateInput toolUpdateInput, String layerId);
    CanvasCommand? onToolEnd();

    void onPanOverrideStart(){}
    void onPanOverrideEnd(){}

    void drawToolOverlay(Canvas canvas, PointerDeviceKind device, double scale){}

    void cancel(){}
    
}