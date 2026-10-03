import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/domain/models/property_data/property_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/draw_tools/canvas_tool.dart';
import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';

const Uuid uuid = Uuid();
abstract class DrawTool extends CanvasTool{

  DrawTool({required super.toolName, required super.toolIcon});

  List<DrawData> get activePreview => const [];

  List<PropertyData> getToolProperties();

  CanvasCommand? onPanOverrideStart(){
    if(isActive){
      CanvasCommand? command = onToolEnd();

      return command;
    } else{
      return null;
    }
  }
  void onPanOverrideEnd(){}

}

abstract class StrokeToolType{
  Paint get strokePaint;
  bool get renderStroke;

  void updateStrokePaint(Paint updatedStrokePaint);

  void toggleRenderStroke(bool enabled);
}

abstract class FillToolType{
  Paint get fillPaint;
  bool get renderFill;

  void updateFillPaint(Paint updatedFillPaint);
  void toggleRenderFill(bool enabled);
}

