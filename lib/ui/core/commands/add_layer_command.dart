import 'package:drawing_app/domain/models/layer_data/layer_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';

class AddLayerCommand extends CanvasCommand{
  final LayerData layerData;


  AddLayerCommand({required super.layerId, required super.index, required this.layerData});

  @override
  void execute(CanvasStateContext context) {
    context.layerData.insert(index, layerData);

    if(layerData.layerDrawHistory.isNotEmpty){
      context.globalDrawHistory.addAll(layerData.layerDrawHistory);
    }
  }

  @override
  void undo(CanvasStateContext context) {
    context.layerData.remove(layerData);

    if(layerData.layerDrawHistory.isNotEmpty){
         final targets = layerData.layerDrawHistory.toSet();

    context.globalDrawHistory.removeWhere((data) => targets.contains(data));
    }
  }
  
}