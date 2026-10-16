import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/domain/models/property_data/property_data.dart';
import 'package:drawing_app/domain/models/property_data/property_type.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/draw_tools/canvas_tool.dart';
import 'package:drawing_app/utils/widgets/box_icon.dart';
import 'package:flutter/material.dart';

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

extension StrokeToolUiExtensions on StrokeToolType {
  /// Generates the standard property control list for managing stroke options
  List<PropertyData> getStrokeProperties(Function(PropertyId) onPropertyChanged) {
    return [
      PropertyData.double(
        displayName: 'Stroke Size',
        value: strokePaint.strokeWidth,
        minValue: 0,
        maxValue: 20,
        onChanged: (strokeWidth) {
          final updatedPaint = Paint.from(strokePaint)..strokeWidth = strokeWidth;
          updateStrokePaint(updatedPaint);
          onPropertyChanged(const StrokeSizeType());
          },
        id: const StrokeSizeType()
      ),
      PropertyData.color(
        displayName: 'Stroke Color',
        value: strokePaint.color,
        onChanged: (newColor) {
                    final updatedPaint = Paint.from(strokePaint)..color = newColor;
          updateStrokePaint(updatedPaint);
          onPropertyChanged(const GenericType());
        },
        id: const GenericType()
      ),
    ];
  }
}

extension FillToolUiExtensions on FillToolType {
  /// Generates the standard property control list for managing fill options
  List<PropertyData> getFillProperties(Function(PropertyId) onPropertyChanged) {
    return [
      PropertyData.choice(
        displayName: 'Fill Type',
        value: renderFill,
        options: {
          BoxIcon(size: 18,color: Colors.transparent, border: Border.all(color: Colors.black, width: 2)): false,
           BoxIcon(size: 18,color: Colors.black): true,
        },
        onChanged: (renderFill) {
          toggleRenderFill(renderFill);
          onPropertyChanged(const GenericType());
        },
        id: const GenericType()
      ),
      PropertyData.color(
        displayName: 'Fill Color',
        value: fillPaint.color,
        onChanged: (newColor) {
          final updatedPaint = Paint.from(fillPaint)..color = newColor;
          updateFillPaint(updatedPaint);
          onPropertyChanged(const GenericType());
        },
        id: const GenericType()
      ),
    ];
  }
}