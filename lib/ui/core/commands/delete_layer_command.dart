import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/domain/models/layer_data/layer_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';

class DeleteLayerCommand extends CanvasCommand{
  final LayerData deletedLayer;


  DeleteLayerCommand({required super.layerId, required super.index, required this.deletedLayer});

  @override
  void execute(CanvasStateContext context) {
    context.layerData.remove(deletedLayer);

    if(deletedLayer.layerDrawHistory.isNotEmpty){
          final targets = deletedLayer.layerDrawHistory.toSet();

    context.globalDrawHistory.removeWhere((data) => targets.contains(data));
    }
  }

  @override
  void undo(CanvasStateContext context) {
    context.layerData.insert(index, deletedLayer);

    if(deletedLayer.layerDrawHistory.isNotEmpty){
      context.globalDrawHistory.addAll(deletedLayer.layerDrawHistory);
    }
    }
}