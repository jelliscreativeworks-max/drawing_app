import 'dart:ui';

import 'package:drawing_app/domain/models/draw_command/draw_command.dart';
import 'package:drawing_app/domain/models/draw_tools/draw_tool.dart';



abstract class CanvasCommand {
final String _toolName;
final String _layerId;

String get toolName => _toolName;
String get layerId => _layerId;


void addCommand({  required List<DrawCommand> drawHistory,
  required List<CanvasCommand> undoHistory,
  required List<CanvasCommand> redoHistory});

void undo({
  required List<DrawCommand> drawHistory,
  required List<CanvasCommand> undoHistory,
  required List<CanvasCommand> redoHistory
  });

void redo({ 
   required List<DrawCommand> drawHistory,
  required List<CanvasCommand> undoHistory,
  required List<CanvasCommand> redoHistory});

const CanvasCommand({
  required String toolName,
  required String layerId} ) : _layerId = layerId, _toolName = toolName;

}