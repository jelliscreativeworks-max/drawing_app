import 'dart:math';
import 'dart:ui';

import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:drawing_app/ui/core/commands/erase_draw_command.dart';
import 'package:drawing_app/utils/history_consumer.dart';

class EraseTool extends DrawTool implements HistoryConsumer {
  EraseTool({required super.toolName, required super.toolIcon});

  final List<CanvasHistoryEntry> _erasedDrawData = [];
  List<DrawData> _drawHistory = const [];
  String _currentLayerId = '';

  bool _isErasing = false;
  Offset? _lastActivePoint;
  @override
  void draw(Canvas canvas, DrawData drawData) {}

  /// High-performance geometric collision routing engine that handles 
  /// outline-only strokes, pure fills, composite shapes, and single-dot taps flawlessly.
  void _checkCollisions(Offset p1, Offset p2) {
    final double eraserRadius = (strokePaint?.strokeWidth ?? 20.0) / 2.0;

    for (int i = 0; i < _drawHistory.length; i++) {
      final data = _drawHistory[i];
      
      if (data.layerId != _currentLayerId) continue;
      if (data.points.isEmpty) continue;

      // Prevent duplicate logging during the active gesture session
      final bool alreadyCached = _erasedDrawData.any((entry) => entry.drawData == data);
      if (alreadyCached) continue;

      bool hitDetected = false;

      // =======================================================================
      // 🟢 CONDITION 0: SINGLE-POINT TAP / DOT GUARD RAIL
      // =======================================================================
      if (data.points.length == 1) {
        final Offset singleDot = data.points.first;
        
        // Extract the thickness of the dot, defaulting to a standard baseline if null
        final double dotThickness = data.strokeSettings?.strokeWidth ?? 5.0;
        final double combinedThreshold = eraserRadius + (dotThickness / 2.0);

        // Calculate the shortest distance from the single dot to the eraser's swipe segment line
        final double distanceToSwipe = _pointToSegmentDistance(singleDot, p1, p2);
        
        if (distanceToSwipe <= combinedThreshold) {
          hitDetected = true;
        }
      } 
      // =======================================================================
      // POLYMORPHIC MULTI-POINT SHAPE TESTING ENGINE
      // =======================================================================
      else {
        // 1. CHANNELS PASS A: Check for interior region fills
        if (data.strokeSettings == null || data.fillSettings != null || data.strokeSettings!.style == PaintingStyle.fill) {
          if (_isPointInsidePolygon(p2, data.points) || _isPointInsidePolygon(p1, data.points)) {
            hitDetected = true;
          }
        }

        // 2. CHANNELS PASS B: Check for outline border segment crossings
        if (!hitDetected && data.strokeSettings != null && data.strokeSettings!.style != PaintingStyle.fill) {
          for (int s = 0; s < data.points.length - 1; s++) {
            final Offset v1 = data.points[s];
            final Offset v2 = data.points[s + 1];
            
            final double currentLineThickness = data.strokeSettings!.strokeWidth;
            final double combinedBrushRadius = eraserRadius + (currentLineThickness / 2.0);

            if (_intersects(p1, p2, v1, v2, combinedBrushRadius)) {
              hitDetected = true;
              break; 
            }
          }
        }
      }

          // 3. TRANSACTION REGISTER
      if (hitDetected) {
        // 🟢 FIXED: Instead of checking volatile memory address pointers via indexOf(),
        // look up the live position matching the exact structural 'index' identifier property!
        // This makes your eraser 100% immune to copyWith() cloning anomalies or layer switches.
        final int liveCurrentIndex = _drawHistory.indexWhere(
          (stroke) => stroke.index == data.index,
        );

        if (liveCurrentIndex != -1) {
          _erasedDrawData.add(
            CanvasHistoryEntry(
              originalIndex: liveCurrentIndex, 
              drawData: data,
            ),
          );
        }
      }

    }
  }


  @override
  void onDrawStart({
    required PointerDeviceKind deviceKind,
    required Offset startPoint, 
    required String layerId, 
    required int nextStrokeIndex, // We skip using this hardcoded value entirely!
    required Color color, 
    required double strokeWidth
  }) {
    _isErasing = true;
    _currentLayerId = layerId;
    _lastActivePoint = startPoint;
    _erasedDrawData.clear();

    _checkCollisions(startPoint, startPoint);
  }

  @override
  void onUpdateTool({required Offset newPoint, required double gestureScale,  required PointerDeviceKind deviceKind,}) {
    if(!_isErasing || _lastActivePoint == null) return;
    _checkCollisions(_lastActivePoint!,newPoint);
    _lastActivePoint = newPoint;
  }
  @override
  CanvasCommand? onDrawEnd() {
    // 1. If no shapes were hit during this swipe session, return null early.
    // Because we removed stale static variables, missing a swipe is now 100% safe!
    if (!_isErasing || _erasedDrawData.isEmpty) {
      _isErasing = false;
      _lastActivePoint = null;
      return null;
    }

    _isErasing = false;
    _lastActivePoint = null;

    // =========================================================================
    // 🟢 FIXED: CALCULATE TRUTH AT COMMIT TIMING
    // =========================================================================
    // By checking '_drawHistory.length' exactly when the finger lifts, 
    // we capture the true chronological timeline placement of this transaction, 
    // completely neutralizing any blank misses or layer swaps that came before it!
    final int dynamicCommitIndex = _drawHistory.length;

    final eraseCommand = EraseDrawCommand(
      layerId: _currentLayerId,
      index: dynamicCommitIndex, // Binds safely to the absolute top of the timeline
      erasedDrawData: List<CanvasHistoryEntry>.from(_erasedDrawData),
    );

    _erasedDrawData.clear();
    return eraseCommand;
  }

  @override
  bool get isActive => _isErasing;

  @override
  // TODO: implement activePreview
  DrawData? get activePreview => null;

  @override
  void setHistorySnapshot(List<DrawData> drawHistory) {
    _drawHistory = drawHistory;
  }

  /// Ray-casting algorithm for Point-in-Polygon evaluation.
  /// Determines if an eraser position lands entirely inside a fill region shape.
  bool _isPointInsidePolygon(Offset point, List<Offset> polygon) {
    int intersectCount = 0;
    for (int i = 0; i < polygon.length; i++) {
      final Offset next = polygon[(i + 1) % polygon.length];
      final Offset curr = polygon[i];

      if (((curr.dy > point.dy) != (next.dy > point.dy)) &&
          (point.dx < (next.dx - curr.dx) * (point.dy - curr.dy) / (next.dy - curr.dy) + curr.dx)) {
        intersectCount++;
      }
    }
    return intersectCount % 2 != 0;
  }
bool _intersects(Offset p1, Offset p2, Offset v1, Offset v2, double combinedRadius) {
    final double pad = combinedRadius;
    if (max(p1.dx, p2.dx) < min(v1.dx, v2.dx) - pad ||
        min(p1.dx, p2.dx) > max(v1.dx, v2.dx) + pad ||
        max(p1.dy, p2.dy) < min(v1.dy, v2.dy) - pad ||
        min(p1.dy, p2.dy) > max(v1.dy, v2.dy) + pad) {
      return false;
    }

    final Offset u = p2 - p1;
    final Offset v = v2 - v1;
    final Offset w = p1 - v1;

    final double a = u.dx * u.dx + u.dy * u.dy;
    final double b = u.dx * v.dx + u.dy * v.dy;
    final double c = v.dx * v.dx + v.dy * v.dy;
    final double d = u.dx * w.dx + u.dy * w.dy;
    final double e = v.dx * w.dx + v.dy * w.dy;

    final double D = a * c - b * b;
    double sc, sN, sD = D;       
    double tc, tN, tD = D;       

    if (D < 1e-6) {
      sN = 0.0;
      sD = 1.0;
      tN = e;
      tD = c;
    } else {
      sN = (b * e - c * d);
      tN = (a * e - b * d);
      if (sN < 0.0) {
        sN = 0.0;
        tN = e;
        tD = c;
      } else if (sN > sD) {
        sN = sD;
        tN = e + b;
        tD = c;
      }
    }

    if (tN < 0.0) {
      tN = 0.0;
      if (-d < 0.0) {
        sN = 0.0;
      } else if (-d > a) {
        sN = sD;
      } else {
        sN = -d;
        sD = a;
      }
    } else if (tN > tD) {
      tN = tD;
      if ((-d + b) < 0.0) {
        sN = 0;
      } else if ((-d + b) > a) {
        sN = sD;
      } else {
        sN = (-d + b);
        sD = a;
      }
    }

    sc = (sN.abs() < 1e-6 ? 0.0 : sN / sD);
    tc = (tN.abs() < 1e-6 ? 0.0 : tN / tD);

    final Offset closestVector = w + (u * sc) - (v * tc);
    return closestVector.distance <= combinedRadius;
  }

    // =========================================================================
  // --- ADDITIONAL POINT PROJECTION MATH UTILITIES ---
  // =========================================================================

  /// Calculates the shortest absolute distance from a standalone point [pt]
  /// to a finite line segment traveling between [v] and [w].
  double _pointToSegmentDistance(Offset pt, Offset v, Offset w) {
    // 1. Calculate the finite length squared of the segment path line
    final double l2 = (v.dx - w.dx) * (v.dx - w.dx) + (v.dy - w.dy) * (v.dy - w.dy);
    
    // If v and w are the exact same point, simply return the direct 2D distance
    if (l2 == 0) return (pt - v).distance;
    
    // 2. Determine the projection scalar parameter clipped tightly to the finite segment bounds [0, 1]
    final double t = max(0, min(1, ((pt.dx - v.dx) * (w.dx - v.dx) + (pt.dy - v.dy) * (w.dy - v.dy)) / l2));
    
    // 3. Extrapolate the exact coordinates of the closest point on the segment
    final Offset projection = Offset(v.dx + t * (w.dx - v.dx), v.dy + t * (w.dy - v.dy));
    
    // Return the straight distance vector from our point to that projection node
    return (pt - projection).distance;
  }


}
