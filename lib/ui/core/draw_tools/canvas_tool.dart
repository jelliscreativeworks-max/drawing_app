import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'dart:ui';
import 'package:flutter/gestures.dart';

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

  /// Factory helper that automatically unrolls clean unified spaces instantly
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
  
  /// Exposes the precise physical movement vector delta directly to your tool instances
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

    void onToolStart(ToolStartFrame toolFrame);
    void onToolUpdate(ToolUpdateFrame toolFrame);
    CanvasCommand? onToolEnd();

    
}