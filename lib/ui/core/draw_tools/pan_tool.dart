import 'dart:ui';

import 'package:drawing_app/domain/models/canvas_camera.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:flutter/material.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class PanTool extends DrawTool {
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
  void updateFillSettings(_) {}

  @override
  void updateStrokeSettings(_) {}

  @override
  bool get isActive => _isPanning;

  @override
  DrawData? get activePreview => null; 

  @override
  void onDrawStart({
    required PointerDeviceKind deviceKind,
    required Offset startPoint,
    required String layerId,
    required int nextStrokeIndex,
    required Color color,
    required double strokeWidth,
  }) {
    _isPanning = true;
    _camera.panStartOrigin = startPoint;
  }

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
  void onUpdateTool({
    required Offset newPoint, 
    required double gestureScale, 
    required PointerDeviceKind deviceKind,
  }) {
    if (!_isPanning) return;
    
    if (deviceKind == PointerDeviceKind.trackpad) {
      final bool isZooming = (gestureScale - 1.0).abs() > 0.001;

      if (isZooming) {
        // Ignore the trackpad's noisy pan deltas completely to prevent sliding away.
        _zoom(gestureScale);
      } else if (newPoint != Offset.zero) {
        // two-finger pan scroll (when scale is exactly 1.0)
        if (_isFirstFrameAfterReEntry) {
          _isFirstFrameAfterReEntry = false;
          return;
        }

        _camera.transform = _camera.transform.clone()
          ..translateByVector3(
            vm.Vector3(
              newPoint.dx / _camera.currentScale,
              newPoint.dy / _camera.currentScale,
              0.0,
            ),
          );
      }
    } else {
      //Standard single-pointer desktop mouse clicks & touchscreen math 
      _pan(newPoint);
      if (deviceKind == PointerDeviceKind.touch) _zoom(gestureScale);
    }
  }


  @override
  CanvasCommand? onDrawEnd() {
    if (!_isPanning) return null;
    _isPanning = false; 
    _isFirstFrameAfterReEntry = false; // Reset clean
    return null;
  }

  @override
  void draw(Canvas canvas, DrawData stroke) {}
}
