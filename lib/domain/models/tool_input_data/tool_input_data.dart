import 'dart:ui';

import 'package:drawing_app/ui/core/draw_tools/canvas_tool.dart';

class ToolStartInput {
  final PointerDeviceKind kind;
  final CanvasCoordinateSpace snappedPoints;
  final CanvasCoordinateSpace rawPoints;

  Offset get snappedScreenPoint => snappedPoints.screen;
  Offset get snappedWorldPoint => snappedPoints.world;

  Offset get unSnappedScreenPoint => rawPoints.screen;
  Offset get unSnappedWorlPoint => rawPoints.world;

  ToolStartInput({required this.kind, required this.snappedPoints, required this.rawPoints});

  factory ToolStartInput.compute({
    required PointerDeviceKind kind,
    required Offset rawScreenPoint,
    required Offset Function(Offset screenPoint) snappedScreenToWorldConverter,
    required Offset Function(Offset screenPoint) unsnappedScreenToWorldConverter
  }){
    return ToolStartInput(
      kind: kind, 
      snappedPoints: (screen: rawScreenPoint, world: snappedScreenToWorldConverter(rawScreenPoint)),
      rawPoints: (screen: rawScreenPoint, world: unsnappedScreenToWorldConverter(rawScreenPoint))
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
  final CanvasCoordinateSpace snappedPoints;
  final CanvasCoordinateSpace rawPoints;

  final Offset delta;

  Offset get snappedScreenPoint => snappedPoints.screen;
  Offset get snappedWorldPoint => snappedPoints.world;

  Offset get unSnappedScreenPoint => rawPoints.screen;
  Offset get unSnappedWorlPoint => rawPoints.world;

  ToolUpdateInput({
    required this.kind,
    required this.snappedPoints,
    required this.rawScale,
    required this.delta,
    required this.rawPoints
  });

  factory ToolUpdateInput.compute({
    required PointerDeviceKind kind,
    required Offset rawScreenPoint,
    required double currentScale,
    required Offset Function(Offset screenPoint) snappedScreenToWorldConverter,
    required Offset Function(Offset screenPoint) unsnappedScreenToWorldConverter,
    required Offset lastScreenPoint,
    Offset? customDelta
  }){
    final CanvasCoordinateSpace computedSnappedPoints = (screen: rawScreenPoint, world: snappedScreenToWorldConverter(rawScreenPoint));
    final CanvasCoordinateSpace computedRawPoints = (screen: rawScreenPoint, world: unsnappedScreenToWorldConverter(rawScreenPoint));

    final Offset computedDelta = customDelta ?? (rawScreenPoint - lastScreenPoint);



    return ToolUpdateInput(kind: kind, snappedPoints: computedSnappedPoints, rawPoints: computedRawPoints, rawScale: currentScale, delta: computedDelta);
  }

    @override
  String toString() {
    return 'Tool Update: [ Device: $kind | Raw Scale: $rawScale | Screen Point: $snappedScreenPoint | World Point: $snappedWorldPoint | Delta: $delta ]';
  }
}

class ToolReleasedInput{
  final PointerDeviceKind lastUsedDevice;
  


  ToolReleasedInput({required this.lastUsedDevice,});

  @override
  String toString() {
    return 'Tool Released: [ Device: $lastUsedDevice ]';
  }
}