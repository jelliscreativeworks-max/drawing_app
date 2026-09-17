import 'dart:ui';
import 'package:drawing_app/domain/models/canvas_camera.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/draw_tools/canvas_tool.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class PanTool extends CanvasTool {
  final ToolMatrixPayload _camera;
  bool _isPanning = false;

  PanTool({
    required super.toolName,
    required super.toolIcon,
    required ToolMatrixPayload camera,
  }) : _camera = camera;

  @override
  bool get isActive => _isPanning;

  /// Translates the camera matrix based on the calculated frame-to-frame delta vector.
  void _pan(Offset screenDelta) {
    if (screenDelta == Offset.zero) return;

    _camera.transform = _camera.transform.clone()
      ..translateByVector3(
        vm.Vector3(
          screenDelta.dx / _camera.currentScale,
          screenDelta.dy / _camera.currentScale,
          0,
        ),
      );
  }

  /// Scales the camera viewport matrix around the continuous focal coordinate.
  void _zoom(double scale) {
    final double baselineScale = _camera.currentScale;
    final double proposedScale = _camera.scaleStart * scale;
    final double clampedScale = proposedScale.clamp(0.2, 5.0);
    final double scaleMultiplier = clampedScale / baselineScale;

    // Quick structural shortcut if we are hitting hard clamp thresholds
    if ((scaleMultiplier - 1.0).abs() < 0.0001) return;

    final Matrix4 inverted = Matrix4.copy(_camera.transform)..invert();
    final vm.Vector4 screenVector = vm.Vector4(
      _camera.focalPointAtStart.dx,
      _camera.focalPointAtStart.dy,
      0.0,
      1.0,
    );
    final vm.Vector4 worldFocalVector = inverted.transform(screenVector);

    final double worldFocalX = worldFocalVector.x;
    final double worldFocalY = worldFocalVector.y;
    
    _camera.transform = _camera.transform.clone()
      ..translateByVector3(vm.Vector3(worldFocalX, worldFocalY, 0.0))
      ..scaleByVector3(vm.Vector3(scaleMultiplier, scaleMultiplier, 1.0))
      ..translateByVector3(vm.Vector3(-worldFocalX, -worldFocalY, 0.0));
  }

  @override
  CanvasCommand? onToolEnd() {
    if (!_isPanning) return null;
    _isPanning = false;
    return null;
  }

  @override
  void onToolStart(ToolStartFrame toolFrame) {
    _isPanning = true;
  }
     @override
  void onToolUpdate(ToolUpdateFrame toolFrame) {
    if (!_isPanning) return;
    
    if (toolFrame.pointerDeviceKind == PointerDeviceKind.trackpad) {
      final bool isZooming = (toolFrame.rawScale - 1.0).abs() > 0.001;

      if (isZooming) {
        _zoom(toolFrame.rawScale);
      } else if (toolFrame.screenPoint != Offset.zero) {
        _camera.transform = _camera.transform.clone()
          ..translateByVector3(
            vm.Vector3(
              toolFrame.screenPoint.dx / _camera.currentScale,
              toolFrame.screenPoint.dy / _camera.currentScale,
              0.0,
            ),
          );
      }
    } else {
      // Standard mouse, stylus, and touch gestures remain untouched
      _pan(toolFrame.delta);
      if (toolFrame.pointerDeviceKind == PointerDeviceKind.touch) {
        _zoom(toolFrame.rawScale);
      }
    }
  }



}
