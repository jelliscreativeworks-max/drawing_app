import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/domain/models/draw_data/draw_data.dart';

class EraseDrawCommand extends CanvasCommand {
  final List<CanvasHistoryEntry> erasedDrawData;  

  EraseDrawCommand({
    required super.layerId,
    required super.index, // Represents the chronological timeline sequence tracking number
    required this.erasedDrawData,
  });

  @override
  void execute(CanvasStateContext context) {
    // 1. Gather all values to remove into a Set for O(1) instant hash lookups
    final targets = erasedDrawData.map((data) => data.drawData).toSet();

    // 2. Scan the flat render timeline array exactly once, stripping out matches in-place
    context.globalDrawHistory.removeWhere((data) => targets.contains(data));
  }

  @override
  void undo(CanvasStateContext context) {
    // 1. Sort the history entry logs by their original sequential position.
    // Sorting ascending guarantees that when we re-insert them, they don't shift each other's indexes!
    final sorted = List<CanvasHistoryEntry>.from(erasedDrawData)
      ..sort((a, b) => a.originalIndex.compareTo(b.originalIndex));

    // 2. Re-inject every stroke back into its precise historical depth position
    for (final entry in sorted) {
      if (entry.originalIndex <= context.globalDrawHistory.length) {
        // 🟢 FIXED: Use entry.originalIndex instead of hardcoded 'index'
        context.globalDrawHistory.insert(entry.originalIndex, entry.drawData);
      } else {
        context.globalDrawHistory.add(entry.drawData);
      }
    }
  }
}

/// A clean history container tracking exactly where a vector stroke sat 
/// inside the flat rendering timeline before an erasure pass occurred.
class CanvasHistoryEntry {
  final int originalIndex;
  final DrawData drawData;

  CanvasHistoryEntry({
    required this.originalIndex, 
    required this.drawData,
  });
}
