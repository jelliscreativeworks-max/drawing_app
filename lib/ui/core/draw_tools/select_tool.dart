import 'dart:math';
import 'dart:ui';
import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/domain/models/tool_input_data/tool_input_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/commands/erase_draw_command.dart';
import 'package:drawing_app/ui/core/commands/transformation_command.dart';
import 'package:drawing_app/ui/core/draw_tools/canvas_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/history_consumer.dart';
import 'package:drawing_app/ui/core/draw_tools/override_drawn.dart';
import 'package:drawing_app/utils/extensions.dart';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';

class SelectTool extends DrawTool implements HistoryConsumer, OverrideDrawn {
  // 🌟 SINGLE SOURCE OF TRUTH: Track unique string IDs instead of object copies
  String? _selectedShapeId;
  final Set<String> _multiSelectShapeIds = {};

  List<DrawData> _drawHistory = [];
  bool _isSelecting = false;
  final double _singleClickRadius = 10;
  String _currentLayerId = '';
  CanvasCoordinateSpace _startPointsRaw = (
    screen: Offset.zero,
    world: Offset.zero,
  );
  CanvasCoordinateSpace _startPointsSnapped = (
    screen: Offset.zero,
    world: Offset.zero,
  );

  // UI Styles
  final Paint boundingBoxPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..color = Colors.black38;
  final Paint groupSelectionPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..color = Colors.black38;

  bool _didHitShapeOnDown = false;
  Rect? dragPreview;

  Rect? _liveGroupScaleBox;

  //   double _originalGroupWidth = 1.0;
  // double _originalGroupHeight = 1.0;

  Rect get groupPreview {
    // A. If actively drawing a marquee selection box across empty space, use your dragPreview field
    if (!_didHitShapeOnDown && dragPreview != null) {
      return dragPreview!;
    }

    // If we are actively transforming multiple shapes (either dragging the body OR scaling handles),
    // derive the outer bounding frame directly from the moving previews list
    // This allows the box outline and corner nodes to glide and scale smoothly with cursor.
    if (_groupDragPreviews.isNotEmpty) {
      return _groupDragPreviews
          .map((data) => data.getGroupBoundingBox())
          .reduce((combined, current) => combined.expandToInclude(current));
    }

    // C. Default: Derive bounds dynamically from history by ID to keep Undo/Redo reactive
    final selectedShapes = _drawHistory
        .where((s) => _multiSelectShapeIds.contains(s.id))
        .toList();
    if (selectedShapes.length < 2) return Rect.zero;

    return selectedShapes
        .map((data) => data.getGroupBoundingBox())
        .reduce((combined, current) => combined.expandToInclude(current));
  }

  double _currentScale = 1.0;

  (int index, Offset nodePosition)? _activeNode;
  Offset _transformAnchorPosition = Offset.zero;

  DrawData? _baselineShapeSnapshot;
  final List<DrawData> _baselineGroupSnapshots = [];

  DrawData? _dragPreview;
  final List<DrawData> _groupDragPreviews = [];

  SelectTool({required super.toolName, required super.toolIcon});

  @override
  bool get isActive => _isSelecting;

  @override
  void setHistorySnapshot(List<DrawData> drawHistory) =>
      _drawHistory = drawHistory;

  @override
  List<DrawData> get activePreview {
    if (!_isSelecting) return const [];

    // 1. Check group preview list FIRST so multi-drags aren't masked
    if (_groupDragPreviews.isNotEmpty) {
      return _groupDragPreviews;
    }

    if (_dragPreview != null) {
      return [_dragPreview!];
    }

    if (_selectedShapeId != null) {
      final liveShape = _drawHistory.firstWhereOrNull(
        (s) => s.id == _selectedShapeId,
      );
      return liveShape != null ? [liveShape] : const [];
    }

    if (_multiSelectShapeIds.isNotEmpty) {
      return _drawHistory
          .where((s) => _multiSelectShapeIds.contains(s.id))
          .toList();
    }

    return const [];
  }

  @override
  Set<String> get hiddenDrawDataIds {
    if (!_isSelecting) return const {};

    // Hide the group items when a multi-drag is active
    if (_groupDragPreviews.isNotEmpty && _didHitShapeOnDown) {
      return _groupDragPreviews.map((e) => e.id).toSet();
    }

    if (_dragPreview != null && (_activeNode != null || _didHitShapeOnDown)) {
      return {_dragPreview!.id};
    }

    return const {};
  }

  @override
  void onToolStart(
    ToolStartInput toolStartInput,
    String layerId,
    int strokeIndex,
  ) {
    _isSelecting = true;
    _currentLayerId = layerId;
    _startPointsRaw = toolStartInput.rawPoints;
    _startPointsSnapped = toolStartInput.snappedPoints;

    // Reset baseline snapshot logs before analyzing the new gesture session
    _baselineShapeSnapshot = null;
    _baselineGroupSnapshots.clear();
    _cleanupEndState();

    // =========================================================================
    // STEP 1: Handle Multi-Selection Interactions (Group Drag or Handle Resize)
    // =========================================================================
    if (_multiSelectShapeIds.isNotEmpty) {
      final activeMultiShapes = _drawHistory.where((s) => _multiSelectShapeIds.contains(s.id)).toList();
      
      final groupRect = groupPreview; 
      if (groupRect != Rect.zero) {
        // 1A. Check if click landed on an outer control handle node resize point of the group box
        final List<Offset> groupControlPoints = groupRect.pointsToList();
        final double nodeScale = 15 / _currentScale; 

        int? hitGroupNode = checkNodeCollision(
          toolStartInput.unSnappedWorlPoint, 
          groupControlPoints, 
          nodeScale,
        );

        if (hitGroupNode != null) {
          _activeNode = (hitGroupNode, groupControlPoints[hitGroupNode]);
          _transformAnchorPosition = _getGroupAnchorForNode(hitGroupNode, groupRect);
          _didHitShapeOnDown = true;

          _liveGroupScaleBox = groupRect;

          _baselineGroupSnapshots.clear();
          _baselineGroupSnapshots.addAll(activeMultiShapes);
          return;
        }

        // 🌟 1B. NEW: Check if click landed ANYWHERE within the outer group bounding box bounds
        // This removes the restriction of needing to target a specific shape line/fill.
        if (groupRect.contains(toolStartInput.unSnappedWorlPoint)) {
          _didHitShapeOnDown = true;

          // Cache element baselines once for smooth group translation math
          _baselineGroupSnapshots.clear();
          _baselineGroupSnapshots.addAll(activeMultiShapes);
          return;
        }
      }
    }


    // =========================================================================
    // STEP 2: Handle Single Selection Interactions (Body Drag or Handle Resize)
    // =========================================================================
    if (_selectedShapeId != null) {
      final liveShape = _drawHistory.firstWhereOrNull(
        (s) => s.id == _selectedShapeId,
      );

      if (liveShape != null) {
        final controlPointsMap = liveShape.getControlPoints();
        final nodeScale = liveShape.getControlPointScale(15, _currentScale, 2);

        // 2A. Check for a single control point handle node hit
        int? hitNode = checkNodeCollision(
          toolStartInput.unSnappedWorlPoint,
          controlPointsMap.values.toList(),
          nodeScale,
        );

        if (hitNode != null) {
          final nodeIndexKey = controlPointsMap.keys.toList()[hitNode];
          final rawPoints = liveShape.getRawControlPoints();

          _activeNode = (nodeIndexKey, rawPoints[nodeIndexKey]!);
          _transformAnchorPosition = liveShape.getAnchorForSelectedNode(
            nodeIndexKey,
          );
          _didHitShapeOnDown = true;

          // Single element node transformation baseline snap
          _baselineShapeSnapshot = liveShape;
          _dragPreview = liveShape.copyWith();
          return;
        }

        // 2B. Check if hitting body area instead of node handles
        if (liveShape.checkPointCollision(
          toolStartInput.unSnappedWorlPoint,
          toolStartInput.unSnappedWorlPoint,
          _singleClickRadius,
        )) {
          _didHitShapeOnDown = true;

          //Single element body drag translation baseline snap
          _baselineShapeSnapshot = liveShape;
          _dragPreview = liveShape.copyWith();
          return;
        }
      }
    }

    // =========================================================================
    // STEP 3: Clicked Empty Canvas Space - Initialize Marquee Drag or Fresh Select
    // =========================================================================
    _flushSelectionState();

    DrawData? freshSelected = _checkSinglePointCollision(
      toolStartInput.unSnappedWorlPoint,
      _drawHistory,
    );

    if (freshSelected != null) {
      _didHitShapeOnDown = true;
      _selectedShapeId = freshSelected.id;

      //Capture baseline for a freshly tapped single target selection
      _baselineShapeSnapshot = freshSelected;
      _dragPreview = freshSelected.copyWith();
    } else {
      // Empty space tap triggers marquee bounding collection mode on the next update ticks
      _didHitShapeOnDown = false;
    }
  }

  /// Anchor resolution mapping helper for group bounding boxes
  Offset _getGroupAnchorForNode(int nodeIndex, Rect rect) {
    // Custom 4-corner bounding handle matrix match option:
    // 0: TopLeft, 1: TopRight, 2: BottomRight, 3: BottomLeft
    switch (nodeIndex) {
      case 0:
        return rect.bottomRight; // Grabbing TL -> Anchor is BR
      case 1:
        return rect.bottomCenter;
      case 2:
        return rect.bottomLeft; // Grabbing TR -> Anchor is BL
      case 3:
        return rect.centerLeft;
      case 4:
        return rect.topLeft; // Grabbing BR -> Anchor is TL
      case 5: 
      return rect.topCenter;
      case 6:
        return rect.topRight; // Grabbing BL -> Anchor is TR
      case 7:
        return rect.centerRight;
      default:
        return rect.center;
    }
  }

  @override
  void onToolUpdate(ToolUpdateInput toolUpdateInput, String layerId) {
    if (!_isSelecting) return;

    // =========================================================================
    // BRANCH A: Active Node Handle Transformation (Resizing/Scaling Layouts)
    // =========================================================================
    if (_activeNode != null) {
      // A1. Resizing a SINGLE shape handle
      if (_selectedShapeId != null && _dragPreview != null && _baselineShapeSnapshot != null) {
        _dragPreview = _baselineShapeSnapshot!.applyNodeTransformation(
          _activeNode!,
          toolUpdateInput.snappedWorldPoint,
          _transformAnchorPosition,
        );
      }
      // A2. Resizing an entire MULTI-SHAPE selection group box handle together
      else if (_multiSelectShapeIds.isNotEmpty &&
          _baselineGroupSnapshots.isNotEmpty) {
        int nodeIndex = _activeNode!.$1;

        // 1. Grab the clean baseline dimensions straight out of your cached rectangle instance
        double safeOriginalWidth = _liveGroupScaleBox!.width == 0
            ? 1.0
            : _liveGroupScaleBox!.width;
        double safeOriginalHeight = _liveGroupScaleBox!.height == 0
            ? 1.0
            : _liveGroupScaleBox!.height;

        // 2. Calculate current raw distance from the stationary anchor to our cursor
        double currentWidth =
            (toolUpdateInput.snappedWorldPoint.dx - _transformAnchorPosition.dx)
                .abs();
        double currentHeight =
            (toolUpdateInput.snappedWorldPoint.dy - _transformAnchorPosition.dy)
                .abs();

        // 3. PURE LINEAR RATIO: No floating point compound loops
        double sx = currentWidth / safeOriginalWidth;
        double sy = currentHeight / safeOriginalHeight;

        // Corners: 0 (TL), 2 (TR), 4 (BR), 6 (BL)
        // Sides: 1 (Top), 3 (Right), 5 (Bottom), 7 (Left)
        if (nodeIndex == 1 || nodeIndex == 5) {
          sx =
              1.0; // Force horizontal scale to freeze completely when pulling top/bottom edges
        } else if (nodeIndex == 3 || nodeIndex == 7) {
          sy =
              1.0; // Force vertical scale to freeze completely when pulling left/right edges
        }

        // 3. Directional quadrant checks (keeps flips smooth when moving past anchor lines)
        // Skip flipping checks on axes that are completely locked
        bool isXFlipped = false;
        bool isYFlipped = false;

        if (sx != 1.0) {
          isXFlipped =
              (toolUpdateInput.snappedWorldPoint.dx <
                  _transformAnchorPosition.dx) !=
              (_startPointsRaw.world.dx < _transformAnchorPosition.dx);
        }
        if (sy != 1.0) {
          isYFlipped =
              (toolUpdateInput.snappedWorldPoint.dy <
                  _transformAnchorPosition.dy) !=
              (_startPointsRaw.world.dy < _transformAnchorPosition.dy);
        }

        if (isXFlipped) sx = -sx;
        if (isYFlipped) sy = -sy;

        // 4. Map the transformation smoothly across our snapshots
        _groupDragPreviews.clear();
        for (final snapshot in _baselineGroupSnapshots) {
          _groupDragPreviews.add(
            snapshot.scaleRelativeToAnchor(sx, sy, _transformAnchorPosition),
          );
        }
      }
    }
    // =========================================================================
    // BRANCH B: Active Shape Body Translation Dragging (Single or Group)
    // =========================================================================
    else if (_didHitShapeOnDown) {
      // Calculate how far the cursor has moved away from the initial click anchor position
      final Offset translationDelta =
          toolUpdateInput.unSnappedWorlPoint - _startPointsRaw.world;

      // B1. SINGLE SHAPE BODY DRAG
      if (_selectedShapeId != null && _baselineShapeSnapshot != null) {
        _dragPreview = _baselineShapeSnapshot!.translate(translationDelta);
      }
      // B2. MULTI-SHAPE GROUP BODY DRAG
      else if (_multiSelectShapeIds.isNotEmpty &&
          _baselineGroupSnapshots.isNotEmpty) {
        _translateMultiSelectGroup(translationDelta);
      }
    }
    // =========================================================================
    // BRANCH C: Empty Canvas Space Marquee Box Drag Selection Mode
    // =========================================================================
    // C: Drawing marquee box selection over empty grid space
    else if (!_didHitShapeOnDown) {
      dragPreview = Rect.fromPoints(
        _startPointsSnapped.world,
        toolUpdateInput.snappedWorldPoint,
      );
      _getGroupBoundingBox(
        _startPointsSnapped.world,
        toolUpdateInput.snappedWorldPoint,
      );
    }
  }

  @override
  CanvasCommand? onToolEnd() {
    // 1. Check if a marquee box selection sequence just finished over empty space
    if (!_didHitShapeOnDown && _multiSelectShapeIds.isNotEmpty) {
      // If the marquee caught exactly ONE shape,
      // upgrade it to a standard single selection and skip command generation
      if (_multiSelectShapeIds.length == 1) {
        _selectedShapeId = _multiSelectShapeIds.first;
        _multiSelectShapeIds.clear();
        _cleanupEndState();
        return null;
      }
    }

    // 2. Security fallback: If no adjustments were made, exit safely
    if (_dragPreview == null && _groupDragPreviews.isEmpty) {
      _cleanupEndState();
      return null;
    }

    if (!_didHitShapeOnDown && _multiSelectShapeIds.isEmpty) {
      cancel();
      return null;
    }

    // --- CASE A: SINGLE SHAPE TRANSFORMATION COMMIT ---
    if (_selectedShapeId != null && _dragPreview != null) {
      final int liveCurrentIndex = _drawHistory.indexWhere(
        (s) => s.id == _selectedShapeId,
      );
      if (liveCurrentIndex == -1) {
        _cleanupEndState();
        return null;
      }

      final originalData = _drawHistory[liveCurrentIndex];
      if (originalData.hasSamePropertiesAsOther(_dragPreview!)) {
        _cleanupEndState();
        return null;
      }

      final transformCommand = TransformationCommand(
        layerId: _currentLayerId,
        index: _drawHistory.length,
        transformedData: [
          CanvasHistoryEntry(
            originalIndex: liveCurrentIndex,
            originalData: originalData,
            transformedData: _dragPreview!,
          ),
        ],
      );

      _cleanupEndState();
      return transformCommand;
    }

    // --- CASE B: MULTI-SHAPE GROUP TRANSFORMATION COMMIT ---
    if (_multiSelectShapeIds.isNotEmpty && _groupDragPreviews.isNotEmpty) {
      final List<CanvasHistoryEntry> historyEntries = [];

      for (final movingPreview in _groupDragPreviews) {
        final int liveIndex = _drawHistory.indexWhere(
          (s) => s.id == movingPreview.id,
        );
        if (liveIndex != -1) {
          historyEntries.add(
            CanvasHistoryEntry(
              originalIndex: liveIndex,
              originalData: _drawHistory[liveIndex],
              transformedData: movingPreview,
            ),
          );
        }
      }

      if (historyEntries.isEmpty) {
        _cleanupEndState();
        return null;
      }

      final transformCommand = TransformationCommand(
        layerId: _currentLayerId,
        index: _drawHistory.length,
        transformedData: historyEntries,
      );

      _cleanupEndState();
      return transformCommand;
    }

    _cleanupEndState();
    return null;
  }

  @override
  void cancel() {
    _isSelecting = false;
    _didHitShapeOnDown = false;
    _flushSelectionState();
  }

  void _flushSelectionState() {
    _multiSelectShapeIds.clear();
    _selectedShapeId = null;
    _cleanupEndState();
  }

  void _cleanupEndState() {
    _dragPreview = null;
    _activeNode = null;
    dragPreview = null;
    _groupDragPreviews.clear();
    _baselineShapeSnapshot = null;
    _baselineGroupSnapshots.clear();
  }

  @override
  void drawToolOverlay(Canvas canvas, PointerDeviceKind device, double scale) {
    _currentScale = scale;

    final List<DrawData> resolvedTargets = activePreview;

    // 1. Render Active Single Selection Layout Bounds, Active Preview Shape, and Nodes
    if (resolvedTargets.isNotEmpty &&
        _selectedShapeId != null &&
        resolvedTargets.length == 1 &&
        dragPreview == null) {
      final currentShape = resolvedTargets.first;
      final Rect? box = currentShape.getIndividualBoundingBox();

      if (box != null) {
        canvas.drawRect(box, boundingBoxPaint);
      }

      final double controlScale = currentShape.getControlPointScale(
        15,
        scale,
        2,
      );
      final List<Offset> controlPoints = currentShape
          .getControlPoints()
          .values
          .toList();

      canvas.drawPoints(
        PointMode.points,
        controlPoints,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = controlScale
          ..strokeCap = StrokeCap.round
          ..color = Colors.black,
      );

      canvas.drawPoints(
        PointMode.points,
        controlPoints,
        Paint()
          ..color = Colors.white
          ..strokeCap = StrokeCap.round
          ..strokeWidth = controlScale - (1.0 / scale),
      );
    }

    // 2. Render Selection Frames for Multi-Selected Entities
    if (resolvedTargets.isNotEmpty && _multiSelectShapeIds.isNotEmpty) {
      for (final data in resolvedTargets) {
        canvas.drawRect(data.getGroupBoundingBox(), boundingBoxPaint);
      }
    }

    // 3. Render Active Marquee Box Drag Frame
    if (dragPreview != null) {
      canvas.drawRect(dragPreview!, boundingBoxPaint);
    }

    // 4. Render Global Aggregate Multi-Selection Outer Wrapper Bounds
    // Only render the big group box if we aren't dynamically dragging an empty marquee frame
    if (groupPreview != Rect.zero && dragPreview == null) {
      final double computedGroupStroke = min(
        max(15 / scale, groupSelectionPaint.strokeWidth),
        groupPreview.shortestSide * 0.5,
      );
      final List<Offset> groupPoints = groupPreview.pointsToList();

      canvas.drawRect(groupPreview, groupSelectionPaint);

      canvas.drawPoints(
        PointMode.points,
        groupPoints,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = computedGroupStroke
          ..strokeCap = StrokeCap.round
          ..color = Colors.black,
      );

      canvas.drawPoints(
        PointMode.points,
        groupPoints,
        Paint()
          ..color = Colors.white
          ..strokeCap = StrokeCap.round
          ..strokeWidth = computedGroupStroke - (1.0 / scale),
      );
    }
  }

  DrawData? _checkSinglePointCollision(
    Offset point,
    List<DrawData> dataToCheck,
  ) {
    for (int i = dataToCheck.length - 1; i >= 0; i--) {
      final data = dataToCheck[i];
      if (data.layerId != _currentLayerId) continue;
      if (data.checkPointCollision(point, point, _singleClickRadius)) {
        return data;
      }
    }
    return null;
  }

  int? checkNodeCollision(
    Offset point,
    List<Offset> nodePoints,
    double nodeScale,
  ) {
    for (int i = 0; i < nodePoints.length; i++) {
      final nodeRect = Rect.fromCenter(
        center: nodePoints[i],
        width: nodeScale,
        height: nodeScale,
      );
      if (nodeRect.isPointInsideRect(point)) return i;
    }
    return null;
  }

  Rect _getGroupBoundingBox(Offset fromPoint, Offset toPoint) {
    final checkBounds = Rect.fromPoints(fromPoint, toPoint);
    _multiSelectShapeIds.clear();

    for (final data in _drawHistory) {
      if (data.layerId != _currentLayerId) continue;

      final bounds = data.getBounds();
      final isContained =
          checkBounds.contains(bounds.topLeft) &&
          checkBounds.contains(bounds.bottomRight) &&
          checkBounds.contains(bounds.topRight) &&
          checkBounds.contains(bounds.bottomLeft);

      if (isContained) {
        _multiSelectShapeIds.add(data.id);
      }
    }

    final selectedShapes = _drawHistory
        .where((s) => _multiSelectShapeIds.contains(s.id))
        .toList();
    if (selectedShapes.length < 2) return Rect.zero;

    return selectedShapes
        .map((data) => data.getGroupBoundingBox())
        .reduce((combined, current) => combined.expandToInclude(current));
  }

  void _translateMultiSelectGroup(Offset delta) {
    _groupDragPreviews.clear();

    // Pure math mapping across the pristine snapshots cached in onToolStart
    for (final snapshot in _baselineGroupSnapshots) {
      _groupDragPreviews.add(snapshot.translate(delta));
    }
  }
}
