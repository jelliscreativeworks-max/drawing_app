import 'package:drawing_app/domain/models/property_data/property_data.dart';
import 'package:drawing_app/domain/models/property_data/property_type.dart';
import 'package:drawing_app/ui/draw_screen/view_models/tool_controller.dart';
import 'package:drawing_app/ui/ui_extensions/property_data_extensions.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class PropertyListTile extends StatelessWidget {
  final PropertyData property;
  final ToolController toolController;
  const PropertyListTile({
    super.key,
    required this.property,
    required this.toolController,
  });

  @override
  Widget build(BuildContext context) {
    return property.map(
      color: (data) =>
          _ColorPropertyListTile(data: data, toolController: toolController),
      toggle: (data) => ListTile(title: Text(data.displayName)),
      choice: (data) =>
          _ChoicePropertyListTile(data: data, toolController: toolController),
      string: (data) => ListTile(title: Text(data.displayName)),
      double: (data) =>
          _DoublePropertyListTile(data: data, toolController: toolController),
    );
  }
}

class _ColorPropertyListTile extends StatelessWidget {
  const _ColorPropertyListTile({
    required this.data,
    required this.toolController,
  });

  final ColorPropertyData data;
  final ToolController toolController;

  @override
  Widget build(BuildContext context) {
    final colorNotifier = toolController.getNotifierForProperty<Color>(data.id);

    if (colorNotifier == null) return SizedBox.shrink();

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
              final Color newColor = await showColorPickerDialog(
                context,
                currentValue,
              );
              toolController.updateToolProperty(data.id, newColor);
            },
          ),
        );
      },
    );
  }
}

class _ChoicePropertyListTile extends StatelessWidget {
  const _ChoicePropertyListTile({
    required this.data,
    required this.toolController,
  });

  final ChoicePropertyData data;
  final ToolController toolController;

  @override
  Widget build(BuildContext context) {
    final choiceNotifier = toolController.getNotifierForProperty(data.id);

    if (choiceNotifier == null) return SizedBox.shrink();

    final ChoiceTypeId<Enum> propertyId = data.id as ChoiceTypeId<Enum>;

    return ValueListenableBuilder(
      valueListenable: choiceNotifier,
      builder: (context, currentSelection, child) {
        return ListTile(
          title: Text(data.displayName),
          subtitle: Row(
            spacing: 20,
            children: [
              ...data.options.map((option) {
                final Widget? icon = propertyId.getIconForOption(option.value);

                return Material(
                  clipBehavior: Clip.hardEdge,
                  borderRadius: BorderRadius.circular(8.0),
                  color: option.value == currentSelection
                      ? Colors.blueAccent
                      : const Color.fromARGB(255, 235, 235, 235),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.0),
                    onTap: () =>
                        toolController.updateToolProperty(propertyId, option.value),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: icon,
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _DoublePropertyListTile extends StatelessWidget {
  const _DoublePropertyListTile({
    required this.data,
    required this.toolController,
  });

  final DoublePropertyData data;
  final ToolController toolController;

  @override
  Widget build(BuildContext context) {
    final doubleNotifier = toolController.getNotifierForProperty<double>(
      data.id,
    );

    if (doubleNotifier == null) return SizedBox.shrink();

    return ValueListenableBuilder(
      valueListenable: doubleNotifier,
      builder: (context, currentValue, child) {
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
              onChanged: (val) =>
                  toolController.updateToolProperty(data.id, val),
            ),
          ),
        );
      },
    );
  }
}
