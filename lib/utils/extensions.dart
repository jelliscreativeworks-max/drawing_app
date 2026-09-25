import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;


extension ListExtensions<T> on List<T>{

  /// Returns a copy of this list where [index] is replaced by [element], [index] must be non negative and less than the length of this list
  List<T> replaceAt(int index, T element){
    if(length <= index || index < 0) throw RangeError.index(index, this);
    return List<T>.from(this)..[index] = element;
  }
}

extension RectExtensions on Rect{
  List<Offset> pointsToList(){
    return <Offset>[topLeft,topCenter,topRight,centerRight,bottomRight,bottomCenter,bottomLeft,centerLeft];
  }

  double controlPointScale(double scale, double borderBoxStrokeWidth, double baseSize, double minThreshold){
    double size = min(max(baseSize/scale, borderBoxStrokeWidth), shortestSide / 2);
    if(size > minThreshold){
      return size;
    } else{
      return minThreshold;
    }
  }
}


extension OffsetConversion on Offset{

  Offset screenToWorld(Matrix4 worldTransform) {
    final Matrix4 transformMatrix = worldTransform;

    // Invert the camera transformation matrix to reverse the painter's shift
    final Matrix4 inverted = Matrix4.copy(transformMatrix)..invert();

    // Cast the 2D offset into a 4D vector space calculation block
    final vm.Vector4 screenVector = vm.Vector4(
      dx,
      dy,
      0.0,
      1.0,
    );
    final vm.Vector4 worldVector = inverted.transform(screenVector);

    return Offset(worldVector.x, worldVector.y);
  }
}


extension OffsetPointDetection on List<Offset>{
  double? distanceFromPoint(Offset point, int index){
    if(index >= length) return null;

    return (point - this[index]).distance;
  }




double findSmallestDistance(double minThreshold) {
  if (length < 2) {
    throw ArgumentError("You need at least 2 points to find a distance.");
  }

  double minDistanceSq = double.infinity;

  for (int i = 0; i < length; i++) {
    for (int j = i + 1; j < length; j++) {
      // Calculate squared distance (fast, no square root calculation yet)
      double currentDistanceSq = (this[i] - this[j]).distanceSquared;

      if (currentDistanceSq < minDistanceSq && currentDistanceSq >= minThreshold) {
        minDistanceSq = currentDistanceSq;
      }
    }
  }

  // Take the square root once at the end to get the actual distance
  return sqrt(minDistanceSq);
}




  int? closestIndexToPoint(Offset point){
    if(isEmpty) return null;

    late int closestIndex;
    double? shortestDistance;

    for(int i = 0; i < length; i++){
      double newDist = (point - this[i]).distance;
      if(shortestDistance == null){
        shortestDistance = newDist;
        closestIndex = i;
      } else if(newDist < shortestDistance){
          shortestDistance = newDist;
          closestIndex = i;
      } else{
        continue;
      }
    }
    if(shortestDistance != null){
      return closestIndex;
    } else{
      return null;
    }

  }
}

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
