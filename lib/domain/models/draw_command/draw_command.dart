import 'dart:ui';

import 'package:drawing_app/domain/models/canvas_command/canvas_command.dart';
import 'package:drawing_app/domain/models/draw_tools/draw_tool.dart';
import 'package:drawing_app/utils/converters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'draw_command.freezed.dart';  
part 'draw_command.g.dart';  

@freezed
abstract class DrawCommand extends CanvasCommand with _$DrawCommand{
  
  const DrawCommand._({
    required super.layerId,
    required super.toolName,
    // required List<Offset> points
  });

  const factory DrawCommand({
     required String layerId,
     required String toolName,
     @PaintConverter() Paint? strokeSettings,
     @PaintConverter() Paint? fillSettings,
     @OffsetConverter() required List<Offset> points
  }) = _DrawCommand;

  factory DrawCommand.fromJson(Map<String, dynamic> json) => _$DrawCommandFromJson(json);

  void draw(Canvas canvas, DrawTool tool) {
    tool.draw(canvas, this);
  }

  @override
  void addCommand({required List<DrawCommand> drawHistory, required List<CanvasCommand> undoHistory, required List<CanvasCommand> redoHistory}) {
    drawHistory.add(this);
    undoHistory.add(this);
    redoHistory.clear();
    }
  

  @override
  void undo({required List<DrawCommand> drawHistory, required List<CanvasCommand> undoHistory, required List<CanvasCommand> redoHistory}) {
    drawHistory.remove(this);
    redoHistory.add(this);
    undoHistory.remove(this);
  }

  @override
  void redo({required List<DrawCommand> drawHistory, required List<CanvasCommand> undoHistory, required List<CanvasCommand> redoHistory}) {
    drawHistory.add(this);
    redoHistory.remove(this);
    undoHistory.add(this);
  }


}