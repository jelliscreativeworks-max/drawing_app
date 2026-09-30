import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/commands/erase_draw_command.dart';

class TransformationCommand extends CanvasCommand {
  final List<CanvasHistoryEntry> transformedData;

  TransformationCommand({
    required super.layerId, 
    required super.index, 
    required this.transformedData,
  });

  @override
  void execute(CanvasStateContext context) {
    // 1. Map target IDs using originalData since that's what's currently in history before this execution pass
    final Map<String, DrawData> targetsMap = {
      for (final entry in transformedData) entry.originalData.id: entry.originalData
    };

    // 2. Strip the old configurations from the timeline ledger array
    context.globalDrawHistory.removeWhere((data) => targetsMap.containsKey(data.id));

    // 3. Sort ascending by originalIndex so we re-inject them without throwing off list index offsets
    final sorted = List<CanvasHistoryEntry>.from(transformedData)
      ..sort((a, b) => a.originalIndex.compareTo(b.originalIndex));

    // 4. Re-inject every transformed shape back into its precise chronological layout depth
    for (final entry in sorted) {
      if (entry.originalIndex <= context.globalDrawHistory.length) {
        context.globalDrawHistory.insert(entry.originalIndex, entry.transformedData);
      } else {
        context.globalDrawHistory.add(entry.transformedData);
      }
    }
  }

  @override
  void undo(CanvasStateContext context) {
    // 1. Map target IDs using transformedData since that's what's currently on screen
    final Map<String, DrawData> targetsMap = {
      for (final entry in transformedData) entry.transformedData.id: entry.transformedData
    };
    
    // 2. Clear out the transformed shapes
    context.globalDrawHistory.removeWhere((data) => targetsMap.containsKey(data.id));
    
    // 3. Sort ascending by originalIndex to guarantee clean insertion order
    final sorted = List<CanvasHistoryEntry>.from(transformedData)
      ..sort((a, b) => a.originalIndex.compareTo(b.originalIndex));

    // 4. Re-inject every pure baseline shape back into its exact starting depth position
    for (final entry in sorted) {
      if (entry.originalIndex <= context.globalDrawHistory.length) {
        context.globalDrawHistory.insert(entry.originalIndex, entry.originalData);
      } else {
        context.globalDrawHistory.add(entry.originalData);
      }
    }
  }
}
