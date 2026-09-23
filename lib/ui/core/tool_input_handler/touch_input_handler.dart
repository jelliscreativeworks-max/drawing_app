import 'package:drawing_app/domain/models/tool_input_data/tool_input_data.dart';
import 'package:drawing_app/ui/core/tool_input_handler/tool_input_handler.dart';
import 'package:flutter/gestures.dart';


class TouchInputHandler extends ToolInputHandler{
  TouchInputHandler({required super.onToolPress, required super.onToolUpdate, required super.onToolRelease, required super.onPanStart, required super.onPanUpdate, required super.onPanEnd});

  final Set<int> _activePointers = {};
  bool get _shouldPan => _activePointers.length > 1;
  bool panOverride = false;
  bool started = false;


// TODO: Need tools to be canceled properly when overriding pan 
  @override
  void onScaleStart(ScaleStartDetails details) {
    if(started) return;
    lastDeviceKind = PointerDeviceKind.touch;
    lastScreenPoint = details.localFocalPoint;
    activePointerCount = details.pointerCount;
        ToolStartInput startInput = ToolStartInput.compute(
      kind: details.kind ?? lastDeviceKind, 
      rawScreenPoint: details.localFocalPoint, 
        screenToWorldConverter: (screenPoint) => screenToWorld(screenPoint)
      );
      started = true;
     
      onToolPress(startInput);
    

  }

  @override
  void onScaleUpdate(ScaleUpdateDetails details) {
    if(!started) return;
    lastDeviceKind = PointerDeviceKind.touch;

    ToolUpdateInput updateInput = ToolUpdateInput.compute(kind: lastDeviceKind, currentScreenPoint: details.localFocalPoint, currentScale: details.scale,   screenToWorldConverter: (screenPoint) => screenToWorld(screenPoint), lastScreenPoint: lastScreenPoint);
    lastScreenPoint = details.localFocalPoint;


    if(_shouldPan && !panOverride){
      panOverride = true;
      onPanStart(ToolStartInput.compute(kind: lastDeviceKind, rawScreenPoint: details.localFocalPoint,  screenToWorldConverter: (screenPoint) => screenToWorld(screenPoint)));
    } else if(panOverride){
      onPanUpdate(updateInput);
    } else{
      onToolUpdate(updateInput);
    }


  }

    @override
  void onScaleEnd(ScaleEndDetails details) {
    if(!started) return;
    lastDeviceKind = PointerDeviceKind.touch;
    activePointerCount = details.pointerCount;
    final releasedInput = ToolReleasedInput(lastUsedDevice: lastDeviceKind);

    if(panOverride){
      onPanEnd(releasedInput);
      panOverride = false;
    } else{
    onToolRelease(releasedInput);
    }

    started = false;

  }

  @override
  void onPointerDown(PointerDownEvent event) =>_activePointers.add(event.pointer);

  @override
  void onPointerUp(PointerUpEvent event) => _activePointers.remove(event.pointer);

  @override
  void onPointerCancel(PointerCancelEvent event) => _activePointers.remove(event.pointer);
  

  @override
  void disableInput() {
    started = false;
    _activePointers.clear();
    panOverride = false;
  }
  
}