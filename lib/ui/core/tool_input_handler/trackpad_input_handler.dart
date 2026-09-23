import 'package:drawing_app/domain/models/tool_input_data/tool_input_data.dart';
import 'package:drawing_app/ui/core/tool_input_handler/tool_input_handler.dart';
import 'package:flutter/gestures.dart';

class TrackpadInputHandler extends ToolInputHandler {
  TrackpadInputHandler({
    required super.onToolPress,
    required super.onToolUpdate,
    required super.onToolRelease,
    required super.onPanStart,
    required super.onPanUpdate,
    required super.onPanEnd,
    required super.screenPointConverter
  });

  @override
  void onPointerPanZoomStart(PointerPanZoomStartEvent event) {
    final ToolStartInput input = ToolStartInput.compute(
      kind: PointerDeviceKind.trackpad,
      rawScreenPoint: event.localPosition, // Mapped to true hover coordinate
      screenToWorldConverter: (screenPoint) => screenPointConverter(screenPoint)
    );

    onPanStart(input);
  }

  @override
  @override
  void onPointerPanZoomUpdate(PointerPanZoomUpdateEvent event) {
    // Determine if the user is actively pinching to zoom
    final bool isZooming = (event.scale - 1.0).abs() > 0.001;

    final ToolUpdateInput input = ToolUpdateInput(
      kind: PointerDeviceKind.trackpad,
      points: (
        screen: event.localPosition,
        world: screenPointConverter(event.localPosition),
      ),
      rawScale: event.scale,

      // If zooming, drop the tracking delta entirely to stop the canvas from sliding away
      // Only pass event.localPanDelta if they are doing a pure 2-finger scroll.
      delta: isZooming ? Offset.zero : event.localPanDelta,
    );

    onPanUpdate(input);
  }

  @override
  void onPointerPanZoomEnd(PointerPanZoomEndEvent event) {
    final ToolReleasedInput input = ToolReleasedInput(
      lastUsedDevice: PointerDeviceKind.trackpad,
    );
    onPanEnd(input);
  }

  @override
  void disableInput() {}
}
