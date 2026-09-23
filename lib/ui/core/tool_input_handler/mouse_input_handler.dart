import 'package:drawing_app/domain/models/tool_input_data/tool_input_data.dart';
import 'package:drawing_app/ui/core/tool_input_handler/tool_input_handler.dart';
import 'package:flutter/gestures.dart';

class MouseInputHandler extends ToolInputHandler {


  MouseInputHandler({required super.onToolPress, required super.onToolUpdate, required super.onToolRelease, required super.onPanStart, required super.onPanUpdate, required super.onPanEnd});

  /// All scale event functions are meant to be primary mouse button only. The pointerdown is still used but only to set the pointer device last kind and button int
  @override
  void onScaleStart(ScaleStartDetails details) {
    if(lastButtonsPressed != kPrimaryMouseButton || activePointerCount > 1) return;
    lastScreenPoint = details.localFocalPoint;
    activePointerCount = details.pointerCount;
        ToolStartInput startInput = ToolStartInput.compute(
      kind: details.kind ?? lastDeviceKind, 
      rawScreenPoint: details.localFocalPoint, 
      screenToWorldConverter: (screenPoint) => screenToWorld(screenPoint)
      );
      onToolPress(startInput);

  }


  @override
  void onScaleUpdate(ScaleUpdateDetails details) {
    if(lastButtonsPressed != kPrimaryMouseButton || activePointerCount > 1){
      return;
    }

    activePointerCount = details.pointerCount;
    ToolUpdateInput updateInput = ToolUpdateInput.compute(kind: lastDeviceKind,currentScreenPoint: details.localFocalPoint, currentScale: 1.0,   screenToWorldConverter: (screenPoint) => screenToWorld(screenPoint), lastScreenPoint: lastScreenPoint);
    lastScreenPoint = details.localFocalPoint;
    onToolUpdate(updateInput);
    
  }

  @override
  void onScaleEnd(ScaleEndDetails details) {
    activePointerCount = details.pointerCount;
    final releasedInput = ToolReleasedInput(lastUsedDevice: lastDeviceKind);

    onToolRelease(releasedInput);

  }

  /// All pointer event functions are meant to secondary Input. This is to deal with the issue of pointer events not tracking pointer count
  /// and not also not tracking pointer up and down events reliably. If you press another mouse button while currently holding another it does not detect
  /// a pointer down or up event untill all buttons are released

  @override
  void onPointerDown(PointerDownEvent event) {
    lastButtonsPressed = event.buttons;
    lastDeviceKind = event.kind;
    if(event.buttons != kMiddleMouseButton) return;
    lastScreenPoint = event.localPosition;
    activePointerCount = 1;
    ToolStartInput startInput = ToolStartInput.compute(
      kind: event.kind, 
      rawScreenPoint: event.localPosition, 
      screenToWorldConverter: (screenPoint) => screenToWorld(screenPoint)
      );
      onPanStart(startInput);
  }
  @override
  void onPointerMove(PointerMoveEvent event) {
    if(lastButtonsPressed != kMiddleMouseButton) return;
    activePointerCount = 1;
    ToolUpdateInput updateInput = ToolUpdateInput.compute(kind: event.kind, currentScreenPoint: event.localPosition, currentScale: 1.0,   screenToWorldConverter: (screenPoint) => screenToWorld(screenPoint),lastScreenPoint: lastScreenPoint);
    lastScreenPoint = event.localPosition;
    onPanUpdate(updateInput);
  }

  @override
  void onPointerUp(PointerUpEvent event) {
    if(lastButtonsPressed != kMiddleMouseButton) return;
    activePointerCount = 0;
    final releasedInput = ToolReleasedInput(lastUsedDevice: event.kind);
    onPanEnd(releasedInput);
  }

  @override
  void onPointerCancel(PointerCancelEvent event) {
    if(event.buttons != kMiddleMouseButton) return;
     activePointerCount = 0;
    final releasedInput = ToolReleasedInput(lastUsedDevice: event.kind);

    onPanEnd(releasedInput);

  }

  @override
  void onPointerSignal(PointerSignalEvent event) {
    if(event is PointerScrollEvent){
         ToolStartInput startInput = ToolStartInput.compute(
      kind: event.kind, 
      rawScreenPoint: event.localPosition, 
      screenToWorldConverter: (screenPoint) => screenToWorld(screenPoint)
      );

          
      onPanStart(startInput);
      ToolUpdateInput updateInput = ToolUpdateInput.compute(kind: lastDeviceKind,currentScreenPoint: event.localPosition, currentScale: 1 - event.scrollDelta.dy.sign * 0.25,   screenToWorldConverter: (screenPoint) => screenToWorld(screenPoint), lastScreenPoint: lastScreenPoint, customDelta: Offset.zero);
      onPanUpdate(updateInput);


      final releasedInput = ToolReleasedInput(lastUsedDevice: event.kind);
      onPanEnd(releasedInput);
    }
  }


  @override
  void disableInput() {
    activePointerCount = 0;
  }


}
