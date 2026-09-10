import 'package:flutter/material.dart';
import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:drawing_app/ui/draw_screen/view_models/tool_controller.dart';
import 'package:drawing_app/ui/draw_screen/widgets/layer_preview_view.dart'; // Target file for LayerPreviewWidget

class FloatingLayerPanel extends StatelessWidget {
  final DrawScreenViewModel viewModel;
  
  /// 🟢 NEW INJECTION: Inject your configuration View Model to satisfy 
  /// the background isolation snapshot tool requirements.
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
      color: Theme.of(context).colorScheme.surface,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        constraints: const BoxConstraints(
          minWidth: 80,
          maxWidth: 100,
          minHeight: 80, 
          maxHeight: 400, 
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Structural Addition Action Command Link
            IconButton(
              onPressed: () => viewModel.createLayer.execute(),
              icon: const Icon(Icons.add_circle_outline_rounded),
              tooltip: 'Create New Layer',
            ),
            
            const Divider(height: 12, thickness: 1),
            
            // Nested ListenableBuilder: Watches row selections, insertions, and destructions.
            // Isolates list-rebuilding ticks entirely from the parent shell layout.
            Flexible(
              child: ListenableBuilder(
                listenable: Listenable.merge([
                  viewModel.createLayer,
                  viewModel.deleteLayer,
                  viewModel,            
                ]),
                builder: (context, child) {
                  // 1. Establish a stable local array sequence for absolute tracking index maps
                  final layerList = viewModel.layers;

                  return ReorderableListView(
                    // 🟢 FIXED: Removed 'reverse: true' to protect your reorderLayers index math,
                    // allowing drags to transition down the array bounds cleanly without drift.
                    physics: const ClampingScrollPhysics(),
                    buildDefaultDragHandles: false,
                    shrinkWrap: true, 
                    onReorder: (oldIndex, newIndex) {
                      viewModel.reorderLayers(oldIndex, newIndex); 
                    },
                    children: layerList.asMap().entries.map((entry) {
                      final int index = entry.key;
                      final layer = entry.value;

                      return ReorderableDragStartListener(
                        // Crucial Rule: Every direct child element inside a ReorderableListView 
                        // MUST contain an explicit, unique Key on its absolute root element wrapper.
                        key: ValueKey('drag_listener_${layer.id}'), 
                        index: index, 
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 4,
                            right: 4,
                            bottom: index == layerList.length - 1 ? 0 : 6,
                          ),
                          child: LayerPreviewWidget(
                            layerId: layer.id,
                            viewModel: viewModel,
                            // 🟢 FIXED: Forwards the active UI drawing tool parameters map seamlessly!
                            drawTools: toolController.tools, 
                          ),
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
