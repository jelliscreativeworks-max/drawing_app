import 'package:drawing_app/domain/models/property_data/property_type.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:drawing_app/ui/core/widgets/box_icon.dart';
import 'package:flutter/material.dart';

extension ChoiceTypeIdExtension<T extends Enum> on ChoiceTypeId<T>{
  Widget? getIconForOption(T option){
    final ChoiceTypeId<T> self = this;

    if(self is FillTypeId){
      return {
        FillTypeOptions.filled : BoxIcon(color: Colors.black),
        FillTypeOptions.noFill : BoxIcon(color: Colors.transparent, border: Border.all(color: Colors.black, width: 2),)
      }[option];
    }

    return null;
  }
}