import 'package:drawing_app/domain/models/layer_data/layer_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';

class AddLayerCommand extends CanvasCommand {
  final LayerData layerData;

  AddLayerCommand({
    required super.layerId, 
    required super.index, 
    required this.layerData,
  });

  @override
  void execute(CanvasStateContext context) {
    final int safeInsertionIndex = index.clamp(0, context.layerData.length);
    
    // 🟢 THE REDO FIX: Create a completely fresh clone instance copy using copyWith()!
    // This alters the memory address hash pointer, forcing Flutter's ListenableBuilder 
    // to recognize the re-insertion instantly and redraw your layer previews.
    final LayerData layerClone = layerData.copyWith();

    context.layerData.insert(safeInsertionIndex, layerClone);

    if (layerClone.layerDrawHistory.isNotEmpty) {
      context.globalDrawHistory.addAll(layerClone.layerDrawHistory);
      context.globalDrawHistory.sort((a, b) => a.index.compareTo(b.index));
    }
  }

  @override
  void undo(CanvasStateContext context) {
    // Target destruction using absolute ID matching to remain immune to clone variations
    context.layerData.removeWhere((layer) => layer.id == layerId);

    if (layerData.layerDrawHistory.isNotEmpty) {
      final targets = layerData.layerDrawHistory.toSet();
      context.globalDrawHistory.removeWhere((data) => targets.contains(data));
    }
  }
}
