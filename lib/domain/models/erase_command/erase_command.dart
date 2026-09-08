import 'dart:ui';

import 'package:drawing_app/domain/models/canvas_command/canvas_command.dart';
import 'package:drawing_app/domain/models/draw_command/draw_command.dart';
import 'package:drawing_app/domain/models/draw_tools/draw_tool.dart';
import 'package:drawing_app/utils/converters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'erase_command.freezed.dart';

@freezed
abstract class EraseCommand extends CanvasCommand with _$EraseCommand {
  const EraseCommand._({
    required super.layerId,
    required super.toolName,
    // required List<Offset> points
  });

  const factory EraseCommand({
    required String layerId,
    required String toolName,
    required Map<int, CanvasCommand> erasedCommands,
    //  @PaintConverter() Paint? strokeSettings,
    //  @PaintConverter() Paint? fillSettings,
    //  @OffsetConverter() required List<Offset> points
  }) = _EraseCommand;

  @override
  void addCommand({
    required List<DrawCommand> drawHistory,
    required List<CanvasCommand> undoHistory,
    required List<CanvasCommand> redoHistory,
  }) {

    if(erasedCommands.isEmpty) return;
    // 1. Gather all values to remove into a Set for O(1) instant lookups
    final targets = erasedCommands.values.toSet();

    // 2. Scan the List exactly once, removing matches in place
    drawHistory.removeWhere((item) => targets.contains(item));
    undoHistory.add(this);
    redoHistory.clear();
    
  }

  @override
  void undo({
    required List<DrawCommand> drawHistory,
    required List<CanvasCommand> undoHistory,
    required List<CanvasCommand> redoHistory,
  }) {
      // print(erasedCommands.length);
    // 2. Scan the List exactly once, removing matches in place
    for(MapEntry<int, CanvasCommand> erasedEntry in erasedCommands.entries){
    
        if(erasedEntry.value is DrawCommand){
          drawHistory.add(erasedEntry.value as DrawCommand);
          // drawHistory.insert(erasedEntry.key, erasedEntry.value as DrawCommand);
        }
    }

    undoHistory.remove(this);
    redoHistory.add(this);
  }

  @override
  void redo({
    required List<DrawCommand> drawHistory,
    required List<CanvasCommand> undoHistory,
    required List<CanvasCommand> redoHistory,
  }) {
    final targets = erasedCommands.values.toSet();

    // 2. Scan the List exactly once, removing matches in place
    drawHistory.removeWhere((item) => targets.contains(item));

    undoHistory.add(this);
    redoHistory.remove(this);
  }
}
