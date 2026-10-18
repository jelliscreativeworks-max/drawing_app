import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/domain/models/property_data/property_data.dart';
import 'package:drawing_app/domain/models/property_data/property_type.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/draw_tools/canvas_tool.dart';
import 'package:drawing_app/utils/widgets/box_icon.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:uuid/uuid.dart';

const Uuid uuid = Uuid();
abstract class DrawTool extends CanvasTool{

  DrawTool({required super.toolName, required super.toolIcon});

  List<DrawData> get activePreview => const [];

  

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

mixin StrokeTool{
  Paint strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5.0;

  StrokeTypeOptions strokeTypeOptions = StrokeTypeOptions.solid;

  List<PropertyData> get strokeProperties => [
    PropertyData.double(value: strokePaint.strokeWidth, maxValue: 20, minValue: 0, id: const StrokeSizeId()),
    PropertyData.color(value: strokePaint.color, id: const StrokeColorId())
  ];

  bool updateStrokeProperty(PropertyId id, newValue){
    if(id is StrokeColorId){
      strokePaint = strokePaint..color = newValue as Color;
      return true;
    } else if(id is StrokeSizeId){
      strokePaint = strokePaint..strokeWidth = newValue as double;
      return true;
    } else{
      return false;
    }
  }

}

@JsonEnum()
enum StrokeTypeOptions{
  @JsonValue(0) noStroke('No Stroke'),
  @JsonValue(1) solid('Solid');

  const StrokeTypeOptions(this.displayName);

  final String displayName;
}

@JsonEnum()
enum FillTypeOptions{
  @JsonValue(0) noFill('No Fill'),
  @JsonValue(1) filled('Filled');

  const FillTypeOptions(this.displayName);

  final String displayName;
}

mixin FillTool{
  Paint fillPaint = Paint();

  FillTypeOptions fillTypeOptions = FillTypeOptions.filled;
  
  List<PropertyData> get fillProperties => [
    PropertyData.color(value: fillPaint.color, id: FillColorId()),
    PropertyData.choice(value: fillTypeOptions, options: FillTypeOptions.values, id: const FillTypeId())
  ];

  bool updateFillProperties(PropertyId id, dynamic newValue){
    if(id is FillColorId){
      fillPaint.color = newValue as Color;
      return true;
    } else if(id is FillTypeId){
      fillTypeOptions = newValue;
      return true;
    } else{
      return false;
    }
  }
}

