import 'dart:typed_data';

import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:drawing_app/ui/draw_screen/widgets/layer_preview_view.dart';
import 'package:flutter/material.dart';



class FloatingLayerPanel extends StatelessWidget {
  const FloatingLayerPanel({
    super.key,
    required this.viewModel,
  });

  final DrawScreenViewModel viewModel;

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
            
            const Divider(height: 12, thickness: 1),
            IconButton(
              onPressed: () => viewModel.createLayer.execute(),
              icon: const Icon(Icons.add),
            
            ),
            SizedBox(height: 5,),
            // 1. Wrap ONLY the ReorderableListView in the ListenableBuilder
ListenableBuilder(
  listenable: Listenable.merge([
    viewModel.createLayer,
    viewModel.deleteLayer,
    viewModel,            
  ]),
  builder: (context, child) {
    // 1. Convert to an entry list or map so we get concrete, immutable indices during this build pass
    final layerList = viewModel.layers;

    return ReorderableListView(
      reverse: true,
      physics: const ClampingScrollPhysics(),
      buildDefaultDragHandles: false,
      shrinkWrap: true, 
      onReorder: (oldIndex, newIndex) {
        viewModel.reorderLayers(oldIndex, newIndex); 
      },
      // 2. Map using the entry index to keep index tracking absolute
      children: layerList.asMap().entries.map((entry) {
        final int index = entry.key;
        final layer = entry.value;

        return ReorderableDragStartListener(
          // Rule: The child of a ReorderableListView MUST have a key on its absolute root element
          key: Key('drag_listener_${layer.id}'), 
          index: index, // Fixed index placement
          child: Padding(
            padding: EdgeInsets.only(
              left: 4,
              right: 4,
              bottom: index == 0 ? 0 : 6,
            ),
            child: LayerPreviewWidget(
              layerId: layer.id,
              viewModel: viewModel,
            ),
          ),
        );
      }).toList(),
    );
  },
)

          ],
        ),
      ),
    );
  }
}




        // menuChildren: [...widget._viewModel.layers.map((layer) {
        //                         return Padding(
        //                           padding: EdgeInsets.only(left: 4,right: 4, top: layer == widget._viewModel.layers.first ? 0 : 6),
        //                           child: LayerPreviewWidget(layerId: layer.id, viewModel: widget._viewModel)
        //                         );
        //                       }), SizedBox(height: 6,),Center(child: IconButton(onPressed: () => widget._viewModel.createLayer.execute(), icon: Icon(Icons.add)))]
      


