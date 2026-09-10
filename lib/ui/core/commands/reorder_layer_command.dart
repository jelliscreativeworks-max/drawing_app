import 'package:drawing_app/ui/core/commands/canvas_command.dart';

class ReorderLayerCommand extends CanvasCommand {
  final int oldIndex;
  final int newIndex;

  ReorderLayerCommand({
    required super.layerId,
    required this.oldIndex,
    required this.newIndex,
    required int currentHistoryLength,
  }) : super(index: currentHistoryLength);

  @override
  void execute(CanvasStateContext context) {
    _reorderList(context.layerData, oldIndex, newIndex);
  }

  @override
  void undo(CanvasStateContext context) {
    // 1. 🟢 THE UNDO FIX: Find exactly where our target layer is sitting in the array right now!
    // Since 'execute' already ran, its position might not perfectly equal 'newIndex' 
    // due to Flutter's forward-index adjustments.
    final int currentPositionIndex = context.layerData.indexWhere(
      (layer) => layer.id == layerId,
    );

    if (currentPositionIndex != -1) {
      // 2. 🟢 Move it from its true current position directly back to its pristine 'oldIndex'
      _reorderList(context.layerData, currentPositionIndex, oldIndex);
    }
  }

  /// Internal list mover utility matching Flutter's ReorderableListView mechanics.
  void _reorderList(List<dynamic> list, int source, int destination) {
    if (source < 0 || source >= list.length) return;
    
    int target = destination;
    
    // Adjust target index if shifting an item down past subsequent entries
    if (source < target) {
      target -= 1;
    }
    
    if (target < 0 || target > list.length) return;

    final item = list.removeAt(source);
    list.insert(target, item);
  }
}
