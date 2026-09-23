import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/domain/models/layer_data/layer_data.dart';
import 'package:drawing_app/router/routes.dart';
import 'package:drawing_app/ui/draw_screen/view_models/tool_controller.dart';
import 'package:drawing_app/utils/painters/background_painter.dart';
// import 'package:drawing_app/utils/painters/debug_painter.dart';
import 'package:drawing_app/utils/painters/gridline_painter.dart';
import 'package:drawing_app/utils/painters/painter.dart';
import 'package:drawing_app/ui/draw_screen/widgets/bottom_tool_bar_buttons.dart';
import 'package:drawing_app/ui/draw_screen/widgets/layer_menu_anchor_view.dart';
import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DrawScreen extends StatefulWidget {
  const DrawScreen({
    super.key,
    required this.viewModel,
    required this.toolController,
  });

  final DrawScreenViewModel viewModel;
  final ToolController toolController;

  @override
  State<StatefulWidget> createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  bool _hasCenteredOnStart = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      // Top-Level Listener: Watches core document states and asynchronous autosave progress
      listenable: Listenable.merge([
        widget.viewModel,
        widget.viewModel.saveDirtyProgress,
      ]),
      builder: (context, child) {
        return Scaffold(
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
                  icon:  const Icon(Icons.more_vert),
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
                    child: MouseRegion(
                      onEnter: (event) => widget.toolController.enableDrawing(event),
                      onExit: (event) => widget.toolController.disableDrawing(),
                      child: Listener(
                        onPointerDown: (event) => widget.toolController.handleEvent(event, event.kind),
                        onPointerMove: (event) => widget.toolController.handleEvent(event, event.kind),
                        onPointerUp: (event) => widget.toolController.handleEvent(event, event.kind),
                        onPointerCancel: (event) => widget.toolController.handleEvent(event, event.kind),
                        onPointerPanZoomStart: (event) => widget.toolController.handleEvent(event, event.kind),
                        onPointerPanZoomUpdate: (event) => widget.toolController.handleEvent(event, event.kind),
                        onPointerPanZoomEnd: (event) => widget.toolController.handleEvent(event, event.kind),
                        onPointerSignal: (event) => widget.toolController.handleEvent(event, event.kind),
                        child: GestureDetector(
                          onScaleStart: (details) => widget.toolController.handleEvent(details, details.kind ?? widget.toolController.lastDeviceKind),
                          onScaleUpdate: (details) => widget.toolController.handleEvent(details, widget.toolController.lastDeviceKind),
                          onScaleEnd: (details) => widget.toolController.handleEvent(details, widget.toolController.lastDeviceKind),
                         
                          
                          child: ClipRect(
                            child: Stack(
                              children: [
             
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: BackgroundPainter(
                                      transform:
                                          widget.viewModel.camera.transform,
                                      canvasWidth: widget.viewModel.currentCanvas.currentWidth,
                                      canvasHeight:
                                          widget.viewModel.currentCanvas.currentHeight,
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

                                  return widget.viewModel.loadProject.running ? SizedBox.shrink() : Positioned.fill(
                                    child: RepaintBoundary(
                                      child: CustomPaint(
                                        key: ValueKey(
                                          '${layer.id}_${filteredLayerHistory.length}_${widget.viewModel.transformRevision}',
                                        ),
                                        painter: MyPainter(
                                          deletionTargets: const {},
                                          deviceKind: widget
                                              .toolController
                                              .lastDeviceKind,
                                          canvasHeight:
                                              widget.viewModel.currentCanvas.currentHeight,
                                          canvasWidth:
                                              widget.viewModel.currentCanvas.currentWidth,
                                          drawHistory: filteredLayerHistory,
                                          transform:
                                              widget.viewModel.camera.transform,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                ListenableBuilder(
  listenable: widget.toolController,
  builder: (context, child) {
    final List<DrawData> overlayData = widget.toolController.overlayHistory;

    // If there is nothing to preview and the tool is at rest, draw nothing
    if (overlayData.isEmpty && !widget.toolController.currentTool.isActive) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: CustomPaint(
        painter: MyPainter(
          deletionTargets: widget.toolController.activeDeletionTargets,
          deviceKind: widget.toolController.lastDeviceKind,
          canvasHeight: widget.viewModel.currentCanvas.currentHeight,
          canvasWidth: widget.viewModel.currentCanvas.currentWidth,
          drawHistory: overlayData, // 🟢 Clean MVVM pass-through list
          transform: widget.viewModel.camera.transform,
          activeTool: widget.toolController.currentTool,
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
                                      canvasWidth: widget.viewModel.currentCanvas.currentWidth,
                                      canvasHeight:
                                          widget.viewModel.currentCanvas.currentHeight,
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
                        toolController: widget.toolController,
                      ),
                    ),
                ],
              );
            },
          ),
          bottomNavigationBar: BottomAppBar(
            height: 64.0,
            child: BottomToolBarButtons(toolController: widget.toolController),
          ),
        );
      },
    );
  }
}
