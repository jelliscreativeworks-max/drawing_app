part of 'draw_data.dart';

/// Ray-casting algorithm for Point-in-Polygon evaluation.
/// Determines if an eraser position lands entirely inside a fill region shape.
bool _isPointInsidePolygon(Offset otherPosition, List<Offset> targetPolygon) {
  if(targetPolygon.length < 4) throw RangeError.range(targetPolygon.length, 4, null);
  int intersectCount = 0;
  for (int i = 0; i < targetPolygon.length; i++) {
    final Offset next = targetPolygon[(i + 1) % targetPolygon.length];
    final Offset curr = targetPolygon[i];

    if (((curr.dy > otherPosition.dy) != (next.dy > otherPosition.dy)) &&
        (otherPosition.dx <
            (next.dx - curr.dx) *
                    (otherPosition.dy - curr.dy) /
                    (next.dy - curr.dy) +
                curr.dx)) {
      intersectCount++;
    }
  }
  return intersectCount % 2 != 0;
}

bool _isPointInsidePoint({
  required Offset targetPoint,
  required double targetRadius,
  required double otherRadius,
  required Offset fromPoint,
  required Offset toPoint,
}) {
  // Extract the thickness of the dot, defaulting to a standard baseline if null

  final double combinedThreshold = otherRadius * 2 + (targetRadius);

  // Calculate the shortest distance from the single dot to the eraser's swipe segment line
  final double distanceToSwipe = _pointToSegmentDistance(
    targetPoint,
    fromPoint,
    toPoint,
  );

  if (distanceToSwipe <= combinedThreshold) {
    return true;
  } else {
    return false;
  }
}

bool _isPointInsideCircle({
  required Offset center,
  required double radius,
  required double targetLineRadius,
  required bool filled,
  required bool stroked,
  required double otherRadius,
  required Offset otherPosition,
}) {
  final double distanceToCenter = (otherPosition - center).distance;

  if (filled) {
    bool insideFill = distanceToCenter <= (radius + (otherRadius));
    if (insideFill) return true;
  }

  if (stroked) {
    final double distanceToPerimeter = (distanceToCenter - radius).abs();
    final double collisionTolerance = (targetLineRadius) + (otherRadius);

    return distanceToPerimeter <= collisionTolerance;
  }

  return false;
}

/// Ray-casting algorithm adapted for high-performance structural tuple vertices.
bool _isPointInsideRectPolygon(Offset otherPosition, RectVertices vertices) {
  // Unpack the four corners instantly without list iterations
  final (v0, v1, v2, v3) = vertices;
  final edges = [v0, v1, v2, v3]; 
  
  int intersectCount = 0;
  for (int i = 0; i < 4; i++) {
    final Offset curr = edges[i];
    final Offset next = edges[(i + 1) % 4];

    if (((curr.dy > otherPosition.dy) != (next.dy > otherPosition.dy)) &&
        (otherPosition.dx <
            (next.dx - curr.dx) *
                    (otherPosition.dy - curr.dy) /
                    (next.dy - curr.dy) +
                curr.dx)) {
      intersectCount++;
    }
  }
  return intersectCount % 2 != 0;
}

/// Boundary segment inspector adapted for structural tuple vertices.
bool _isPointOnRectStroke(
  RectVertices vertices,
  double targetLineRadius,
  double otherRadius,
  Offset fromPoint,
  Offset toPoint,
) {
  final (v0, v1, v2, v3) = vertices;
  final edges = [v0, v1, v2, v3];
  final double combinedBrushRadius = otherRadius * 2 + targetLineRadius;

  for (int i = 0; i < 4; i++) {
    if (_intersects(fromPoint, toPoint, edges[i], edges[(i + 1) % 4], combinedBrushRadius)) {
      return true;
    }
  }
  return false;
}


bool _isPointInsideLine({
  required List<Offset> borderPoints,
  required double targetLineRadius,
  required double otherRadius,
  required Offset fromPoint,
  required Offset toPoint,
}) {
  if(borderPoints.length < 2) {throw RangeError.range(borderPoints.length, 2, null);}
  for (int s = 0; s < borderPoints.length - 1; s++) {
    final Offset v1 = borderPoints[s];
    final Offset v2 = borderPoints[s + 1];

    final double combinedBrushRadius = otherRadius * 2 + targetLineRadius;

    if (_intersects(fromPoint, toPoint, v1, v2, combinedBrushRadius)) {
      return true;
    }
  }

  return false;
}

bool _intersects(
  Offset p1,
  Offset p2,
  Offset v1,
  Offset v2,
  double combinedRadius,
) {
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

/// Calculates the shortest absolute distance from a standalone point [pt]
/// to a finite line segment traveling between [v] and [w].
double _pointToSegmentDistance(Offset pt, Offset v, Offset w) {
  // 1. Calculate the finite length squared of the segment path line
  final double l2 =
      (v.dx - w.dx) * (v.dx - w.dx) + (v.dy - w.dy) * (v.dy - w.dy);

  // If v and w are the exact same point, simply return the direct 2D distance
  if (l2 == 0) return (pt - v).distance;

  // 2. Determine the projection scalar parameter clipped tightly to the finite segment bounds [0, 1]
  final double t = max(
    0,
    min(
      1,
      ((pt.dx - v.dx) * (w.dx - v.dx) + (pt.dy - v.dy) * (w.dy - v.dy)) / l2,
    ),
  );

  // 3. Extrapolate the exact coordinates of the closest point on the segment
  final Offset projection = Offset(
    v.dx + t * (w.dx - v.dx),
    v.dy + t * (w.dy - v.dy),
  );

  // Return the straight distance vector from our point to that projection node
  return (pt - projection).distance;
}
