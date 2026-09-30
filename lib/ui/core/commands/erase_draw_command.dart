import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/domain/models/draw_data/draw_data.dart';

class EraseDrawCommand extends CanvasCommand {
  final List<CanvasHistoryEntry> erasedDrawData;  

  EraseDrawCommand({
    required super.layerId,
    required super.index, 
    required this.erasedDrawData,
  });

  @override
  void execute(CanvasStateContext context) {
    final Map<String, DrawData> targetsMap = {
      for (final entry in erasedDrawData) entry.originalData.id: entry.originalData
    };

    // 2. Scan the flat timeline ledger array exactly once, stripping out matches by ID
    context.globalDrawHistory.removeWhere((data) => targetsMap.containsKey(data.id));
  }

  @override
  void undo(CanvasStateContext context) {
    // 1. Sort the history entry logs by their original sequential position.
    // Sorting ascending guarantees that when we re-insert them, they don't shift each other's indexes
    final sorted = List<CanvasHistoryEntry>.from(erasedDrawData)
      ..sort((a, b) => a.originalIndex.compareTo(b.originalIndex));

    // 2. Re-inject every stroke back into its precise historical depth position
    for (final entry in sorted) {
      if (entry.originalIndex <= context.globalDrawHistory.length) {
        context.globalDrawHistory.insert(entry.originalIndex, entry.originalData);
      } else {
        context.globalDrawHistory.add(entry.originalData);
      }
    }
  }
}

/// A clean history container tracking exactly where a vector stroke sat 
/// inside the flat rendering timeline before an erasure pass occurred.
class CanvasHistoryEntry {
  final int originalIndex;
  final DrawData originalData;
  final DrawData transformedData;

  CanvasHistoryEntry({
    required this.originalIndex, 
    required this.originalData,
    DrawData? transformedData
  }) : transformedData = transformedData ?? originalData.copyWith();
}




