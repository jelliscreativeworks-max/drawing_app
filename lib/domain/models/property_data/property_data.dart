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
  factory PropertyData.color({
    required String displayName,
    required Color value,
    required ValueChanged<Color> onChanged,
  }) = ColorPropertyData<T>;

  factory PropertyData.toggle({
    required String displayName,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) = TogglePropertyData<T>;

  factory PropertyData.choice({
    required String displayName,
    required T value,
    required Map<Widget, T> options,
    required ValueChanged<T> onChanged,
  }) = ChoicePropertyData<T>;

  factory PropertyData.double({
    required String displayName,
    required double value,
    required ValueChanged<double> onChanged,
  }) = DoublePropertyData<T>;
}

extension PropertyDataExtensions on PropertyData {
  Widget toWidget() {
    return map(
      color: (data) => ListTile(title: Text(data.displayName)),
      toggle: (data) => ListTile(title: Text(data.displayName)),
     choice: (data) => ListTile(
  title: Text(data.displayName, style: TextStyle(fontSize: 14),),
  subtitle: Row(
    spacing: 20,
    children: data.options.entries.map((entry) => Material(
      color: entry.value == data.value ? Colors.blueAccent : const Color.fromARGB(255, 235, 235, 235),
      borderRadius: BorderRadius.circular(8.0),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: () => data.onChanged(entry.value),
        child: Padding(
          padding: const EdgeInsets.all(8.0), 
          child: entry.key,
        ),
      ),
    )).toList(),
  ),
),

      double: (data) => ListTile(title: Text(data.displayName)),
    );
  }
}


