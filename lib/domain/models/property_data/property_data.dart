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

extension ChoiceDataExtensions<T> on ChoicePropertyData<T>{
  Widget toDropdownWidet(BuildContext context, ToolController toolController){
   final ValueNotifier<dynamic> notifier = toolController.getNotifierForProperty(id);

   return ValueListenableBuilder<dynamic>(
    valueListenable: notifier, 
    builder:(context, currentValue, child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(displayName),
          const SizedBox(height: 6,),
          DropdownButton(value: currentValue,items: options.map((option){
            return DropdownMenuItem<dynamic>(
              value: option,
              child: Row(children: [
                // TODO Implement choice rendering 
              ],));
          }).toList(), onChanged: (newValue){
            if(newValue != null){
              toolController.updateToolProperty(id, newValue);
            }
          })
        ],
      );
    });
  }
}

extension PropertyDataExtensions on PropertyData {
  Widget toListTileWidget(BuildContext context, ToolController toolController) {
    final ValueNotifier<dynamic> notifier = toolController.getNotifierForProperty(id);
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (context, currentValue, child) {
        return map(
          color: (data) => ListTile(
            title: Text(data.displayName), 
            trailing: ColorIndicator(
              width: 30,
              height: 30,
              color: currentValue,
              onSelect: () async {
                final Color newColor = await showColorPickerDialog(context, currentValue);
                toolController.updateToolProperty(id, newColor);
               
              } ,
            ),),
          toggle: (data) => ListTile(title: Text(data.displayName)),
          choice: (data) => ListTile(title: Text(data.displayName), trailing: Text(data.value.toString()),),
        
          double: (data) => ListTile(
            title: Text(data.displayName),
            
            subtitle: SliderTheme(
              data: SliderThemeData().copyWith(
                overlayShape: RoundSliderOverlayShape(overlayRadius: 18)
              ),
              child: Slider(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                value: currentValue,
                max: data.maxValue,
                min: data.minValue,
                onChanged: (val) => toolController.updateToolProperty(id, val),
              ),
            ),
          ), string: (data) => ListTile(title: Text(data.displayName), trailing: Text(data.value),),
        );
      }
    );
  }
}
