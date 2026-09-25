part of 'draw_data.dart';

  extension DrawDataExtensions on DrawData{
  void draw(Canvas canvas){
    map(
      circle: (data) => _drawCircle(canvas, data), 
      freehand: (data) => _drawFreehand(canvas, data), 
      line: (data) => _drawLine(canvas, data), 
      path: (data) => _drawPath(canvas, data), 
      rectangle: (data) => _drawRectangle(canvas, data));
  }

  Rect getBounds(){
    return map(
      circle: (data) => Rect.fromCircle(center: data.center, radius: data.radius), 
      freehand: (data) => (Path()..addPolygon(data.points, false)).getBounds(),
      line: (data) => Rect.fromPoints(data.startPoint, data.endPoint), 
      path: (data) => (Path()..addPolygon(data.points, data.closed)).getBounds(), 
      rectangle: (data) => Rect.fromPoints(data.topLeft, data.botRight));
  }

  Rect getGroupBoundingBox(){
    return map(
      circle: (data) => Rect.fromCircle(center: data.center, radius: data.radius).inflate(10), 
      freehand: (data) => (Path()..addPolygon(data.points, false)).getBounds().inflate(10),
      line: (data) => Rect.fromPoints(data.startPoint, data.endPoint).inflate(10), 
      path: (data) => (Path()..addPolygon(data.points, data.closed)).getBounds().inflate(10), 
      rectangle: (data) => Rect.fromPoints(data.topLeft, data.botRight)).inflate(10);
  }

   Rect? getIndividualBoundingBox(){
    return map(
      circle: (data) => data.getGroupBoundingBox(),
      freehand: (data) => data.getGroupBoundingBox(),
      line: (data) => null,
      path: (data) => null,
      rectangle: (data) => data.getGroupBoundingBox()
      );
  }

  double getControlPointScale(double baseSize, double scale, double minThreshold){
    return map(
      circle: (data) {
        double size = (max(baseSize / scale,data.strokePaint.strokeWidth));
        if(data.radius - size > 0){
          return size;
        } else if(data.radius > minThreshold){
          return data.radius;
        } else{
          return minThreshold;
        }
      }, 
      freehand: (data) => data.getGroupBoundingBox().controlPointScale(scale, data.strokePaint.strokeWidth, baseSize, minThreshold), 
      line: (data) {
        double size = max(baseSize / scale, data.strokePaint.strokeWidth);
        double dist = (data.startPoint - data.endPoint).distance;
        if(dist - size > 0){

          return size;
        } else{

          return dist;
        }
        },
      path: (data){
        double size = max(baseSize / scale, data.strokePaint.strokeWidth);
        double dist = data.points.findSmallestDistance(minThreshold);

        print(data.points);

        if(dist - size > 0){
          return size;
        }
        return dist;
      }, 
      rectangle: (data) => 0);
  }

  

  

  List<Offset> getControlPoints(){
    return map(
      circle: (data) => data.getGroupBoundingBox().pointsToList(), 
      freehand: (data) => data.getGroupBoundingBox().pointsToList(), 
      line: (data) => [data.startPoint, data.endPoint], 
      path: (data) => data.points, 
      rectangle: (data) => data.getGroupBoundingBox().pointsToList());
  }

  bool checkPointCollision(Offset fromPoint, Offset toPoint, double otherRadius){

    
    return map(
      circle: (data) => _isPointInsideCircle(center: data.center, radius: data.radius, targetLineRadius: data.strokePaint.strokeWidth, filled: data.renderFill, stroked: data.renderStroke, otherRadius: otherRadius, otherPosition: toPoint), 
      freehand: (data) => data._points.length == 1 ? 
          _isPointInsidePoint(targetPoint: data._points[0], targetRadius: data.strokePaint.strokeWidth / 2, otherRadius: otherRadius, fromPoint: fromPoint, toPoint: toPoint) :
          _isPointInsideLine(borderPoints: data._points, targetLineRadius: data.strokePaint.strokeWidth / 2, otherRadius: otherRadius, fromPoint: fromPoint, toPoint: toPoint), 
      line: (data) => _isPointInsideLine(borderPoints: [data.startPoint, data.endPoint], targetLineRadius: data.strokePaint.strokeWidth / 2, otherRadius: otherRadius, fromPoint: fromPoint, toPoint: toPoint), 
      path: (data) {
        // 1. Safety optimization: If it doesn't have enough vertices to be valid, drop it early
        if (data._points.length < 2) return false;

        bool isHit = false;

        // 2. Check the Solid Interior Fill Zone
        // If the shape is filled (or explicitly un-stroked), run your ray-caster math
        if (data.renderFill || !data.renderStroke) {
          isHit = _isPointInsidePolygon(toPoint, data._points);
        }

        // 3. Check the Outer Line Boundary (Stroke thickness)
        // If the interior didn't hit but the shape renders an outline stroke,
        // run the line segment swipe check to see if the brush crossed the border line!
        if (!isHit && data.renderStroke) {
          isHit = _isPointInsideLine(
            borderPoints: data._points,
            targetLineRadius: data.strokePaint.strokeWidth / 2,
            otherRadius: otherRadius,
            fromPoint: fromPoint,
            toPoint: toPoint,
          );
        }

        return isHit;
      },
      rectangle: (data) => () {
          // Unroll variables cleanly 
          final RectVertices rectPoints = data.vertices;
          
          bool isHit = false;
          if (data.renderFill || !data.renderStroke) {
            isHit = _isPointInsideRectPolygon(toPoint, rectPoints);
          }
          if (!isHit && data.renderStroke) {
            isHit = _isPointOnRectStroke(
              rectPoints,
              data.strokePaint.strokeWidth / 2,
              otherRadius,
              fromPoint,
              toPoint,
            );
          }
          return isHit;
        }());
  }
}


typedef RectVertices = (Offset topLeft, Offset topRight, Offset botRight, Offset botLeft);

extension RectDataExtensions on RectData{
  List<Offset> tlBrToList(){
    return [topLeft, Offset(topLeft.dx, botRight.dy), botRight, Offset(botRight.dx, topLeft.dy)];
  }

    RectVertices get vertices => (
    topLeft,
    Offset(botRight.dx, topLeft.dy), // Top Right
    botRight,
    Offset(topLeft.dx, botRight.dy), // Bottom Left
  );

}