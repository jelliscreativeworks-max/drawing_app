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

  bool hasSamePropertiesAsOther(DrawData other){
    if(runtimeType != other.runtimeType) return false;

   return map(
      circle: (current) {
        final otherCircle = other as CircleData;
        return current.center == otherCircle.center &&
               current.radius == otherCircle.radius;
      },
      freehand: (current) {
        final otherFreehand = other as FreehandData;
        // Pointer check first for performance, then check individual points
        if (identical(current.points, otherFreehand.points)) return true;
        if (current.points.length != otherFreehand.points.length) return false;
        
        for (int i = 0; i < current.points.length; i++) {
          if (current.points[i] != otherFreehand.points[i]) return false;
        }
        return true;
      },
      line: (current) {
        final otherLine = other as LineData;
        return current.startPoint == otherLine.startPoint &&
               current.endPoint == otherLine.endPoint;
      },
      path: (current) {
        final otherPath = other as PathData;
        if (identical(current.points, otherPath.points)) return true;
        if (current.points.length != otherPath.points.length) return false;
        
        for (int i = 0; i < current.points.length; i++) {
          if (current.points[i] != otherPath.points[i]) return false;
        }
        return current.closed == otherPath.closed;
      },
      rectangle: (current) {
        final otherRect = other as RectData;
        return current.topLeft == otherRect.topLeft &&
               current.botRight == otherRect.botRight;
      },
    );
  }

  Rect getBounds(){
    return map(
      circle: (data) => Rect.fromCircle(center: data.center, radius: data.radius), 
      freehand: (data) => (Path()..addPolygon(data.points, false)).getBounds(),
      line: (data) => Rect.fromPoints(data.startPoint, data.endPoint), 
      path: (data) => (Path()..addPolygon(data.points, data.closed)).getBounds(), 
      rectangle: (data) => Rect.fromPoints(data.topLeft, data.botRight));
  }

  DrawData scaleRelativeToAnchor(double sx, double sy, Offset anchor) {
    // Local helper to scale any individual point relative to the anchor
    Offset scalePoint(Offset p) {
      return Offset(
        anchor.dx + (p.dx - anchor.dx) * sx,
        anchor.dy + (p.dy - anchor.dy) * sy,
      );
    }

    return map(
            circle: (current) {
        final Offset newCenter = scalePoint(current.center);
        
        // 🌟 THE BOUNDARY FIX: Determine what kind of stretch is happening
        double uniformScale = 1.0;
        
        if (sx == 1.0) {
          // Pure Vertical Drag (Handles 1 & 5): Scale radius exclusively by sy
          uniformScale = sy.abs();
        } else if (sy == 1.0) {
          // Pure Horizontal Drag (Handles 3 & 7): Scale radius exclusively by sx
          uniformScale = sx.abs();
        } else {
          // Corner Diagonal Drag (Handles 0, 2, 4, 6): Use the proportional average 
          uniformScale = (sx.abs() + sy.abs()) / 2.0;
        }

        return current.copyWith(
          center: newCenter,
          radius: current.radius * uniformScale,
        );
      },

      freehand: (current) => current.copyWith(
        points: current.points.map(scalePoint).toList(),
      ),
      line: (current) => current.copyWith(
        startPoint: scalePoint(current.startPoint),
        endPoint: scalePoint(current.endPoint),
      ),
      path: (current) => current.copyWith(
        points: current.points.map(scalePoint).toList(),
      ),
      rectangle: (current) {
        final Offset newTopLeft = scalePoint(current.topLeft);
        final Offset newBotRight = scalePoint(current.botRight);
        
        // Ensure topLeft stays top-left and botRight stays bottom-right if scaled negatively
        return current.copyWith(
          topLeft: Offset(min(newTopLeft.dx, newBotRight.dx), min(newTopLeft.dy, newBotRight.dy)),
          botRight: Offset(max(newTopLeft.dx, newBotRight.dx), max(newTopLeft.dy, newBotRight.dy)),
        );
      },
    );
  }

DrawData translate(Offset delta) {
    return map(
      circle: (current) => current.copyWith(
        center: current.center + delta,
      ),
      freehand: (current) => current.copyWith(
        // Map over every individual raw point in the line sketch layout array
        points: current.points.map((point) => point + delta).toList(),
      ),
      line: (current) => current.copyWith(
        startPoint: current.startPoint + delta,
        endPoint: current.endPoint + delta,
      ),
      path: (current) => current.copyWith(
        points: current.points.map((point) => point + delta).toList(),
      ),
      rectangle: (current) => current.copyWith(
        topLeft: current.topLeft + delta,
        botRight: current.botRight + delta,
      ),
    );
  }

DrawData applyNodeTransformation((int index, Offset nodePosition) activeNode, Offset mousePosition, Offset anchorPointPosition){
    return map(
      circle: (data){
        int nodeIndex = activeNode.$1;

        bool isCorner = nodeIndex == 0 || nodeIndex == 2 || nodeIndex == 4 || nodeIndex == 6;

        if (isCorner) {
          // 1. Get the exact 45-degree angle line this corner handle travels on
          Offset initialDiagonalVector = activeNode.$2 - anchorPointPosition;
          if (initialDiagonalVector.distance == 0) return data;
          Offset diagonalDirection = initialDiagonalVector / initialDiagonalVector.distance;

          // 2. Project the mouse cursor directly onto that 45-degree line
          Offset mouseFromAnchor = mousePosition - anchorPointPosition;
          double projectedDistance = (mouseFromAnchor.dx * diagonalDirection.dx) + 
                                     (mouseFromAnchor.dy * diagonalDirection.dy);

          // 3. Determine if we are scaling positively or flipped negatively across the anchor
          bool isNegativeScale = projectedDistance < 0;

          // 4. Strip away the 20px padding correctly based on direction
          double rawDiagonalLength;
          if (!isNegativeScale) {
            rawDiagonalLength = projectedDistance - 20.0;
            if (rawDiagonalLength < 0) rawDiagonalLength = 0; // Prevent deadzone jitter
          } else {
            rawDiagonalLength = projectedDistance + 20.0;
            if (rawDiagonalLength > 0) rawDiagonalLength = 0; 
          }

          // Convert to an absolute scale size for calculating dimensions
          double absoluteRawDiagonal = rawDiagonalLength.abs();

          // 5. Calculate the dynamic operational direction (flips if negative)
          Offset currentDirection = isNegativeScale ? -diagonalDirection : diagonalDirection;

          // 6. Derive true geometric edges from the stationary anchor point position
          Offset rawAnchorPoint = anchorPointPosition + (currentDirection * 10.0);
          Offset center = rawAnchorPoint + (currentDirection * (absoluteRawDiagonal * 0.5));

          // 7. Calculate true radius from the side length
          double boxSideLength = absoluteRawDiagonal / 1.41421356;
          double radius = boxSideLength * 0.5;

          return data.copyWith(center: center, radius: radius);
        } else {
          // Side Dragging (Stays centered and locked)
          double targetRadiusWithPadding = (data.center - mousePosition).distance;
          double radius = targetRadiusWithPadding - 10.0;
          if (radius < 0) radius = 0;

          return data.copyWith(center: data.center, radius: radius);
        }
      }, 
      

      // Matches the bounding box style using the stationary anchor point position
            rectangle: (data) {
        int nodeIndex = activeNode.$1;
        
        // Custom 8-node bounding layout assumption:
        // 0: TopLeft, 1: TopCenter, 2: TopRight, 3: RightCenter, 
        // 4: BottomRight, 5: BottomCenter, 6: BottomLeft, 7: LeftCenter
        
        // Extract the anchor coordinates (the opposite static boundary corner/edge)
        double staticX = anchorPointPosition.dx;
        double staticY = anchorPointPosition.dy;
        
        // Track the newly modified coordinates initialized to the current mouse state
        double targetX = mousePosition.dx;
        double targetY = mousePosition.dy;

        //Anchor to existing properties for side-handles to prevent collapsing
        switch (nodeIndex) {
          case 1: // TopCenter (Modifying Top Edge only)
          case 5: // BottomCenter (Modifying Bottom Edge only)
            // Lock X-axis variations to match the existing shape's absolute current width
            staticX = data.topLeft.dx;
            targetX = data.botRight.dx;
            break;
            
          case 3: // RightCenter (Modifying Right Edge only)
          case 7: // LeftCenter (Modifying Left Edge only)
            // Lock Y-axis variations to match the existing shape's absolute current height
            staticY = data.topLeft.dy;
            targetY = data.botRight.dy;
            break;
            
          default:
            // Corners (0, 2, 4, 6) use the generic opposite structural point mapping
            break;
        }

        // Re-compile bounding box corners dynamically based on spatial quadrants 
        Offset topLeft = Offset(min(staticX, targetX), min(staticY, targetY));
        Offset botRight = Offset(max(staticX, targetX), max(staticY, targetY));

        return data.copyWith(topLeft: topLeft, botRight: botRight);
      },

      
      // 🌟 LINE IMPLEMENTATION
      // A line has exactly 2 node points (0: StartPoint, 1: EndPoint). 
      // Whichever node isn't selected automatically acts as the stationary anchor.
      line: (data) {
        int nodeIndex = activeNode.$1;
        
        if (nodeIndex == 0) {
          // Dragging the line origin point, while the end point remains stationary
          return data.copyWith(startPoint: mousePosition);
        } else {
          // Dragging the line endpoint, while the origin remains stationary
          return data.copyWith(endPoint: mousePosition);
        }
      },

            // 🌟 STABILIZED ABSOLUTE FREEHAND SCALING & QUADRANT FLIPPING
      freehand: (data) {
        int nodeIndex = activeNode.$1;

        // 1. Calculate the initial static width and height spans at click-time relative to the anchor position
        double originalWidth = (activeNode.$2.dx - anchorPointPosition.dx).abs();
        double originalHeight = (activeNode.$2.dy - anchorPointPosition.dy).abs();
        final double safeOriginalWidth = originalWidth == 0 ? 1.0 : originalWidth;
        final double safeOriginalHeight = originalHeight == 0 ? 1.0 : originalHeight;

        // 2. Compute your live absolute target dimensions relative to the stationary pivot anchor
        double targetWidth = (mousePosition.dx - anchorPointPosition.dx).abs();
        double targetHeight = (mousePosition.dy - anchorPointPosition.dy).abs();

        // 3. Compute absolute scale factors relative to the starting gesture dimensions
        double sx = targetWidth / safeOriginalWidth;
        double sy = targetHeight / safeOriginalHeight;

        // 4. Directional Quadrant Checks: Determine target flipping state purely from mouse position
        final bool isXFlipped = (mousePosition.dx < anchorPointPosition.dx) != (activeNode.$2.dx < anchorPointPosition.dx);
        final bool isYFlipped = (mousePosition.dy < anchorPointPosition.dy) != (activeNode.$2.dy < anchorPointPosition.dy);
        
        if (isXFlipped) sx = -sx;
        if (isYFlipped) sy = -sy;

        // 5. SIDE HANDLE LOCK: Protect the non-active axis explicitly from side-drags
        // 0: TL, 1: TC, 2: TR, 3: RC, 4: BR, 5: BC, 6: BL, 7: LC
        if (nodeIndex == 1 || nodeIndex == 5) sx = 1.0;
        if (nodeIndex == 3 || nodeIndex == 7) sy = 1.0;

        // 6. Map over the raw points list natively relative to the stationary anchor point position
        final List<Offset> transformedPoints = data.points.map((p) {
          return Offset(
            anchorPointPosition.dx + (p.dx - anchorPointPosition.dx) * sx,
            anchorPointPosition.dy + (p.dy - anchorPointPosition.dy) * sy,
          );
        }).toList();

        return data.copyWith(points: transformedPoints);
      },






      // 🌟 PATH: Pure vertex substitution mapping
      path: (data) {
        int nodeIndex = activeNode.$1;
        
        if (nodeIndex >= 0 && nodeIndex < data.points.length) {
          final List<Offset> updatedPoints = List<Offset>.from(data.points);
          updatedPoints[nodeIndex] = mousePosition;
          
          return data.copyWith(points: updatedPoints);
        }
        return data;
      }
    );
}










  Offset getAnchorForSelectedNode(int nodeIndex){
    return map(
      circle: (data) => data.getRawControlPoints()[_getOppositeNodeInRect(nodeIndex)]!,
    
      freehand: (data) => data.getRawControlPoints()[_getOppositeNodeInRect(nodeIndex)]!, 
      line: (data){
        if(nodeIndex == 1){
          return data.startPoint;
        } else if(nodeIndex == 0){
          return data.endPoint;
        } else{
          return Offset.zero;
        }
       
      },
          path: (data) {
        if (nodeIndex >= 0 && nodeIndex < data.points.length) {
          return data.points[nodeIndex];
        }
        return Offset.zero;
      },

      rectangle: (data) => data.getRawControlPoints()[_getOppositeNodeInRect(nodeIndex)]!);
  }

    int _getOppositeNodeInRect(int referencePointIndex){
    int refClamped = referencePointIndex.clamp(0, 7);

    int index = switch(refClamped){
      0 => 4,
      1 => 5,
      2 => 6,
      3 => 7,
      4 => 0,
      5 => 1,
      6 => 2,
      7 => 3,
      int() => throw UnimplementedError(),
    };

    return index;
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


        if(dist - size > 0){
          return size;
        }
        return dist;
      }, 
      rectangle: (data) => data.getGroupBoundingBox().controlPointScale(scale, data.strokePaint.strokeWidth, baseSize, minThreshold));
  }

  

  Map<int, Offset> getRawControlPoints() {
  return map(
    circle: (data) => data.getBounds().pointsToList().asMap(), 
    freehand: (data) => data.getBounds().pointsToList().asMap(), 
    line: (data) => [data.startPoint, data.endPoint].asMap(), 
    path: (data) => data.points.asMap(), 
    rectangle: (data) => data.getBounds().pointsToList().asMap(),
  );
}

  Map<int, Offset> getControlPoints(){
    return map(
      circle: (data) =>  data.getGroupBoundingBox().pointsToList().asMap(), 
      freehand: (data) => data.getGroupBoundingBox().pointsToList().asMap(), 
      line: (data) => [data.startPoint, data.endPoint].asMap(), 
      path: (data) => data.points.asMap(), 
      rectangle: (data) => data.getGroupBoundingBox().pointsToList().asMap());
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