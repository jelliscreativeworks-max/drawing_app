

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class InputChangedNotifier extends ChangeNotifier {
  PointerDeviceKind _lastActiveDevice = PointerDeviceKind.unknown;
  PointerDeviceKind get lastActiveDevice => _lastActiveDevice;

  InputChangedNotifier() {
    // Connect into the foundational Flutter engine pointer routing array
    GestureBinding.instance.pointerRouter.addGlobalRoute(_handleGlobalPointerEvent);
  }

  void _handleGlobalPointerEvent(PointerEvent event) {
    // Intercept hardware signals immediately during their baseline execution frame
    if (event is PointerDownEvent || event is PointerPanZoomStartEvent) {
      if (_lastActiveDevice != event.kind) {
        _lastActiveDevice = event.kind;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    // Clean up router allocation when tearing down state
    GestureBinding.instance.pointerRouter.removeGlobalRoute(_handleGlobalPointerEvent);
    super.dispose();
  }
}
