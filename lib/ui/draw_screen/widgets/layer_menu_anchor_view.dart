import 'package:flutter/material.dart';
import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:drawing_app/ui/draw_screen/view_models/tool_controller.dart';
import 'package:drawing_app/ui/draw_screen/widgets/layer_preview_view.dart'; // Make sure your path matches

class FloatingLayerPanel extends StatelessWidget {
  final DrawScreenViewModel viewModel;
  final ToolController toolController;

  const FloatingLayerPanel({
    super.key,
    required this.viewModel,
    required this.toolController,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      color: Colors.grey,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        constraints: const BoxConstraints(
          minWidth: 120, 
          maxWidth: 140,
          minHeight: 80, 
          maxHeight: 400, 
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => viewModel.createLayer.execute(),
              icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white70),
              tooltip: 'Create New Layer',
            ),
            
            const Divider(height: 12, thickness: 1, color: Colors.white24),
            
            Flexible(
              child: ListenableBuilder(
                listenable: Listenable.merge([
                  viewModel.createLayer,
                  viewModel.deleteLayer,
                  viewModel,            
                ]),
                builder: (context, child) {
                  final layerList = viewModel.layers;

                  return ReorderableListView(
                    physics: const ClampingScrollPhysics(),
                    // 🟢 SET TO TRUE: Let Flutter natively append the drag handle 
                    // gestures onto the rows to guarantee perfect alignment!
                    buildDefaultDragHandles: true,
                    shrinkWrap: true, 
                    onReorder: (oldIndex, newIndex) {
                      viewModel.reorderLayers(oldIndex, newIndex); 
                    },
                    children: layerList.asMap().entries.map((entry) {
                      final int index = entry.key;
                      final layer = entry.value;

                      // 🟢 FIXED: The immediate child MUST hold a clean ValueKey(layer.id).
                      // This isolates the framework's GlobalKey factories from duplicates!
                      return Padding(
                        key: ValueKey(layer.id), // Key moved to top child cleanly
                        padding: EdgeInsets.only(
                          left: 8,
                          right: 8,
                          bottom: index == layerList.length - 1 ? 0 : 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // A. Clean, Isolated Layer Thumbnail Tile Card
                            LayerPreviewWidget(
                              layerId: layer.id,
                              viewModel: viewModel,
                              toolController: toolController, 
                            ),
                            
                            const SizedBox(width: 6),

                            // B. Explicit trash icon for deletions
                            if (layerList.length > 1)
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                                onPressed: () => viewModel.deleteLayer.execute(layer.id),
                                tooltip: 'Delete Layer',
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
