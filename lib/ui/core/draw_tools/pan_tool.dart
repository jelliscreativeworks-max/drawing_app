import 'dart:ui';

import 'package:drawing_app/domain/models/canvas_camera.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/draw_tools/canvas_tool.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class PanTool extends CanvasTool {
  final ToolMatrixPayload _camera;

  bool _isPanning = false;
  
  //Tracks if the cursor is recovering from an OS window boundary exit
  bool _isFirstFrameAfterReEntry = false; 

  PanTool({
    required super.toolName,
    required super.toolIcon,
    
    required ToolMatrixPayload camera,
  }) : _camera = camera;


  @override
  bool get isActive => _isPanning;

  //Called by ToolController.syncPointerStatesOnReEntry if reentering from window
  void flagWindowReEntryTransition() {
    _isFirstFrameAfterReEntry = true;
  }

  void _pan(Offset newPoint) {
    // If resuming from outside the window frame, 
    // swallow the massive jump delta and snap the tracking anchor directly to the new point layout coordinate.
    if (_isFirstFrameAfterReEntry) {
      _camera.panStartOrigin = newPoint;
      _isFirstFrameAfterReEntry = false;
      return;
    }
    final Offset screenDelta = newPoint - _camera.panStartOrigin;
    if (screenDelta == Offset.zero) return;

    _camera.transform = _camera.transform.clone()
      ..translateByVector3(
        vm.Vector3(screenDelta.dx / _camera.currentScale,
        screenDelta.dy / _camera.currentScale,
        0,)
 
      );

    _camera.panStartOrigin = newPoint;
  }
void _zoom(double scale) {
    // 1. Capture the true baseline scale before mutating the matrix array
    final double baselineScale = _camera.currentScale;

    // 2. Calculate target scaling factor from gesture start
    final double proposedScale = _camera.scaleStart * scale;
    final double clampedScale = proposedScale.clamp(0.2, 5.0);
    
    // 3. Determine true layout ratio relative to current baseline scale
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
    if(!_isPanning) return null;
    _isPanning = false;
    _isFirstFrameAfterReEntry = false;
    return null;
  }

  @override
  void onToolStart(ToolStartFrame toolFrame) {
        _isPanning = true;
    _camera.panStartOrigin = toolFrame.initialPoint;
  }

  @override
  void onToolUpdate(ToolUpdateFrame toolFrame) {
        if (!_isPanning) return;
    
    if (toolFrame.pointerDeviceKind == PointerDeviceKind.trackpad) {
      final bool isZooming = (toolFrame.gestureScale - 1.0).abs() > 0.001;

      if (isZooming) {
        // Ignore the trackpad's noisy pan deltas completely to prevent sliding away.
        _zoom(toolFrame.gestureScale);
      } else if (toolFrame.newestPoint != Offset.zero) {
        // two-finger pan scroll (when scale is exactly 1.0)
        if (_isFirstFrameAfterReEntry) {
          _isFirstFrameAfterReEntry = false;
          return;
        }

        _camera.transform = _camera.transform.clone()
          ..translateByVector3(
            vm.Vector3(
              toolFrame.newestPoint.dx / _camera.currentScale,
              toolFrame.newestPoint.dy / _camera.currentScale,
              0.0,
            ),
          );
      }
    } else {
      //Standard single-pointer desktop mouse clicks & touchscreen math 
      _pan(toolFrame.newestPoint);
      if (toolFrame.pointerDeviceKind == PointerDeviceKind.touch) _zoom(toolFrame.gestureScale);
    }
  }

}
