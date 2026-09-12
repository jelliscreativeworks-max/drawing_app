import 'dart:ui';

import 'package:drawing_app/domain/models/canvas_camera.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:flutter/material.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class PanTool extends DrawTool {
  final ToolMatrixPayload _camera;

  // Track structural state locally to prevent ghost gestures
  bool _isPanning = false;

  PanTool({
    required super.toolName,
    required super.toolIcon,
    required ToolMatrixPayload camera,
  }) : _camera = camera;

  // --- Core Abstract Base Interface Contract Overrides ---

  @override
  void updateFillSettings(_) {}

  @override
  void updateStrokeSettings(_) {}

  @override
  bool get isActive => _isPanning;

  @override
  DrawData? get activePreview => null; // Navigation tools never author real-time vector line previews

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
    // Lock where the stylus gesture initiated directly on the physical glass viewport
    _camera.panStartOrigin = startPoint;
  }

  void _pan(Offset newPoint) {
    // 1. Calculate step migration distance deltas across layout grid pixels
    final Offset screenDelta = newPoint - _camera.panStartOrigin;
    if (screenDelta == Offset.zero) return;

    // 2. Uniformly shift matrix properties scaled dynamically alongside zoom depths
    _camera.transform = _camera.transform.clone()
      ..translate(
        screenDelta.dx / _camera.currentScale,
        screenDelta.dy / _camera.currentScale,
      );

    // 3. Keep the interaction boundary anchor point tracking layout frames accurately
    _camera.panStartOrigin = newPoint;
  }

  void _zoom(double scale) {
    // 1. Calculate the target zoom multiplier by combining the gesture scale
    // with the starting zoom level captured when the pinch began.
    final double proposedScale = _camera.scaleStart * scale;

    // 2. Restrict zoom parameters within standard creative app bounds (20% to 500%)
    final double clampedScale = proposedScale.clamp(0.2, 5.0);

    // Safety Optimization: If the delta change is infinitesimally small, skip rendering.
    // if ((clampedScale - drawScreenViewModel.camera.currentScale).abs() < 1e-6)

    // 3. Determine the relative scale expansion multiplier step factor
    final double scaleMultiplier = clampedScale / _camera.currentScale;

    // =========================================================================
    // 🟢 THE FOCAL POINT CORRECTION MATH
    // =========================================================================
    // Instead of using raw screen pixels, we must translate our focal point
    // back into world canvas coordinates relative to our current viewport setup!
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
      ..translate(worldFocalX, worldFocalY)
      ..scale(scaleMultiplier, scaleMultiplier)
      ..translate(-worldFocalX, -worldFocalY);
  }

  @override
  void onUpdateTool({required Offset newPoint, required double gestureScale,  required PointerDeviceKind deviceKind,}) {
    if (!_isPanning) return;
    if(deviceKind == PointerDeviceKind.trackpad){
      if(gestureScale != 1.0){
        _zoom(gestureScale);
      } else{
        _pan(newPoint);
      }
    } else{
      _pan(newPoint);
      _zoom(gestureScale);
    }
  }

  @override
  CanvasCommand? onDrawEnd() {
    if (!_isPanning) return null;
    _isPanning = false; // Reset gesture flag state cleanly

    // Navigational camera changes modify screen configurations, not document datasets.
    // Returning null keeps movement actions entirely hidden from the structural Undo stack.
    return null;
  }

  @override
  void draw(Canvas canvas, DrawData stroke) {
    // Navigation tools do not commit vector lines onto active drawing custom painters
  }
}
