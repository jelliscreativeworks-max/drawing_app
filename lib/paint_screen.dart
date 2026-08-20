
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
            final activeLayerHistory = paintController.layers[paintController.activeLayerIndex].layerDrawHistory;
            return GestureDetector(
            
            onPanStart: (details) =>
                paintController.startTool(details.localPosition),
            onPanUpdate: (details) => paintController.updateTool(details.localPosition),
            onPanEnd: (details) =>
                paintController.endTool(),

            child: CustomPaint(
              size: Size.infinite,
              painter: MyPainter(drawHistory: activeLayerHistory, drawTools: paintController.tools, activeCommand: paintController.activeCommand
              ),
              child: Container(
              ),
            ),
          );}
        ),

      bottomNavigationBar: BottomAppBar(
        child: IconButton(onPressed: () {}, icon: Icon(Icons.draw)),
      ),
    );
  }
}
