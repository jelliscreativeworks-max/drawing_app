import 'dart:ui';

import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:drawing_app/ui/draw_screen/view_models/tool_controller.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class DebugPainter extends CustomPainter{
  final ToolController toolController;
  final DrawScreenViewModel drawScreenViewModel;

  
  final PointerDeviceKind device;
  final Matrix4 transform;
  final double canvasWidth;
  final double canvasHeight;
  final Paint debugPaint = Paint()..color = Colors.red..strokeWidth = 5..style = PaintingStyle.fill;
    final Paint debugPaint2 = Paint()..color = Colors.blue..strokeWidth = 5..style = PaintingStyle.fill;

  DebugPainter({required this.drawScreenViewModel, required this.toolController,required this.transform, required this.canvasHeight, required this.canvasWidth, required this.device});
@override
  void paint(Canvas canvas, Size size) {
    // 1. Open a clean graphics state configuration container anchor frame.
    canvas.save();
    
    // 2. THE CANVASKIT CORE: Apply the camera pan/zoom matrix directly into the painter buffer!
    canvas.transform(transform.storage);

    // Actual input
     if(device != PointerDeviceKind.trackpad)canvas.drawCircle(toolController.screenToWorld(toolController.updateDetails.localFocalPoint), 5, debugPaint);

    
    if(device == PointerDeviceKind.trackpad) canvas.drawCircle(handlePinchZoom(toolController.updateDetails.scale), 5, debugPaint2);

    // canvas.drawPoints(PointMode.points, [_scaleUpdateDetails.focalPoint], debugPaint);
    // canvas.drawPoints(PointMode.points, [_drawScreenViewModel.camera.focalPointAtStart], Paint()..color = Colors.blue..strokeWidth = 5..style = PaintingStyle.stroke);

    // 6. Close the transformation frame safely to protect peripheral rendering streams.
    canvas.restore();
  }
 
 Offset handlePinchZoom(double gestureScale) {
    // 1. Calculate the target zoom multiplier by combining the gesture scale 
    // with the starting zoom level captured when the pinch began.
    final double proposedScale = drawScreenViewModel.camera.scaleStart * gestureScale;
    
    // 2. Restrict zoom parameters within standard creative app bounds (20% to 500%)
    final double clampedScale = proposedScale.clamp(0.2, 5.0); 

    // Safety Optimization: If the delta change is infinitesimally small, skip rendering.
    // if ((clampedScale - drawScreenViewModel.camera.currentScale).abs() < 1e-6) 

    // 3. Determine the relative scale expansion multiplier step factor
    final double scaleMultiplier = clampedScale / drawScreenViewModel.camera.currentScale;

    // =========================================================================
    // 🟢 THE FOCAL POINT CORRECTION MATH
    // =========================================================================
    // Instead of using raw screen pixels, we must translate our focal point
    // back into world canvas coordinates relative to our current viewport setup!
    final Matrix4 inverted = Matrix4.copy(drawScreenViewModel.camera.transform)..invert();
    final vm.Vector4 screenVector = vm.Vector4(
      drawScreenViewModel.camera.focalPointAtStart.dx, 
      drawScreenViewModel.camera.focalPointAtStart.dy, 
      0.0, 
      1.0,
    );
    final vm.Vector4 worldFocalVector = inverted.transform(screenVector);
    
    final double worldFocalX = worldFocalVector.x;
    final double worldFocalY = worldFocalVector.y;
      //   drawScreenViewModel.camera.transform = drawScreenViewModel.camera.transform.clone()
      // ..translate(worldFocalX, worldFocalY)
      // ..scale(scaleMultiplier, scaleMultiplier)
      // ..translate(-worldFocalX, -worldFocalY);


    return Offset(worldFocalX, worldFocalY);

    // // 4. Uniformly mutate the transformation matrix around the localized world anchor point.
    // // By using worldFocal coordinates, your zoom tracks perfectly without drifting!


  }


  @override
  bool shouldRepaint(covariant DebugPainter oldDelegate){
    return 
    oldDelegate.canvasHeight != canvasHeight ||
    oldDelegate.canvasWidth != canvasWidth ||
    oldDelegate.transform != transform ||
    oldDelegate.toolController != toolController ||
    oldDelegate.drawScreenViewModel != drawScreenViewModel ||
    oldDelegate.device != device;


  }
}
