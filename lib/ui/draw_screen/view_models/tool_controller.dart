import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/draw_tools/canvas_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/circle_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/erase_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/freehand_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/line_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/pan_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/path_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/rectangle_tool.dart';
import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:drawing_app/utils/history_consumer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class ToolController extends ChangeNotifier {
  final DrawScreenViewModel _viewModel;

  // DEBUG
  ScaleStartDetails startDetails = ScaleStartDetails();
  ScaleUpdateDetails updateDetails = ScaleUpdateDetails();

  final Set<int> _activePointerIds = {};
  Set<int> get activePointerIds => _activePointerIds;


  Offset _lastTrackedScreenPoint = Offset.zero;


  late final Map<Type, CanvasTool> tools;
  late CanvasTool _currentTool;
  bool _panToolOverrideActive = false;

  DrawData? get activePreview => _currentTool is DrawTool ? (_currentTool as DrawTool).activePreview : null;

  ToolController({required DrawScreenViewModel viewModel})
    : _viewModel = viewModel {
    initializeTools();
  }
  PointerDeviceKind get lastDeviceKind => _lastDeviceKind;
  PointerDeviceKind _lastDeviceKind = PointerDeviceKind.unknown;
  bool drawEnabled = true;

  CanvasTool get currentTool => _currentTool;

  void initializeTools({Type? initialTool}) {
    tools = {
      FreehandTool: FreehandTool(
        toolName: 'Freehand Tool',
        toolIcon: Icon(Icons.draw),
        defaultStrokePaint: Paint()
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5, renderStroke: true,
      ),
      PanTool: PanTool(
        toolName: 'Pan Tool',
        toolIcon: Icon(Icons.pan_tool),
        camera: _viewModel.camera,
      ),
      EraseTool: EraseTool(
        toolName: 'Erase Tool',
        toolIcon: Icon(Symbols.ink_eraser), defaultStrokePaint: Paint()..style = PaintingStyle.stroke..strokeWidth = 20,
      ),
      CircleTool: CircleTool(
        toolIcon: Icon(Icons.circle),
        toolName: 'Circle Tool',
        defaultStrokePaint: Paint()..style = PaintingStyle.stroke..strokeWidth = 5, defaultFillPaint: Paint()..color = Colors.grey, renderStroke: true, renderFill: true,
      ),
      RectangleTool: RectangleTool(
        toolName: 'Rectangle Tool',
        toolIcon: Icon(Icons.square), 
        defaultStrokePaint: Paint()
          ..color = Colors.black
          ..strokeWidth = 5
          ..style = PaintingStyle.stroke, defaultFillPaint: Paint()..color = Colors.grey, renderStroke: true, renderFill: true,
      ),
      LineTool: LineTool(
        toolIcon: Icon(Icons.horizontal_rule),
        toolName: 'Line Tool',
        defaultStrokePaint: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..color = Colors.black, renderStroke: true,
      ),
      PathTool: PathTool(toolIcon: Icon(Icons.polyline),defaultFillPaint: Paint()..color = Colors.blue, toolName: 'Path Tool', defaultStrokePaint: Paint()..strokeWidth = 5..color = Colors.black..style = PaintingStyle.stroke..strokeJoin..strokeJoin = StrokeJoin.round, renderFill: true, renderStroke: true)
    };
    if (initialTool != null) {
      _currentTool = tools.containsKey(initialTool)
          ? tools[initialTool]!
          : tools.values.first;
    } else {
      _currentTool = tools[PanTool]!;
    }
  }

  void selectTool<T extends CanvasTool>() {
    final targetTool = tools[T];
    if (targetTool == null || targetTool == _currentTool) return;

    // clear its caches, and emit any final transformation commands before swapping
    if (_currentTool.isActive) {
      final finalCommand = _currentTool.onToolEnd();
      if (finalCommand != null) {
        _viewModel.executeCommand(finalCommand);
      }
    }

    _currentTool = targetTool;
    notifyListeners();
  }

  void onPointerDown(PointerDownEvent event) {
    if (!drawEnabled) return;
    _activePointerIds.add(event.pointer);
    _lastDeviceKind = event.kind;

    // 1. Establish the baseline anchor tracking point immediately on click down
    _lastTrackedScreenPoint = event.localPosition;

    // 2. Generate the self-aware ToolStartFrame through the computed factory
    final ToolStartFrame frame = ToolStartFrame.compute(
      deviceKind: event.kind,
      rawScreenPoint: event.localPosition,
      layerId: _viewModel.activeLayerId,
      strokeIndex: _viewModel.drawHistory.length,
      screenToWorldConverter: (screenPoint) => screenToWorld(screenPoint),
    );

    // Handle Middle Click Panning (Even if a drawing tool is active)
    if (event.buttons == kTertiaryButton) {
      _panToolOverrideActive = true;

      // End active drawing tools cleanly before shifting the viewport matrix
      if (_currentTool.isActive) {
        final command = _currentTool.onToolEnd();
        if (command != null) _viewModel.executeCommand(command);
      }

      // Initialize the pan tool tracking variables cleanly
      tools[PanTool]!.onToolStart(frame);
      notifyListeners();
      return;
    }

    // Touch Overrides (Two fingers or more triggers PanTool)
    if (_activePointerIds.length > 1 && _currentTool is! PanTool) {
      _panToolOverrideActive = true;
      final command = _currentTool.onToolEnd();
      if (command != null) _viewModel.executeCommand(command);
    }
  }

  void onPointerMove(PointerMoveEvent event) {
    if (!drawEnabled) return;

    // Handle Middle Click drag tracking directly
    if (event.buttons == kTertiaryButton ||
        (_panToolOverrideActive && _lastDeviceKind == PointerDeviceKind.mouse)) {
      final panTool = tools[PanTool] as PanTool;

      if (!panTool.isActive) {
        _panToolOverrideActive = true;
        
        final ToolStartFrame startFrame = ToolStartFrame.compute(
          deviceKind: event.kind,
          rawScreenPoint: event.localPosition,
          layerId: _viewModel.activeLayerId,
          strokeIndex: _viewModel.drawHistory.length,
          screenToWorldConverter: (screenPoint) => screenToWorld(screenPoint),
        );
        panTool.onToolStart(startFrame);
        
        // Match base coordinates since a tool start resets the interaction path
        _lastTrackedScreenPoint = event.localPosition;
      }

      // 1. Build the updated frame payload containing the precise movement delta
      final ToolUpdateFrame updateFrame = ToolUpdateFrame.computeUpdate(
        deviceKind: event.kind,
        currentScreenPoint: event.localPosition,
        currentScale: 1.0, // Fixed unit scale during raw un-pinch mouse moves
        layerId: _viewModel.activeLayerId,
        priorScreenPoint: _lastTrackedScreenPoint,
        screenToWorldConverter: (screenPoint) => screenToWorld(screenPoint),
      );

      // 2. Execute the matrix shift update directly on your PanTool instance
      panTool.onToolUpdate(updateFrame);
      _viewModel.forceCanvasRefresh();

      // 3. Cache the current location to keep subsequent frame deltas consecutive
      _lastTrackedScreenPoint = event.localPosition;
    }
  }

  void onPointerUp(PointerUpEvent event) {
    if (!drawEnabled) return;
    _activePointerIds.remove(event.pointer);

    // Cleanly close down middle-mouse pan action
    if (_panToolOverrideActive && _lastDeviceKind == PointerDeviceKind.mouse) {
      tools[PanTool]!.onToolEnd();
      _panToolOverrideActive = false;
      notifyListeners();
    }
  }

  void onPointerCancel(PointerCancelEvent event) {
    if (!drawEnabled) return;
    _activePointerIds.remove(event.pointer);

    if (_panToolOverrideActive) {
      tools[PanTool]!.onToolEnd();
      _panToolOverrideActive = false;
      notifyListeners();
    }
  }

  void onPointerPanZoomStart(PointerPanZoomStartEvent event) {
    if (!drawEnabled) return;

    // 1. Log that we are actively on a trackpad interaction loop
    _lastDeviceKind = PointerDeviceKind.trackpad;

    // 2. Continuously sync the camera focal point to the trackpad's hover location
    _viewModel.camera.focalPointAtStart = event.localPosition;
    _viewModel.camera.scaleStart = _viewModel.camera.currentScale;
    _viewModel.camera.previousGestureScale = 1.0;

    // 3. Keep world pivot calculation accurate for your tools
    _viewModel.camera.worldPivotAtStart = screenToWorld(event.localPosition);

    // 4. Anchor our tracking pointer baseline to prevent initial delta jumps
    _lastTrackedScreenPoint = event.localPosition;

    // 5. Generate the unified frame payload containing zero-allocation spatial fields
    final ToolStartFrame frame = ToolStartFrame.compute(
      deviceKind: event.kind,
      rawScreenPoint: event.localPosition,
      layerId: _viewModel.activeLayerId,
      strokeIndex: _viewModel.drawHistory.length,
      screenToWorldConverter: (screenPoint) => screenToWorld(screenPoint),
    );

    // Trigger your PanTool initialization hook cleanly
    tools[PanTool]!.onToolStart(frame);
  }

   void onPointerPanZoomUpdate(PointerPanZoomUpdateEvent event) {
    if (!drawEnabled) return;

    _viewModel.camera.focalPointAtStart = event.localPosition;

    // 🟢 RESTORED: Feed the raw, incremental frame-to-frame localPanDelta vector.
    // This perfectly matches your old logic before the refactor!
    final ToolUpdateFrame frame = ToolUpdateFrame(
      pointerDeviceKind: event.kind,
      rawScale: event.scale,
      activeLayerId: _viewModel.activeLayerId,
      delta: Offset.zero, // Keep isolated to prevent double-panning bugs
      points: (
        screen: event.localPanDelta, // True incremental pixel changes
        world: screenToWorld(event.localPosition),
      ),
    );

    tools[PanTool]!.onToolUpdate(frame);
    _viewModel.forceCanvasRefresh();
  }


  // 🟢 Handles Trackpad Touch-Lift Cleanup
  void onPointerPanZoomEnd(PointerPanZoomEndEvent event) {
    if (!drawEnabled) return;
    _activePointerIds.remove(event.pointer);

    // Trackpad gestures initialize PanTool actions directly. We always clear it down safely here.
    final panTool = tools[PanTool]!;
    if (panTool.isActive) {
      final command = panTool.onToolEnd();
      if (command != null) _viewModel.executeCommand(command);
      _panToolOverrideActive = false;
      notifyListeners();
    }
  }


void handleScaleStart(ScaleStartDetails details, PointerDeviceKind device) {
  if (!drawEnabled) return;

  // 1. Guard against duplicate execution streams from trackpad events
  if (device == PointerDeviceKind.trackpad || _lastDeviceKind == PointerDeviceKind.trackpad) {
    return;
  }

  startDetails = details;
  _lastDeviceKind = device; // Make sure to cache the current active device kind

  // 2. Handle Multi-touch updates: Override active drawing tools if extra fingers tap down
  if (details.pointerCount > 1 && _currentTool is! PanTool) {
    _panToolOverrideActive = true;
    if (_currentTool.isActive) {
      CanvasCommand? command = _currentTool.onToolEnd();
      if (command != null) _viewModel.executeCommand(command);
    }
  }

  // 3. Synchronize camera spatial state properties
  _viewModel.camera.focalPointAtStart = details.localFocalPoint;
  _viewModel.camera.scaleStart = _viewModel.camera.currentScale;
  _viewModel.camera.previousGestureScale = 1.0;
  _viewModel.camera.worldPivotAtStart = screenToWorld(details.localFocalPoint);

  // 4. CRITICAL FIX: Initialize your delta tracking property for handleScaleUpdate
  _lastTrackedScreenPoint = details.localFocalPoint;

  // 5. Handle consumer history snapshot caching for undo/redo tracking
  if (_currentTool is HistoryConsumer && !_panToolOverrideActive) {
    List<DrawData> drawHistory = _viewModel.getHistoryForLayer(_viewModel.activeLayerId);
    (_currentTool as HistoryConsumer).setHistorySnapshot(drawHistory);
  }

  // 6. Generate the unified frame payload using the raw screen coordinate
  final ToolStartFrame frame = ToolStartFrame.compute(
    deviceKind: device,
    rawScreenPoint: details.localFocalPoint, // Always feed raw screen space here!
    layerId: _viewModel.activeLayerId,
    strokeIndex: _viewModel.drawHistory.length,
    screenToWorldConverter: (screenPoint) => screenToWorld(screenPoint),
  );

  // 7. Route the frame cleanly out to the targeted tool execution branch
  if (_panToolOverrideActive && _currentTool is! PanTool) {
    tools[PanTool]!.onToolStart(frame);
  } else {
    _currentTool.onToolStart(frame);
  }

  notifyListeners();
}

void handleScaleUpdate(ScaleUpdateDetails details) {
  if (!drawEnabled) return;
  if (_lastDeviceKind == PointerDeviceKind.trackpad) return;

  updateDetails = details;
  if (!_currentTool.isActive && !_panToolOverrideActive) return;

  // 1. Generate the self-aware, zero-allocation ToolUpdateFrame
  final ToolUpdateFrame frame = ToolUpdateFrame.computeUpdate(
    deviceKind: _lastDeviceKind,
    currentScreenPoint: details.localFocalPoint,
    currentScale: details.scale,
    layerId: _viewModel.activeLayerId,
    priorScreenPoint: _lastTrackedScreenPoint,
    screenToWorldConverter: (screenPoint) => screenToWorld(screenPoint),
  );

  // 2. Route the frame cleanly to the active tool layout instance
  if (_currentTool is PanTool || _panToolOverrideActive) {
    if (_currentTool is PanTool) {
      _currentTool.onToolUpdate(frame);
    } else {
      tools[PanTool]!.onToolUpdate(frame);
    }
    _viewModel.forceCanvasRefresh();
  } else {
    _currentTool.onToolUpdate(frame);
    notifyListeners();
  }

  // 3. Update the historical delta tracking position for the next frame tick
  _lastTrackedScreenPoint = details.localFocalPoint;
}

  void handleScaleEnd() {
    if (!drawEnabled) return;

    if (_panToolOverrideActive) {
      tools[PanTool]!.onToolEnd();
      _panToolOverrideActive = false;
      _activePointerIds.clear();
      notifyListeners();
    } else if (_currentTool.isActive) {
      final command = _currentTool.onToolEnd();
      if (command != null) {
        _viewModel.executeCommand(command);
      }
      notifyListeners();
    }
  }

  void disableDrawing() {
    handleScaleEnd();
    _panToolOverrideActive = false;
    drawEnabled = false;
    _activePointerIds.clear();
    notifyListeners();
  }

  void enableDrawing() {
    drawEnabled = true;
    notifyListeners();
  }

  Offset screenToWorld(Offset screenPoint) {
    final Matrix4 transformMatrix = _viewModel.camera.transform;

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
