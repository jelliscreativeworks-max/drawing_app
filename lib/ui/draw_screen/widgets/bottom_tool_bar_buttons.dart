import 'package:drawing_app/ui/core/draw_tools/circle_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/erase_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/line_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/path_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/rectangle_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/select_tool.dart';
import 'package:flutter/material.dart';
import 'package:drawing_app/ui/draw_screen/view_models/tool_controller.dart';
import 'package:drawing_app/ui/core/draw_tools/freehand_tool.dart'; // Assumed concrete file paths
import 'package:drawing_app/ui/core/draw_tools/pan_tool.dart';      // Assumed concrete file paths

class BottomToolBarButtons extends StatelessWidget {
  /// 🟢 NEW INJECTION: Inject your interaction configurations View Model.
  /// Following decoupled rules, tool selections are managed entirely here.
  final ToolController toolController;

  const BottomToolBarButtons({
    super.key, 
    required this.toolController,
  });

  @override
  Widget build(BuildContext context) {
    // Local Builder: Rebuilds ONLY when a user taps an icon profile,
    // leaving your heavy custom paint background artwork layers completely frozen.
    return ListenableBuilder(
      listenable: toolController,
      builder: (context, child) {
        // Extract the live active instances out of your controller registry
        final panToolInstance = toolController.tools[PanTool];
        final freehandToolInstance = toolController.tools[FreehandTool];
        final eraserToolInstance = toolController.tools[EraseTool];
        final rectangleToolInstance = toolController.tools[RectangleTool];
        final lineToolInstance = toolController.tools[LineTool];
        final circleToolInstance = toolController.tools[CircleTool];
        final pathToolInstance = toolController.tools[PathTool];
        final selectToolInstance = toolController.tools[SelectTool];

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (panToolInstance != null)
              IconButton(
                splashRadius: 24,
                icon: panToolInstance.toolIcon,
                tooltip: panToolInstance.toolName,
                onPressed: () => toolController.selectTool<PanTool>(),
                color: toolController.currentTool is PanTool ? Colors.blueAccent : Colors.black87,
              ),

            if (freehandToolInstance != null)
              IconButton(
                splashRadius: 24,
                icon: freehandToolInstance.toolIcon,
                tooltip: freehandToolInstance.toolName,
                onPressed: () => toolController.selectTool<FreehandTool>(),
                color: toolController.currentTool is FreehandTool ? Colors.blueAccent : Colors.black87,
              ),

              if (rectangleToolInstance != null)
              IconButton(
                splashRadius: 24,
                icon: rectangleToolInstance.toolIcon,
                tooltip: rectangleToolInstance.toolName,
                onPressed: () => toolController.selectTool<RectangleTool>(),
                color: toolController.currentTool is RectangleTool ? Colors.blueAccent : Colors.black87,
              ),

                if (circleToolInstance != null)
              IconButton(
                splashRadius: 24,
                icon: circleToolInstance.toolIcon,
                tooltip: circleToolInstance.toolName,
                onPressed: () => toolController.selectTool<CircleTool>(),
                color: toolController.currentTool is CircleTool ? Colors.blueAccent : Colors.black87,
              ),

                if (eraserToolInstance != null)
              IconButton(
                splashRadius: 24,
                icon: eraserToolInstance.toolIcon,
                tooltip: eraserToolInstance.toolName,
                onPressed: () => toolController.selectTool<EraseTool>(),
                color: toolController.currentTool is EraseTool ? Colors.blueAccent : Colors.black87,
              ),

                    if (pathToolInstance != null)
              IconButton(
                splashRadius: 24,
                icon: pathToolInstance.toolIcon,
                tooltip: pathToolInstance.toolName,
                onPressed: () => toolController.selectTool<PathTool>(),
                color: toolController.currentTool is PathTool ? Colors.blueAccent : Colors.black87,
              ),

            if (lineToolInstance != null)
              IconButton(
                splashRadius: 24,
                icon: lineToolInstance.toolIcon,
                tooltip: lineToolInstance.toolName,
                onPressed: () => toolController.selectTool<LineTool>(),
                color: toolController.currentTool is LineTool ? Colors.blueAccent : Colors.black87,
              ),

              if(selectToolInstance != null)
              IconButton(
                splashRadius: 24,
                icon: selectToolInstance.toolIcon,
                tooltip: selectToolInstance.toolName,
                onPressed: () => toolController.selectTool<SelectTool>(),
                color: toolController.currentTool is SelectTool ? Colors.blueAccent : Colors.black87,
              ),
          ],
        );
      },
    );
  }
}
