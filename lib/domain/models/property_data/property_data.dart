
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';


class PropertyData<T> {
  const PropertyData({
    required this.displayName,
    required this.propertyValue,
    required this.onChanged,
  });


  final String displayName;
  final T propertyValue;
  final ValueChanged<T> onChanged;
}
