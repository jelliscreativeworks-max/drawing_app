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

  bool checkPointCollision(Offset fromPoint, Offset toPoint, double otherRadius){

    
    return map(
      circle: (data) => _isPointInsideCircle(center: data.center, radius: data.radius, targetLineRadius: data.strokePaint.strokeWidth, filled: data.renderFill, stroked: data.renderStroke, otherRadius: otherRadius, otherPosition: toPoint), 
      freehand: (data) => data._points.length == 1 ? 
          _isPointInsidePoint(targetPoint: data._points[0], targetRadius: data.strokePaint.strokeWidth / 2, otherRadius: otherRadius, fromPoint: fromPoint, toPoint: toPoint) :
          _isPointInsideLine(borderPoints: data._points, targetLineRadius: data.strokePaint.strokeWidth / 2, otherRadius: otherRadius, fromPoint: fromPoint, toPoint: toPoint), 
      line: (data) => _isPointInsideLine(borderPoints: [data.startPoint, data.endPoint], targetLineRadius: data.strokePaint.strokeWidth / 2, otherRadius: otherRadius, fromPoint: fromPoint, toPoint: toPoint), 
      path: (data) => data.closed || !data.renderStroke ? _isPointInsidePolygon(toPoint, data._points) : _isPointInsideLine(borderPoints: data._points, targetLineRadius: data.strokePaint.strokeWidth / 2, otherRadius: otherRadius, fromPoint: fromPoint, toPoint: toPoint), 
      rectangle: (data) => !data.renderStroke || data.renderFill ? _isPointInsidePolygon(toPoint, data.tlBrToList()) : _isPointInsideLine(borderPoints: data.tlBrToList(), targetLineRadius: data.strokePaint.strokeWidth / 2, otherRadius: otherRadius, fromPoint: fromPoint, toPoint: toPoint));
  }
}

extension RectDataExtensions on RectData{
  List<Offset> tlBrToList(){
    return [topLeft, Offset(topLeft.dx, botRight.dy), botRight, Offset(botRight.dx, topLeft.dy)];
  }

}