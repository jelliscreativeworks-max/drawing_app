import 'package:drawing_app/ui/core/draw_tools/erase_tool.dart';
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

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ==========================================
            // A. CAMERA VIEWPORT NAVIGATION PAN TOOL
            // ==========================================
            if (panToolInstance != null)
              IconButton(
                splashRadius: 24,
                icon: panToolInstance.toolIcon,
                tooltip: panToolInstance.toolName,
                // 🟢 FIXED: Uses type generics to cleanly trigger the selection assignment
                onPressed: () => toolController.selectTool<PanTool>(),
                // 🟢 FIXED: References runtimeType checks to highlight the active menu selection
                color: toolController.currentTool is PanTool ? Colors.blueAccent : Colors.white70,
              ),

            // ==========================================
            // B. VECTOR LINE FREEHAND DRAW TOOL
            // ==========================================
            if (freehandToolInstance != null)
              IconButton(
                splashRadius: 24,
                icon: freehandToolInstance.toolIcon,
                tooltip: freehandToolInstance.toolName,
                onPressed: () => toolController.selectTool<FreehandTool>(),
                color: toolController.currentTool is FreehandTool ? Colors.blueAccent : Colors.white70,
              ),

            // ==========================================
            // C. VECTOR STROKE ERASER TOOL
            // ==========================================
            if (eraserToolInstance != null)
              IconButton(
                splashRadius: 24,
                icon: eraserToolInstance.toolIcon,
                tooltip: eraserToolInstance.toolName,
                onPressed: () => toolController.selectTool<EraseTool>(),
                color: toolController.currentTool is EraseTool ? Colors.blueAccent : Colors.white70,
              ),
          ],
        );
      },
    );
  }
}
