import 'dart:ui';

import 'package:drawing_app/ui/core/draw_tools/canvas_tool.dart';

class ToolStartInput {
  final PointerDeviceKind kind;
  final CanvasCoordinateSpace points;

  Offset get screenPoint => points.screen;
  Offset get worldPoint => points.world;

  ToolStartInput({required this.kind, required this.points});

  factory ToolStartInput.compute({
    required PointerDeviceKind kind,
    required Offset rawScreenPoint,
    required Offset Function(Offset) screenToWorldConverter
  }){
    return ToolStartInput(
      kind: kind, 
      points: (screen: rawScreenPoint, world: screenToWorldConverter(rawScreenPoint)),
      );
  }


    @override
  String toString() {
    return 'Tool Pressed: [ Device: $kind ]';
  }
}

class ToolUpdateInput {
  final PointerDeviceKind kind;
  final double rawScale;
  final CanvasCoordinateSpace points;

  final Offset delta;

  Offset get screenPoint => points.screen;
  Offset get worldPoint => points.world;

  ToolUpdateInput({
    required this.kind,
    required this.points,
    required this.rawScale,
    required this.delta,
  });

  factory ToolUpdateInput.compute({
    required PointerDeviceKind kind,
    required Offset currentScreenPoint,
    required double currentScale,
    required Offset Function(Offset) screenToWorldConverter,
    required Offset lastScreenPoint,
    Offset? customDelta
  }){
    final CanvasCoordinateSpace computedPoints = (screen: currentScreenPoint, world: screenToWorldConverter(currentScreenPoint));

    final Offset computedDelta = customDelta ?? (currentScreenPoint - lastScreenPoint);



    return ToolUpdateInput(kind: kind, points: computedPoints, rawScale: currentScale, delta: computedDelta);
  }

    @override
  String toString() {
    return 'Tool Update: [ Device: $kind | Raw Scale: $rawScale | Screen Point: $screenPoint | World Point: $worldPoint | Delta: $delta ]';
  }
}

class ToolReleasedInput{
  final PointerDeviceKind lastUsedDevice;


  ToolReleasedInput({required this.lastUsedDevice});

  @override
  String toString() {
    return 'Tool Released: [ Device: $lastUsedDevice ]';
  }
}