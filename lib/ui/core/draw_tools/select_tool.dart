import 'dart:math';
import 'dart:ui';

import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/domain/models/tool_input_data/tool_input_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:drawing_app/utils/extensions.dart';
import 'package:drawing_app/utils/history_consumer.dart';
import 'package:flutter/material.dart';

class SelectTool extends DrawTool implements HistoryConsumer{
  final Set<DrawData> _multiSelectData = {};
  DrawData? _singleSelectData;
  List<DrawData> _drawHistory = [];
  bool _isSelecting = false;
  final double _singleClickRadius = 10;
  String _currentLayerId = ''; //TODO: Maybe think about removing layerDependency from tools. The tool controller should just feed in the required filtered data
  Offset _startPoint = Offset.zero;
  SelectTool({required super.toolName, required super.toolIcon});
  
  Paint boundingBoxPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = Colors.black38;
    Paint groupSelectionPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = Colors.black38;
  
  Paint nodePaintFill = Paint()..color = Colors.white..strokeCap = StrokeCap.round;
  Paint nodePaintOutline = Paint()..style = PaintingStyle.stroke..strokeWidth = 15..strokeCap = StrokeCap.round..color = Colors.black;
  
  bool _didHitShapeOnDown = false;

  Rect? dragPreview;
  Rect groupPreview = Rect.zero;

  @override
  // TODO: implement activePreview
  DrawData? get activePreview => null;

  @override
  bool get isActive => _isSelecting;

  @override
  void onToolStart(ToolStartInput toolStartInput, String layerId, int strokeIndex) {
    _isSelecting = true;
    _currentLayerId = layerId;
    _startPoint = toolStartInput.worldPoint;

    // STEP 1: Priority check. Did the click land inside the ALREADY active group selection?
    bool hitExistingMultiSelect = false;
    for (var data in _multiSelectData) {
      if (data.checkPointCollision(toolStartInput.worldPoint, toolStartInput.worldPoint, _singleClickRadius)) {
        hitExistingMultiSelect = true;
        break;
      }
    }

    if (hitExistingMultiSelect) {
      // It's a group drag! Preserve everything, mark as shape interaction, and don't clear anything.
      _didHitShapeOnDown = true;
      transformShape(); 
      return;
    }

    // STEP 2: Did the click land inside the ALREADY active single selection?
    if (_singleSelectData != null && 
        _singleSelectData!.checkPointCollision(toolStartInput.worldPoint, toolStartInput.worldPoint, _singleClickRadius)) {
      // Dragging the currently single-selected shape. Preserve it.
      _didHitShapeOnDown = true;
      transformShape();
      return;
    }

    // STEP 3: If we missed the active group and active single shape, this is a FRESH selection intent.
    // Cleanly flush all previous selection tracking arrays right here!
    _multiSelectData.clear();
    _singleSelectData = null;
    groupPreview = Rect.zero;
    dragPreview = null;

    // Check what new item we hit, if any
    DrawData? freshSelected = _checkSinglePointCollision(toolStartInput.worldPoint, _drawHistory);

    if (freshSelected != null) {
      _didHitShapeOnDown = true;
      _singleSelectData = freshSelected;
    } else {
      // Struck completely empty space. Prepare to open a marquee selection box.
      _didHitShapeOnDown = false; 
    }
  }

  @override
  void onToolUpdate(ToolUpdateInput toolUpdateInput, String layerId) {
    if (!_isSelecting) return;

    if (_didHitShapeOnDown) {
      // 1. Dragging an active shape or active group
      _transformActiveSelection(toolUpdateInput);
    } else {
      // 2. Dragging a marquee box over empty space
      _checkWithinRectCollision(_startPoint, toolUpdateInput.worldPoint);
    }
  }

  @override
  CanvasCommand? onToolEnd() {
    if (!_didHitShapeOnDown) {
      // The gesture started on empty space
      if (_multiSelectData.isNotEmpty) {
        // A: The marquee box successfully caught something new. Clear single hook.
        _singleSelectData = null; 
      } else {
        // B: Static click/miss on completely empty space. Clear everything and turn off tool.
        cancel();
      }
    } else {
      print('Return Trany COmmand');
      // 🟢 IMMUTABLE HANDOFF: The user let go of a drag transformation.
      // This is exactly where we will return your concrete TransformCommand!
    }
    
    dragPreview = null;
    return null;
  }

  @override
  void cancel() {
    _isSelecting = false;
    _didHitShapeOnDown = false;
    _singleSelectData = null;
    _multiSelectData.clear();
    groupPreview = Rect.zero;
    dragPreview = null;
  }

  DrawData? _checkSinglePointCollision(Offset point, List<DrawData> dataToCheck) {
    // Walk backward through history natively to pick the topmost item safely
    for (int i = dataToCheck.length - 1; i >= 0; i--) {
      final data = dataToCheck[i];
      if (data.layerId != _currentLayerId) continue;

      if (data.checkPointCollision(point, point, _singleClickRadius)) {
        return data;
      }
    }
    return null;
  }

  void _checkWithinRectCollision(Offset fromPoint, Offset toPoint) {
    Rect checkBounds = Rect.fromPoints(fromPoint, toPoint);
    dragPreview = checkBounds;
    for (int i = 0; i < _drawHistory.length; i++) {
      final data = _drawHistory[i];
      if (data.layerId != _currentLayerId) continue;

      Rect bounds = data.getBounds();
      if (checkBounds.contains(bounds.topLeft) && 
          checkBounds.contains(bounds.bottomRight) && 
          checkBounds.contains(bounds.topRight) && 
          checkBounds.contains(bounds.bottomLeft)) {
        _multiSelectData.add(data);
      } else {
        _multiSelectData.remove(data);
      }
    }

    if(_multiSelectData.length >= 2){
      groupPreview = _multiSelectData.first.getGroupBoundingBox();
      final list = _multiSelectData.toList();
      for(int i = 1; i < list.length; i++){
        groupPreview = groupPreview.expandToInclude(list[i].getGroupBoundingBox());
      }
    }
  }

// TODO: might want to pass min threshold as a number based on the screen size
  @override
  void drawToolOverlay(Canvas canvas, PointerDeviceKind device, double scale) {

  
    if (_singleSelectData != null) {
      Rect? box = _singleSelectData!.getIndividualBoundingBox();
      
      if(box != null){
      canvas.drawRect(box, boundingBoxPaint);
      }

      //Potential Todo, Have points scale with stroke size of selected incase the stroke width is high       
      nodePaintOutline = nodePaintOutline..strokeWidth = _singleSelectData!.getControlPointScale(15, scale, 2);
      nodePaintFill = nodePaintFill..strokeWidth = _singleSelectData!.getControlPointScale(15, scale, 2) - 1/scale;

      canvas.drawPoints(PointMode.points, _singleSelectData!.getControlPoints(), nodePaintOutline);
      canvas.drawPoints(PointMode.points, _singleSelectData!.getControlPoints(), nodePaintFill);
      
    }
    
    for (DrawData data in _multiSelectData) {
      canvas.drawRect(data.getGroupBoundingBox(), boundingBoxPaint);
    }

    if(dragPreview != null){
      canvas.drawRect(dragPreview!, boundingBoxPaint);
    }

    if(groupPreview != Rect.zero){
      nodePaintOutline = nodePaintOutline..strokeWidth = groupPreview.controlPointScale(scale, groupSelectionPaint.strokeWidth, 15, 2);
      nodePaintOutline = nodePaintOutline..strokeWidth = min(max(15/scale, groupSelectionPaint.strokeWidth), groupPreview.shortestSide / 2);
      nodePaintFill = nodePaintFill..strokeWidth = nodePaintOutline.strokeWidth - 1/scale;
      canvas.drawRect(groupPreview, groupSelectionPaint);
      canvas.drawPoints(PointMode.points, groupPreview.pointsToList(), nodePaintOutline);
      canvas.drawPoints(PointMode.points, groupPreview.pointsToList(), nodePaintFill);
    }
  
      
    
    
  }

  void transformShape() {
    print('Transforming Shape');
  }

  void _transformActiveSelection(ToolUpdateInput input) {
    print('Moving shape by delta: ${input.delta}');
  }

  @override
  void setHistorySnapshot(List<DrawData> drawHistory) {
    _drawHistory = drawHistory;
  }
}
