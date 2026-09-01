import 'package:drawing_app/domain/models/draw_tools/draw_tools_list.dart';
import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:flutter/material.dart';

class BottomToolBarButtons extends StatefulWidget {
  const BottomToolBarButtons({super.key, required this.viewModel});

  final DrawScreenViewModel viewModel;

  @override
  State<BottomToolBarButtons> createState() => _BottomToolBarButtonsState();
}

class _BottomToolBarButtonsState extends State<BottomToolBarButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          splashRadius: 24,
          icon: DrawToolsList.pan.toolIcon,
          onPressed: () => widget.viewModel.changeTool(DrawToolsList.pan),
          color: widget.viewModel.currentTool == DrawToolsList.pan ? Colors.blueAccent : null,
        ),
        IconButton(
          splashRadius: 24,
          icon: DrawToolsList.freehand.toolIcon,
          onPressed: () => widget.viewModel.changeTool(DrawToolsList.freehand),
          color: widget.viewModel.currentTool == DrawToolsList.freehand ? Colors.blueAccent : null,
        ),
        IconButton(
          splashRadius: 24,
          icon: DrawToolsList.erase.toolIcon,
          onPressed: () => widget.viewModel.changeTool(DrawToolsList.erase),
          color: widget.viewModel.currentTool == DrawToolsList.erase ? Colors.blueAccent : null,
        ),
      ],
    );
  }
}

