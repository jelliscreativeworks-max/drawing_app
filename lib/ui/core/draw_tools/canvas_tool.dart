import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ToolUpdateFrame {
  final PointerDeviceKind pointerDeviceKind;
  final double gestureScale;
  final Offset newestPoint;
  final String activeLayerId;


  ToolUpdateFrame({required this.pointerDeviceKind, required this.gestureScale, required this.newestPoint, required this.activeLayerId});
}

class ToolStartFrame {
  final PointerDeviceKind pointerDeviceKind;
  final Offset initialPoint;
  final String activeLayerId;
  final int nextStrokeIndex;


  ToolStartFrame({required this.pointerDeviceKind, required this.initialPoint, required this.activeLayerId, required this.nextStrokeIndex});
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