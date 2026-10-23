import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/domain/models/layer_data/layer_data.dart';
import 'package:drawing_app/router/routes.dart';
import 'package:drawing_app/ui/draw_screen/view_models/tool_controller.dart';
import 'package:drawing_app/ui/draw_screen/widgets/tool_properties/tool_properties_menu.dart';
import 'package:drawing_app/ui/draw_screen/widgets/tool_properties/tool_stroke_size_preview.dart';
import 'package:drawing_app/ui/core/painters/background_painter.dart';
// import 'package:drawing_app/utils/painters/debug_painter.dart';
import 'package:drawing_app/ui/core/painters/gridline_painter.dart';
import 'package:drawing_app/ui/core/painters/painter.dart';
import 'package:drawing_app/ui/draw_screen/widgets/bottom_tool_bar_buttons.dart';
import 'package:drawing_app/ui/draw_screen/widgets/layer_menu_anchor_view.dart';
import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DrawScreen extends StatefulWidget {
   const DrawScreen({
    super.key,
    required this.viewModel,
  });

  final DrawScreenViewModel viewModel;

  @override
  State<StatefulWidget> createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  bool _hasCenteredOnStart = false;

  @override
  Widget build(BuildContext context) {
    final ToolController toolController = context.read<ToolController>();

    return ListenableBuilder(
      // Top-Level Listener: Watches core document states and asynchronous autosave progress
      listenable: Listenable.merge([
        widget.viewModel,
        widget.viewModel.saveDirtyProgress,
      ]),
      builder: (context, child) {
        return MouseRegion(
          onEnter: (event) => toolController.enableDrawing(event),
          onExit: (event) => toolController.disableDrawing(),
          child: Scaffold(
            backgroundColor: Colors.grey.shade900,
            appBar: AppBar(
              backgroundColor: Colors.grey.shade50,
              elevation: 0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => context.go(Routes.home),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  IconButton(
                    onPressed: () => widget.viewModel.toggleLayerMenu(),
                    icon: const Icon(Icons.layers),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                  ),
                  // Visual indicators can watch widget.viewModel.saveDirtyProgress.running here
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final Size currentViewport = Size(
                  constraints.maxWidth,
                  constraints.maxHeight,
                );

                // Auto-center viewport workspace exactly once on screen boot parameters
                if (!_hasCenteredOnStart) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    widget.viewModel.resetView(currentViewport);
                  });
                  _hasCenteredOnStart = true;
                }

                return Stack(
                  children: [
                    Positioned.fill(
                      child: Listener(
                        onPointerDown: (event) => toolController
                            .handleEvent(event, event.kind),
                        onPointerMove: (event) => toolController
                            .handleEvent(event, event.kind),
                        onPointerUp: (event) => toolController
                            .handleEvent(event, event.kind),
                        onPointerCancel: (event) => toolController
                            .handleEvent(event, event.kind),
                        onPointerPanZoomStart: (event) => toolController
                            .handleEvent(event, event.kind),
                        onPointerPanZoomUpdate: (event) => toolController
                            .handleEvent(event, event.kind),
                        onPointerPanZoomEnd: (event) => toolController
                            .handleEvent(event, event.kind),
                        onPointerSignal: (event) => toolController
                            .handleEvent(event, event.kind),
                        child: GestureDetector(
                          onScaleStart: (details) =>
                              toolController.handleEvent(
                                details,
                                details.kind ??
                                    toolController.lastDeviceKind,
                              ),
                          onScaleUpdate: (details) =>
                              toolController.handleEvent(
                                details,
                                toolController.lastDeviceKind,
                              ),
                          onScaleEnd: (details) =>
                              toolController.handleEvent(
                                details,
                                toolController.lastDeviceKind,
                              ),

                          child: ClipRect(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: BackgroundPainter(
                                      transform:
                                          widget.viewModel.camera.transform,
                                      canvasWidth: widget
                                          .viewModel
                                          .currentCanvas
                                          .currentWidth,
                                      canvasHeight: widget
                                          .viewModel
                                          .currentCanvas
                                          .currentHeight,
                                      cellSize: 35.0,
                                      lineThickness: 1.2,
                                    ),
                                  ),
                                ),

                                // B. Dynamic Persistent Stacking Vector Layer System
                                ...widget.viewModel.layers.map((
                                  LayerData layer,
                                ) {
                                  if (!layer.isVisible) return const SizedBox.shrink();

                                  final List<DrawData> filteredLayerHistory =
                                      widget.viewModel.getHistoryForLayer(
                                        layer.id,
                                      );

                                  return widget.viewModel.loadProject.running
                                      ? SizedBox.shrink()
                                      :
                                        // 🌟 REFACTORED HIGH-PERFORMANCE LAYER RENDERER
                                        Selector<
                                          ToolController,
                                          Set<String>
                                        >(
                                          // 1. Route the selector to drill down through the ViewModel to fetch hiddenData
                                          selector: (_, controller) => Set<String>.of(
                                            controller.hiddenData,
                                          ),

                                          builder: (context, hiddenData, child) {
            
    
                                            final activeCanvas =
                                                widget.viewModel.currentCanvas;

                                            return Positioned.fill(
                                              child: RepaintBoundary(
                                                child: CustomPaint(
                                                  key: ValueKey(
                                                    '${layer.id}_${filteredLayerHistory.length}_${widget.viewModel.transformRevision}',
                                                  ),
                                                  painter: MyPainter(
                                                    hiddenData: hiddenData,
                                                    deletionTargets: const {},
                                     
                                                    deviceKind: toolController
                                                        .lastDeviceKind,
                                                    canvasHeight: activeCanvas
                                                        .currentHeight,
                                                    canvasWidth: activeCanvas
                                                        .currentWidth,
                                                    drawHistory:
                                                        filteredLayerHistory,
                                                    camera:
                                                        widget.viewModel.camera,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                }),
                                ListenableBuilder(
                                  listenable: toolController,
                                  builder: (context, child) {
                                    final List<DrawData> overlayData =
                                        toolController.overlayHistory;

                                    // If there is nothing to preview and the tool is at rest, draw nothing
                                    if (overlayData.isEmpty &&
                                        !toolController
                                            .currentTool
                                            .isActive) {
                                      return const SizedBox.shrink();
                                    }

                                    return Positioned.fill(
                                      child: CustomPaint(
                                        painter: MyPainter(
                                          deletionTargets: toolController
                                              .activeDeletionTargets,
                                          deviceKind: toolController
                                              .lastDeviceKind,
                                          canvasHeight: widget
                                              .viewModel
                                              .currentCanvas
                                              .currentHeight,
                                          canvasWidth: widget
                                              .viewModel
                                              .currentCanvas
                                              .currentWidth,
                                          drawHistory:
                                              overlayData,
                                          camera: widget.viewModel.camera,
                                          activeTool:
                                              toolController.currentTool,
                                          hiddenData: {},
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // D. Persistent Document Guideline Grids Overlay
                                Positioned.fill(
                                  child: CustomPaint(
                                    key: ValueKey(
                                      'canvas_grid_layer_${widget.viewModel.transformRevision}',
                                    ),
                                    painter: GridlinePainter(
                                      transform:
                                          widget.viewModel.camera.transform,
                                      canvasWidth: widget
                                          .viewModel
                                          .currentCanvas
                                          .currentWidth,
                                      canvasHeight: widget
                                          .viewModel
                                          .currentCanvas
                                          .currentHeight,
                                      cellSize: widget.viewModel.gridCellSize,
                                      lineThickness: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      
                      alignment: AlignmentGeometry.center,
                      child: ToolStrokeSizePreview(alwaysActive: false,),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: SafeArea(
                        child: ToolPropertiesMenu(),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: SafeArea(
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: widget.viewModel.canUndo
                                    ? widget.viewModel.undo
                                    : null,
                                icon: const Icon(Icons.undo),
                                color: Colors.black87,
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: widget.viewModel.canRedo
                                    ? widget.viewModel.redo
                                    : null,
                                icon: const Icon(Icons.redo),
                                color: Colors.black87,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // // Fullscreen Initial Loading Blocker
                    // if (widget.viewModel.loadProject.running)
                    //   Positioned.fill(
                    //     child: Container(
                    //       color: Colors.transparent,
                    //       child: const Center(
                    //         child: CircularProgressIndicator(color: Colors.blue),
                    //       ),
                    //     ),
                    //   ),

                    // Sidebar Layers Panel overlay
                    if (widget.viewModel.isLayerMenuOpen)
                      Positioned(
                        right: 16,
                        top: 20,
                        child: FloatingLayerPanel(
                          viewModel: widget.viewModel,
                          toolController: toolController,
                        ),
                      ),
                  ],
                );
              },
            ),
            bottomNavigationBar: BottomAppBar(
              height: 64.0,
              child: BottomToolBarButtons(
                toolController: toolController,
              ),
            ),
          ),
        );
      },
    );
  }
}
