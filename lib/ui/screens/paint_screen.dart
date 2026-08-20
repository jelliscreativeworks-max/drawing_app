import 'package:drawing_app/painter.dart';
import 'package:drawing_app/painter_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaintScreen extends StatelessWidget {
  const PaintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.save))],
      ),
      body: Consumer<PainterController>(
        builder: (context, paintController, child) {
          return Container(
            color:
                Colors.grey[200], 
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onPanStart: (details) =>
                        paintController.startTool(details.localPosition),
                    onPanUpdate: (details) =>
                        paintController.updateTool(details.localPosition),
                    onPanEnd: (details) => paintController.endTool(),

                    child: Stack(
                    children: paintController.layers.asMap().entries.map((entry) {
                      final int layerIndex = entry.key;
                      final drawLayer = entry.value;

                      final filteredLayerHistory = paintController.getHistoryForLayer(drawLayer.id);

                      return Positioned.fill(
                        child: RepaintBoundary(
                          child: CustomPaint(
                            key: ValueKey('${drawLayer.id}_${filteredLayerHistory.length}'),
                            painter: MyPainter(
                              drawHistory: filteredLayerHistory,
                              drawTools: paintController.tools,
                              activeCommand: layerIndex == paintController.activeLayerIndex
                                  ? paintController.activeCommand
                                  : null,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
                Align(
                  alignment: AlignmentGeometry.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.format_paint_outlined),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: paintController.drawHistory.isEmpty ? null : () => paintController.undo(), icon: Icon(Icons.undo)),
                      IconButton(onPressed:paintController.redoHistory.isEmpty ? null : () => paintController.redo(), icon: Icon(Icons.redo)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),

      bottomNavigationBar: BottomAppBar(
        child: IconButton(onPressed: () {}, icon: Icon(Icons.draw)),
      ),
    );
  }
}
