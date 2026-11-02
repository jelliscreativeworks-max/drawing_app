import 'package:collection/collection.dart';
import 'package:drawing_app/ui/core/draw_tools/canvas_tool.dart';
import 'package:flutter/material.dart';

class MultiToolIconButton extends StatefulWidget {
  MultiToolIconButton({super.key, required List<CanvasTool> tools, required Function(CanvasTool) onToolSelected}) : _tools = tools, _onToolSelected = onToolSelected, assert(tools.isNotEmpty);
  final List<CanvasTool> _tools;

  final Function(CanvasTool) _onToolSelected;

  Function(CanvasTool) get onToolSelected => _onToolSelected;

  @override
  State<MultiToolIconButton> createState() => _MultiToolIconButtonState();
}

class _MultiToolIconButtonState extends State<MultiToolIconButton> {
  late CanvasTool _currentTool;

  @override
  void initState() {
    _currentTool = widget._tools.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<CanvasTool> nonSelectedTools = List.from(widget._tools.whereNot((tool) => tool != _currentTool));

    return  MenuAnchor(
              builder: (context, controller, child) {
                return IconButton.filled(
                  isSelected: controller.isOpen, 
                  onPressed: () => controller.isOpen ? controller.close() : controller.open(),
                  icon: _currentTool.toolIcon);
              },
              menuChildren: [
                SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      nonSelectedTools.length, 
                      (index) {
                        return IconButton(onPressed: widget._onToolSelected(nonSelectedTools[index]), icon: nonSelectedTools[index].toolIcon);
                      }),
                  ),)
            ]);
  }
}