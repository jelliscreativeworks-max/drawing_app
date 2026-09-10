import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/domain/models/layer_data/layer_data.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tools_list.dart';
import 'package:drawing_app/ui/draw_screen/view_models/tool_controller.dart';
import 'package:drawing_app/utils/painters/background_painter.dart';
import 'package:drawing_app/utils/painters/gridline_painter.dart';
import 'package:drawing_app/utils/painters/painter.dart';
import 'package:drawing_app/ui/draw_screen/widgets/bottom_tool_bar_buttons.dart';
import 'package:drawing_app/ui/draw_screen/widgets/layer_preview_view.dart';
import 'package:drawing_app/ui/draw_screen/widgets/layer_menu_anchor_view.dart';
import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:drawing_app/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DrawScreen extends StatefulWidget {
  const DrawScreen({super.key, required this.viewModel, required this.toolController});

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
                  onPressed: () => Navigator.of(context).pop(),
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
                  icon: widget.viewModel.saveDirtyProgress.running 
                      ? const SizedBox(
                          width: 18, 
                          height: 18, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70)
                        )
                      : const Icon(Icons.more_vert)
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
                  // ==========================================================
                  // LAYER 1: UNIFIED WORKSPACE BOUNDARY (GESTURES INTERCEPTOR)
                  // ==========================================================
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onScaleStart: (details) => widget.toolController.handleScaleStart(details.localFocalPoint),
                      onScaleUpdate: (details) => widget.toolController.handleScaleUpdate(details.localFocalPoint,details.scale),
                      onScaleEnd: (_) => widget.toolController.handleScaleEnd(),
                      child: ClipRect(
                        child: Stack(
                          children: [
                            // A. Infinite Workspace Canvas Blueprint Background Paint
                            Positioned.fill(
                              child: CustomPaint(
                                painter: BackgroundPainter(
                                  transform: widget.viewModel.camera.transform,
                                  canvasWidth: widget.viewModel.canvasWidth,
                                  canvasHeight: widget.viewModel.canvasHeight,
                                  cellSize: 35.0,
                                  lineThickness: 1.2,
                                ),
                              ),
                            ),

                            // B. Dynamic Persistent Stacking Vector Layer System
                            ...widget.viewModel.layers.map((LayerData layer) {
                              if (!layer.isVisible) return const SizedBox.shrink();

                              final List<DrawData> filteredLayerHistory = 
                                  widget.viewModel.getHistoryForLayer(layer.id);

                              return Positioned.fill(
                                child: RepaintBoundary(
                                  child: CustomPaint(
                                    key: ValueKey(
                                      '${layer.id}_${filteredLayerHistory.length}_${widget.viewModel.transformRevision}',
                                    ),
                                    painter: MyPainter(
                                      canvasHeight: widget.viewModel.canvasHeight,
                                      canvasWidth: widget.viewModel.canvasWidth,
                                      drawHistory: filteredLayerHistory,
                                      tools: widget.toolController.tools,
                                      transform: widget.viewModel.camera.transform,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),

                            // C. Real-Time Active Pointer Stroke Sketch Preview Overlay Channel
                            // Sits right on top of historical layer lines so in-progress shapes trace accurately!
                            ListenableBuilder(
                              listenable: widget.toolController,
                              builder: (context, child) {
                                final DrawData? preview = widget.toolController.activePreview;
                                if (preview == null) return const SizedBox.shrink();

                                return Positioned.fill(
                                  child: CustomPaint(
                                    painter: MyPainter(
                                      canvasHeight: widget.viewModel.canvasHeight,
                                      canvasWidth: widget.viewModel.canvasWidth,
                                      drawHistory: [preview],
                                      tools: widget.toolController.tools,
                                      transform: widget.viewModel.camera.transform,
                                    ),
                                  ),
                                );
                              },
                            ),

                            // D. Persistent Document Guideline Grids Overlay
                            // 🟢 MOVED TO TOP: Placed at the absolute end of the array loop 
                            // so guidelines sit perfectly visible over everything without blocking touch signals.
                            Positioned.fill(
                              child: CustomPaint(
                                key: ValueKey(
                                  'canvas_grid_layer_${widget.viewModel.transformRevision}',
                                ),
                                painter: GridlinePainter(
                                  transform: widget.viewModel.camera.transform,
                                  canvasWidth: widget.viewModel.canvasWidth,
                                  canvasHeight: widget.viewModel.canvasHeight,
                                  cellSize: 35.0,
                                  lineThickness: 1.2,
                                ),
                              ),
                            ),
                          ],
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
                          color: Colors.white.withOpacity(0.9),
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

                  // Fullscreen Initial Loading Blocker
                  if (widget.viewModel.loadProject.running ||
                      widget.viewModel.initProject.running)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    ),

                  // Sidebar Layers Panel overlay
                  if (widget.viewModel.isLayerMenuOpen)
                    Positioned(
                      right: 16,
                      top: 20,
                      child: FloatingLayerPanel(viewModel: widget.viewModel, toolController: widget.toolController,),
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