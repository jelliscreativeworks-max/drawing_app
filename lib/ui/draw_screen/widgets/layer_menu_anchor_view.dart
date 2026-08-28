import 'dart:typed_data';

import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:drawing_app/ui/draw_screen/widgets/layer_preview_view.dart';
import 'package:flutter/material.dart';


class LayerMenuAnchor extends StatefulWidget {
  const LayerMenuAnchor({super.key, required DrawScreenViewModel viewModel}) : _viewModel = viewModel;

  final DrawScreenViewModel _viewModel;

  @override
  State<LayerMenuAnchor> createState() => _LayerMenuAnchorState();
}

class _LayerMenuAnchorState extends State<LayerMenuAnchor> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget._viewModel.createLayer,
      builder: (context, child) => 
      MenuAnchor(
        builder: (context, controller, child) {
          return IconButton(onPressed: () {
            controller.isOpen ? controller.close() : controller.open();
          }, icon: Icon(Icons.layers));
        },
        menuChildren: widget._viewModel.layers.map((layer) {
                                return Padding(
                                  padding: EdgeInsets.all(0),
                                  child: LayerPreviewWidget(layerId: layer.id, viewModel: widget._viewModel,)
                                );
                              }).toList(),
      ),
    );
  }
}

