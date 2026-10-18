import 'package:drawing_app/domain/models/property_data/property_data.dart';
import 'package:drawing_app/ui/draw_screen/view_models/tool_controller.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class PropertyListTile extends StatelessWidget {
  final PropertyData property;
  final ToolController toolController;
  const PropertyListTile({super.key, required this.property, required this.toolController});

  @override
  Widget build(BuildContext context) {
    return property.map(
      color: (data) => _ColorPropertyListTile(data: data, toolController: toolController), 
      toggle: (data) => ListTile(title: Text(data.displayName)), 
      choice: (data) => ListTile(title: Text(data.displayName)), 
      string: (data) => ListTile(title: Text(data.displayName)), 
      double: (data) => _DoublePropertyListTile(data: data, toolController: toolController));
  }
}

class _ColorPropertyListTile extends StatelessWidget {
  const _ColorPropertyListTile({required this.data, required this.toolController});

  final ColorPropertyData data;
  final ToolController toolController;

  @override
  Widget build(BuildContext context) {
    final colorNotifier = toolController.getNotifierForProperty<Color>(data.id);

    if(colorNotifier == null) return SizedBox.shrink();

    return ValueListenableBuilder(
      valueListenable: colorNotifier,
      builder: (context, currentValue, child) {
        return ListTile(
                title: Text(data.displayName), 
                trailing: ColorIndicator(
                  width: 30,
                  height: 30,
                  color: currentValue,
                  onSelect: () async {
                    final Color newColor = await showColorPickerDialog(context, currentValue);
                    toolController.updateToolProperty(data.id, newColor);
                   
                  } ,
                ),);
      }
    );
  }
}

class _DoublePropertyListTile extends StatelessWidget {
  const _DoublePropertyListTile({required this.data, required this.toolController});

  final DoublePropertyData data;
  final ToolController toolController;

  @override
  Widget build(BuildContext context) {
    final doubleNotifier = toolController.getNotifierForProperty<double>(data.id);

    if(doubleNotifier == null) return SizedBox.shrink();

    return ValueListenableBuilder(valueListenable: doubleNotifier, builder:(context, currentValue, child) {
      return ListTile(
          title: Text(data.displayName),
          subtitle: SliderTheme(
            data: Theme.of(context).sliderTheme.copyWith(
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            ),
            child: Slider(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              value: currentValue,
              // These now dynamically update instantly if the property configuration itself changes
              min: data.minValue,
              max: data.maxValue,
              onChanged: (val) => toolController.updateToolProperty(data.id, val),
            ),
          ),
        );
    });
  }
}