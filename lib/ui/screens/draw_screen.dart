import 'package:drawing_app/painter.dart';
import 'package:drawing_app/ui/draw_page/view_models/draw_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:drawing_app/ui/draw_page/view_models/draw_screen_view_model.dart';
import 'package:flutter/material.dart';

class DrawScreen extends StatelessWidget {
  final DrawScreenViewModel viewModel;

  const DrawScreen({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    // FIX: Merge the main view model AND the async commands into a single listener.
    // This guarantees a rebuild whenever a drawing gesture happens OR any command state shifts!
    return ListenableBuilder(
      listenable: Listenable.merge([
        viewModel,
        viewModel.saveDirtyProgress,
        viewModel.loadProject,
        viewModel.createLayer,
        viewModel.initProject
      ]),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.grey, // Artboard canvas background wrapper
          body: Stack(
            children: [
              // --- Layer 1: Global Workspace Canvas Gesture Grid ---
              Positioned.fill(
                child: GestureDetector(
                  onPanStart: (details) => viewModel.handlePanStart(details.localPosition),
                  onPanUpdate: (details) => viewModel.handlePanUpdate(details.localPosition),
                  onPanEnd: (_) => viewModel.handlePanEnd(),
                  
                  child: Stack(
                    children: viewModel.layers.map((layer) {
                      // High-performance O(1) array memory lookups
                      final filteredLayerHistory = viewModel.getHistoryForLayer(layer.id);

                      if (!layer.isVisible) return const SizedBox.shrink();

                      return Positioned.fill(
                        child: RepaintBoundary(
                          child: CustomPaint(
                            // Dynamic tracking key forces redraw ticks synchronously on undo/redo steps
                            key: ValueKey('${layer.id}_${filteredLayerHistory.length}'),
                            painter: MyPainter(
                              drawHistory: filteredLayerHistory,
                              drawTools: viewModel.tools,
                              // Render preview vectors exclusively on the focused active layer
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
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Undo action trigger hook
                        IconButton(
                          onPressed: viewModel.canUndo ? viewModel.executeUndo : null,
                          icon: const Icon(Icons.undo),
                          color: Colors.black87,
                        ),
                        const SizedBox(width: 16),
                        // Redo action trigger hook
                        IconButton(
                          onPressed: viewModel.canRedo ? viewModel.executeRedo : null,
                          icon: const Icon(Icons.redo),
                          color: Colors.black87,
                        ),
                        const SizedBox(width: 16),
                        // Shortcut hook to add a new layer instantly
                        IconButton(
                          onPressed: () => viewModel.createLayer.execute(),
                          icon: viewModel.createLayer.running 
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.layers_outlined),
                          color: Colors.blueAccent,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // --- Layer 3: Dynamic Sync Saving Progress Overlay ---
              // Now updates immediately because Listenable.merge listens to saveDirtyProgress changes!
              if (viewModel.saveDirtyProgress.running)
                Positioned(
                  top: 50,
                  left: 20,
                  child: SafeArea(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                          ),
                          SizedBox(width: 8),
                          Text('Saving...', style: TextStyle(color: Colors.black54, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),

              // --- Layer 4: Fullscreen Project Loading Block ---
              if (viewModel.loadProject.running)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ));
        },
    );
  }
}