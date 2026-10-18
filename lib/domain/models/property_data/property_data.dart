import 'package:drawing_app/domain/models/property_data/property_type.dart';
import 'package:drawing_app/ui/draw_screen/view_models/tool_controller.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'property_data.freezed.dart';

// class PropertyData<T> {
//   const PropertyData({
//     required this.displayName,
//     required this.propertyValue,
//     required this.onChanged,
//   });

//   final String displayName;
//   final T propertyValue;
//   final ValueChanged<T> onChanged;
// }



@freezed
sealed class PropertyData<T> with _$PropertyData<T> {
  PropertyData._();

  factory PropertyData.color({
    required Color value,
    required PropertyId<Color> id,
  }) = ColorPropertyData<T>;

  factory PropertyData.toggle({
    required bool value,
    required PropertyId<bool> id,
  }) = TogglePropertyData<T>;

  factory PropertyData.choice({
    required T value,
    required List<T> options,
    required PropertyId id,
  }) = ChoicePropertyData<T>;

    factory PropertyData.string({
    required String value,
    required PropertyId<String> id,
  }) = StringPropertyData<T>;

  factory PropertyData.double({
    required double value,
    required double maxValue,
    required double minValue,
    required PropertyId<double> id
  }) = DoublePropertyData<T>;

  String get displayName => id.displayName;
}



