import 'package:drawing_app/domain/models/tool_input_data/tool_input_data.dart';
import 'package:flutter/gestures.dart';
import 'package:vector_math/vector_math_64.dart' as vm;



/// Abstract base class for handling input to be consumed by a [ToolController]. 
abstract class ToolInputHandler {

  Function(ToolStartInput toolInput) onToolPress;
  Function(ToolUpdateInput toolInput) onToolUpdate;
  Function(ToolReleasedInput toolInput) onToolRelease;

  Function(ToolStartInput toolInput) onPanStart;
  Function(ToolUpdateInput toolInput) onPanUpdate;
  Function(ToolReleasedInput toolInput) onPanEnd;

  late Matrix4 worldTransform;


  Offset lastScreenPoint = Offset.zero;
  int lastButtonsPressed = 0;
  PointerDeviceKind lastDeviceKind = PointerDeviceKind.unknown;
  int activePointerCount = 0;

  


  ToolInputHandler({required this.onToolPress, required this.onToolUpdate, required this.onToolRelease, required this.onPanStart, required this.onPanUpdate, required this.onPanEnd});

  void handleEvent<T>(T event, Matrix4 payload){
    worldTransform = payload;

    switch(event){
      case PointerDownEvent():
        onPointerDown(event);
      case PointerUpEvent():
        onPointerUp(event);
      case PointerMoveEvent():
        onPointerMove(event);
      case PointerCancelEvent():
        onPointerCancel(event);
      case PointerPanZoomStartEvent():
        onPointerPanZoomStart(event);
      case PointerPanZoomUpdateEvent():
        onPointerPanZoomUpdate(event);
      case PointerPanZoomEndEvent():
        onPointerPanZoomEnd(event);
      case ScaleStartDetails():
        onScaleStart(event);
      case ScaleUpdateDetails():
        onScaleUpdate(event);
      case ScaleEndDetails():
        onScaleEnd(event);
      case PointerSignalEvent():
        onPointerSignal(event);
    }
  }

  void onPointerDown(PointerDownEvent event) {}
  void onPointerUp(PointerUpEvent event) {}
  void onPointerMove(PointerMoveEvent event) {}
  void onPointerCancel(PointerCancelEvent event) {}

  void onPointerPanZoomStart(PointerPanZoomStartEvent event) {}
  void onPointerPanZoomUpdate(PointerPanZoomUpdateEvent event) {}
  void onPointerPanZoomEnd(PointerPanZoomEndEvent event) {}

  void onScaleStart(ScaleStartDetails details) {}
  void onScaleUpdate(ScaleUpdateDetails details) {}
  void onScaleEnd(ScaleEndDetails details) {}
  
  void onPointerSignal(PointerSignalEvent event){}

  void disableInput();

  
  Offset screenToWorld(Offset screenPoint) {
    final Matrix4 transformMatrix = worldTransform;

    // Invert the camera transformation matrix to reverse the painter's shift
    final Matrix4 inverted = Matrix4.copy(transformMatrix)..invert();

    // Cast the 2D offset into a 4D vector space calculation block
    final vm.Vector4 screenVector = vm.Vector4(
      screenPoint.dx,
      screenPoint.dy,
      0.0,
      1.0,
    );
    final vm.Vector4 worldVector = inverted.transform(screenVector);

    return Offset(worldVector.x, worldVector.y);
  }
}


