import 'package:drawing_app/domain/models/draw_tools/draw_tools_list.dart';
import 'package:drawing_app/domain/models/draw_tools/freehand_tool.dart';
import 'package:drawing_app/domain/models/draw_tools/pan_tool.dart';
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
          icon: Icon(Icons.pan_tool_rounded),
          onPressed: () => widget.viewModel.changeTool(DrawToolsList.pan),
          color: widget.viewModel.currentTool == DrawToolsList.pan ? Colors.blueAccent : null,
        ),
        IconButton(
          splashRadius: 24,
          icon: Icon(Icons.draw),
          onPressed: () => widget.viewModel.changeTool(DrawToolsList.freehand),
          color: widget.viewModel.currentTool == DrawToolsList.freehand ? Colors.blueAccent : null,
        ),
      ],
    );
  }
}

