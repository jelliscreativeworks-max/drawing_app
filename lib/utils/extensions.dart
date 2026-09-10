import 'dart:math';
import 'package:flutter/material.dart';

extension LineSegmentCollisionDetector on Offset {
  /// Determines if a line segment tracking between [p1] and [p2] intersects or passes 
  /// within a specific [threshold] distance of a vector line segment between [v1] and [v2].
  static bool intersects(Offset p1, Offset p2, Offset v1, Offset v2, double threshold) {
    // 1. Core Geometric Intersection Pass (AABB quick check bound box filtering)
    if (max(p1.dx, p2.dx) < min(v1.dx, v2.dx) - threshold ||
        min(p1.dx, p2.dx) > max(v1.dx, v2.dx) + threshold ||
        max(p1.dy, p2.dy) < min(v1.dy, v2.dy) - threshold ||
        min(p1.dy, p2.dy) > max(v1.dy, v2.dy) + threshold) {
      return false;
    }

    // 2. Standard Cross-Product Vector Plane Intersections Math Equations
    final double denominator = ((p2.dx - p1.dx) * (v2.dy - v1.dy)) - ((p2.dy - p1.dy) * (v2.dx - v1.dx));
    if (denominator.abs() < 1e-6) {
      // Finite segment lines are parallel; run a fallback point-to-line projection check
      return _pointToSegmentDistance(p1, v1, v2) <= threshold;
    }

    final double u = (((v1.dx - p1.dx) * (v2.dy - v1.dy)) - ((v1.dy - p1.dy) * (v2.dx - v1.dx))) / denominator;
    final double v = (((v1.dx - p1.dx) * (p2.dy - p1.dy)) - ((v1.dy - p1.dy) * (p2.dx - p1.dx))) / denominator;

    // If intersection happens exactly along both segment scales, it's a confirmed hit!
    if (u >= 0 && u <= 1 && v >= 0 && v <= 1) return true;

    // 3. Fallback: Check if segment endpoints sit within the safe threshold brush thickness bounds
    return _pointToSegmentDistance(p1, v1, v2) <= threshold ||
           _pointToSegmentDistance(p2, v1, v2) <= threshold ||
           _pointToSegmentDistance(v1, p1, p2) <= threshold;
  }

  static double _pointToSegmentDistance(Offset p, Offset v, Offset w) {
    final double l2 = (v.dx - w.dx) * (v.dx - w.dx) + (v.dy - w.dy) * (v.dy - w.dy);
    if (l2 == 0) return (p - v).distance;
    
    final double t = max(0, min(1, ((p.dx - v.dx) * (w.dx - v.dx) + (p.dy - v.dy) * (w.dy - v.dy)) / l2));
    final Offset projection = Offset(v.dx + t * (w.dx - v.dx), v.dy + t * (w.dy - v.dy));
    return (p - projection).distance;
  }
}
