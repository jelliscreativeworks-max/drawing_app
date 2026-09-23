import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:drawing_app/domain/models/tool_input_data/tool_input_data.dart';
import 'package:drawing_app/ui/core/tool_input_handler/tool_input_handler.dart';

class TouchInputHandler extends ToolInputHandler {
  TouchInputHandler({
    required super.onToolPress,
    required super.onToolUpdate,
    required super.onToolRelease,
    required super.onPanStart,
    required super.onPanUpdate,
    required super.onPanEnd,
  });

  final Set<int> _activePointers = {};
  bool get _shouldPan => _activePointers.length > 1;
  bool panOverride = false;
  bool started = false;

  Timer? _toolPressDebounceTimer;
  bool _isToolPressPending = false;
  ToolStartInput? _pendingStartInput;

  @override
  void onScaleStart(ScaleStartDetails details) {
    if (started) return;
    lastDeviceKind = PointerDeviceKind.touch;
    lastScreenPoint = details.localFocalPoint;
    activePointerCount = details.pointerCount;
    started = true;

    final ToolStartInput startInput = ToolStartInput.compute(
      kind: details.kind ?? lastDeviceKind, 
      rawScreenPoint: details.localFocalPoint, 
      screenToWorldConverter: (screenPoint) => screenToWorld(screenPoint),
    );

    if (details.pointerCount > 1 || _shouldPan) {
      _cancelPendingToolPress();
      panOverride = true;
      onPanStart(startInput);
      return;
    }

    _cancelPendingToolPress();
    _pendingStartInput = startInput;
    _isToolPressPending = true;

    _toolPressDebounceTimer = Timer(const Duration(milliseconds: 25), () {
      if (_isToolPressPending && _pendingStartInput != null && !panOverride) {
        onToolPress(_pendingStartInput!);
        _isToolPressPending = false;
        _pendingStartInput = null;
      }
    });
  }

  @override
  void onScaleUpdate(ScaleUpdateDetails details) {
    if (!started) return;
    lastDeviceKind = PointerDeviceKind.touch;

    // Check if a second touch is actively trying to interrupt the window mid-flight
    if (_checkMidFlightPan(details.localFocalPoint)) return;

    final ToolUpdateInput updateInput = ToolUpdateInput.compute(
      kind: lastDeviceKind, 
      currentScreenPoint: details.localFocalPoint, 
      currentScale: details.scale,   
      screenToWorldConverter: (screenPoint) => screenToWorld(screenPoint), 
      lastScreenPoint: lastScreenPoint,
    );
    lastScreenPoint = details.localFocalPoint;

    if (panOverride) {
      onPanUpdate(updateInput);
    } else {
      if (!_isToolPressPending) {
        onToolUpdate(updateInput);
      }
    }
  }

  bool _checkMidFlightPan(Offset focalPoint) {
    if (_shouldPan && !panOverride) {
      _cancelPendingToolPress(); 
      panOverride = true;
      
      onPanStart(ToolStartInput.compute(
        kind: lastDeviceKind, 
        rawScreenPoint: focalPoint,  
        screenToWorldConverter: (screenPoint) => screenToWorld(screenPoint),
      ));
      return true;
    }
    return false;
  }

  @override
  void onScaleEnd(ScaleEndDetails details) {
    if (!started) return;
    lastDeviceKind = PointerDeviceKind.touch;
    activePointerCount = details.pointerCount;
    final releasedInput = ToolReleasedInput(lastUsedDevice: lastDeviceKind);

    _cancelPendingToolPress();

    if (panOverride) {
      onPanEnd(releasedInput);
      panOverride = false;
    } else {
      // Only execute tool releases if the tool was actually allowed to press down
      if (!_isToolPressPending) {
        onToolRelease(releasedInput);
      }
    }

    started = false;
  }

  @override
  void onPointerDown(PointerDownEvent event) {
    _activePointers.add(event.pointer);
    // If a secondary pointer registers raw, immediately choke any drawing triggers
    if (_activePointers.length > 1) {
      _cancelPendingToolPress();
    }
  }

  @override
  void onPointerUp(PointerUpEvent event) => _activePointers.remove(event.pointer);

  @override
  void onPointerCancel(PointerCancelEvent event) => _activePointers.remove(event.pointer);

  @override
  void disableInput() {
    _cancelPendingToolPress();
    started = false;
    _activePointers.clear();
    panOverride = false;
  }

  void _cancelPendingToolPress() {
    _toolPressDebounceTimer?.cancel();
    _toolPressDebounceTimer = null;
    _isToolPressPending = false;
    _pendingStartInput = null;
  }
}
