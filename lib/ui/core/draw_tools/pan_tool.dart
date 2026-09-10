import 'package:drawing_app/domain/models/canvas_camera.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:flutter/material.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:drawing_app/domain/models/draw_data/draw_data.dart';

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
  void onDrawStart(
    {
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

  @override
  void onUpdateTool({required Offset newPoint}) {
    if (!_isPanning) return;

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
