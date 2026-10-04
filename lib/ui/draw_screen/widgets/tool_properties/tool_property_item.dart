import 'package:drawing_app/domain/models/property_data/property_data.dart';
import 'package:flutter/material.dart';

class ToolPropertyItem extends StatefulWidget {
  const ToolPropertyItem({super.key, required PropertyData propertyData}) : _propertyData = propertyData;

  final PropertyData _propertyData;

  @override
  State<ToolPropertyItem> createState() => _ToolPropertyItemState();
}

class _ToolPropertyItemState extends State<ToolPropertyItem> {
  @override
  Widget build(BuildContext context) {
    switch(widget._propertyData){
      
      case ColorPropertyData<dynamic>():
        // TODO: Handle this case.
        throw UnimplementedError();
      case TogglePropertyData<dynamic>():
        // TODO: Handle this case.
        throw UnimplementedError();
      case ChoicePropertyData<dynamic>():
        // TODO: Handle this case.
        throw UnimplementedError();
      case DoublePropertyData<dynamic>():
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}