import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';

class DrawCommand extends CanvasCommand{
  final DrawData drawData;

  DrawCommand({required this.drawData}):super(layerId: drawData.layerId, index: drawData.index);

  @override
  void execute(CanvasStateContext context) {
    context.globalDrawHistory.add(drawData);
  }

  @override
  void undo(CanvasStateContext context) {
    context.globalDrawHistory.remove(drawData);
  }
}