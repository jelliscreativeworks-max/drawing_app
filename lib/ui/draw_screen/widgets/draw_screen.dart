import 'package:drawing_app/domain/models/draw_tools/draw_tools_list.dart';
import 'package:drawing_app/painter.dart';
import 'package:drawing_app/ui/draw_screen/widgets/bottom_tool_bar_buttons.dart';
import 'package:drawing_app/ui/draw_screen/widgets/layer_preview_view.dart';
import 'package:drawing_app/ui/draw_screen/widgets/layer_menu_anchor_view.dart';
import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:drawing_app/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DrawScreen extends StatefulWidget{
   const DrawScreen({super.key, required this.viewModel});

   final DrawScreenViewModel viewModel;

   @override
  State<StatefulWidget> createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
bool _hasCenteredOnStart = false;

@override
Widget build(BuildContext context) {
  return ListenableBuilder(
    listenable: Listenable.merge([
      widget.viewModel,
      widget.viewModel.saveDirtyProgress,
    ]),
    builder: (context, child) {
      return Scaffold(
        backgroundColor: Colors.grey.shade900,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_rounded)),
              IconButton(onPressed: () => widget.viewModel.toggleLayerMenu(), icon: const Icon(Icons.layers)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.add_photo_alternate_outlined)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
            ],
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints){
            final Size currentViewport = Size(constraints.maxWidth, constraints.maxHeight);

             if (!_hasCenteredOnStart) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  widget.viewModel.resetView(currentViewport);
                });
                _hasCenteredOnStart = true;
              }

           return Stack(
            children: [
              // --- Layer 1: Unified CanvasKit Viewport Workspace ---
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onScaleStart: (details) => widget.viewModel.handleScaleStart(details),
                  onScaleUpdate: (details) => widget.viewModel.handleScaleUpdate(details),
                  onScaleEnd: (_) => widget.viewModel.handleScaleEnd(),
                  
                  child: Stack(
                    children: widget.viewModel.layers.map((layer) {
                      final filteredLayerHistory = widget.viewModel.getHistoryForLayer(layer.id);
                      if (!layer.isVisible) return const SizedBox.shrink();
                            
                      return Positioned.fill(
                        child: RepaintBoundary(
                          child: CustomPaint(
                            // FIX 1: Add the transformRevision into the canvas key track!
                            // This forces the RepaintBoundary cache layer to clear out 
                            // and repaint instantly whenever a zoom or pan modification updates.
                            key: ValueKey(
                              '${layer.id}_${filteredLayerHistory.length}_${widget.viewModel.transformRevision}'
                            ),
                            painter: MyPainter(
                              canvasHeight: widget.viewModel.canvasHeight,
                              canvasWidth: widget.viewModel.canvasWidth,
                              drawHistory: filteredLayerHistory,
                              drawTools: DrawToolsList.map,
                              activeCommand: layer.id == widget.viewModel.activeLayerId 
                                  ? widget.viewModel.activeCommand 
                                  : null,
                              transform: widget.viewModel.transform, // Continuous matrix camera feed
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            Align(
                alignment: Alignment.bottomRight,
                child: SafeArea(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: widget.viewModel.canUndo ? widget.viewModel.executeUndo : null,
                          icon: const Icon(Icons.undo),
                          color: Colors.black87,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: widget.viewModel.canRedo ? widget.viewModel.executeRedo : null,
                          icon: const Icon(Icons.redo),
                          color: Colors.black87,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          
              // Fullscreen Initial Loading Blocker
              if (widget.viewModel.loadProject.running || widget.viewModel.initProject.running)
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
                  child: FloatingLayerPanel(viewModel: widget.viewModel),
                ),
            
            ],
          
            
          );}
        ),
        bottomNavigationBar: BottomAppBar(
          height: 64.0,
          child: BottomToolBarButtons(viewModel: widget.viewModel),
        ),
      );
    },
  );
}
}
