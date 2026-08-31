import 'package:drawing_app/painter.dart';
import 'package:drawing_app/ui/draw_screen/widgets/layer_preview_view.dart'; // Retained your project paths
import 'package:drawing_app/ui/draw_screen/widgets/layer_menu_anchor_view.dart';
import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:drawing_app/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DrawScreen extends StatelessWidget {
  final DrawScreenViewModel viewModel;

  const DrawScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        viewModel,
        viewModel.saveDirtyProgress,
        viewModel.loadProject,
        viewModel.createLayer,
        viewModel.initProject,
      ]),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: DrawScreenViewModel
              .canvasBackgroundColor, // Artboard canvas background wrapper
          appBar: AppBar(
            title: (Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: (){}, icon: Icon(Icons.arrow_back_rounded)),

                 IconButton(onPressed: () => viewModel.toggleLayerMenu(), icon: Icon(Icons.layers)),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.add_photo_alternate_outlined),
                ),
                IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
              ],
            )),
          ),
          body: Stack(
            children: [
              // --- Layer 1: Global Workspace Canvas Gesture Grid ---
              Positioned.fill(
                child: GestureDetector(
                  onPanStart: (details) =>
                      viewModel.handlePanStart(details.localPosition),
                  onPanUpdate: (details) =>
                      viewModel.handlePanUpdate(details.localPosition),
                  onPanEnd: (_) => viewModel.handlePanEnd(),
                  child: Stack(
                    children: viewModel.layers.map((layer) {
                      final filteredLayerHistory = viewModel.getHistoryForLayer(
                        layer.id,
                      );

                      // Avoid drawing or painting widgets if they are hidden
                      if (!layer.isVisible) return const SizedBox.shrink();

                      return Positioned.fill(
                        child: RepaintBoundary(
                          key: viewModel.getGlobalLayerKey(layer.id),
                          child: CustomPaint(
                            key: ValueKey(
                              '${layer.id}_${filteredLayerHistory.length}',
                            ),
                            painter: MyPainter(
                              drawHistory: filteredLayerHistory,
                              drawTools: viewModel.tools,
                              activeCommand: layer.id == viewModel.activeLayerId
                                  ? viewModel.activeCommand
                                  : null,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // --- Layer 2: Floating Functional Action Toolbar Panel ---
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Undo action trigger hook
                    IconButton(
                      onPressed: viewModel.canUndo
                          ? viewModel.executeUndo
                          : null,
                      icon: const Icon(Icons.undo),
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 8),
                    // Redo action trigger hook
                    IconButton(
                      onPressed: viewModel.canRedo
                          ? viewModel.executeRedo
                          : null,
                      icon: const Icon(Icons.redo),
                      color: Colors.black87,
                    ),
                    // const SizedBox(width: 12),
                    // IconButton(onPressed: () => viewModel.toggleLayerMenu(), icon: Icon(Icons.layers))
                  ],
                ),
              ),

              if (viewModel.loadProject.running)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),

              if (viewModel.isLayerMenuOpen == true)
                Positioned(
                  right: 16, // Distance from right screen frame edges
                  top: 20, // Placed right below the navigation AppBar
                  child: FloatingLayerPanel(viewModel: viewModel),
                ),
            ],
          ),

          bottomNavigationBar: BottomAppBar(
            height: 56.0,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  splashRadius: 24.0,
                  icon: const Icon(Icons.near_me, size: 24.0),
                  onPressed: () {},
                ),
                IconButton(
                  splashRadius: 24.0,
                  icon: const Icon(Icons.draw, size: 24.0),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
