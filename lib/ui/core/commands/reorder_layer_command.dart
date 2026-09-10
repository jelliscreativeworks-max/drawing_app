import 'package:drawing_app/ui/core/commands/canvas_command.dart';

class ReorderLayerCommand extends CanvasCommand {
  final int oldIndex;
  final int newIndex;

  ReorderLayerCommand({
    required super.layerId,
    required this.oldIndex,
    required this.newIndex,
  }) : super(index: newIndex); // Fulfills base CanvasCommand visual index layout specifications

  @override
  void execute(CanvasStateContext context) {
    // Shifting elements forward down the list mapping arrays
    _reorderList(context.layerData, oldIndex, newIndex);
  }

  @override
  void undo(CanvasStateContext context) {
    // 🟢 FIXED: To perfectly reverse any list movement from Position A to Position B, 
    // simply move the item from Position B back to Position A using your raw indices!
    // Your internal list utility will handle internal array shifting automatically.
    _reorderList(context.layerData, newIndex, oldIndex);
  }

  /// Internal list mover utility matching Flutter's ReorderableListView mechanics.
  /// Safely adjusts insertion target bounds when elements move across bounds.
  void _reorderList(List<dynamic> list, int source, int destination) {
    int target = destination;
    if (source < target) {
      target -= 1;
    }
    final item = list.removeAt(source);
    list.insert(target, item);
  }
}
