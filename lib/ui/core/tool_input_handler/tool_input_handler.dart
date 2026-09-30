import 'package:drawing_app/domain/models/tool_input_data/tool_input_data.dart';
import 'package:flutter/gestures.dart';



/// Abstract base class for handling input to be consumed by a [ToolController]. 
abstract class ToolInputHandler {

  Function(ToolStartInput toolInput) onToolPress;
  Function(ToolUpdateInput toolInput) onToolUpdate;
  Function(ToolReleasedInput toolInput) onToolRelease;

  Function(ToolStartInput toolInput) onPanStart;
  Function(ToolUpdateInput toolInput) onPanUpdate;
  Function(ToolReleasedInput toolInput) onPanEnd;

  Offset Function(Offset screenPoint) snappedScreenPointConverter;
  Offset Function(Offset screenPoint) unsnappedScreenPointConverter;

  late Matrix4 worldTransform;


  Offset lastScreenPoint = Offset.zero;
  int lastButtonsPressed = 0;
  PointerDeviceKind lastDeviceKind = PointerDeviceKind.unknown;
  int activePointerCount = 0;

  


  ToolInputHandler({required this.onToolPress, required this.onToolUpdate, required this.onToolRelease, required this.onPanStart, required this.onPanUpdate, required this.onPanEnd, required this.snappedScreenPointConverter, required this.unsnappedScreenPointConverter});

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

}


