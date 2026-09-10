import 'package:drawing_app/domain/models/layer_data/layer_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';

class DeleteLayerCommand extends CanvasCommand {
  final LayerData deletedLayer;

  DeleteLayerCommand({
    required super.layerId, 
    required super.index, 
    required this.deletedLayer,
  });

  @override
  void execute(CanvasStateContext context) {
    // 1. 🟢 THE IDENTITY PASS: Prune the layer strictly by matching its unique String ID token.
    // This is 100% immune to copyWith object cloning variations!
    context.layerData.removeWhere((layer) => layer.id == layerId);

    // 2. Remove the layer's associated lines cleanly from the global flat rendering timeline ledger
    if (deletedLayer.layerDrawHistory.isNotEmpty) {
      final targets = deletedLayer.layerDrawHistory.toSet();
      context.globalDrawHistory.removeWhere((data) => targets.contains(data));
    }
  }

  @override
  void undo(CanvasStateContext context) {
    // 3. Re-insert the deleted layer sheet cleanly back into its original index position slot
    context.layerData.insert(index, deletedLayer);

    // 4. Re-inject the layer's inner stroke history paths if they are present
    if (deletedLayer.layerDrawHistory.isNotEmpty) {
      context.globalDrawHistory.addAll(deletedLayer.layerDrawHistory);
      
      // 🟢 THE CHRONOLOGICAL TIMELINE FIX:
      // Always sort the flat history entries array by their intrinsic index markers on an undo.
      // This forces the restored drawing lines to snap back exactly underneath newer layers,
      // preventing background strokes from rendering out of order!
      context.globalDrawHistory.sort((a, b) => a.index.compareTo(b.index));
    }
  }
}
