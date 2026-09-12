import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

class ToolMatrixPayload {
  Matrix4 transform = Matrix4.identity();
  Offset panStartOrigin = Offset.zero;
  Offset focalPointAtStart = Offset.zero;
  double scaleStart = 1.0;
  double previousGestureScale = 1.0;

  Offset worldPivotAtStart = Offset.zero;

  double get currentScale => transform.getMaxScaleOnAxis();
}