import 'package:drawing_app/ui/draw_screen/view_models/tool_controller.dart';
import 'package:drawing_app/ui/draw_screen/widgets/tool_properties/property_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ToolPropertiesMenu extends StatelessWidget {
  const ToolPropertiesMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final hasProperties = context.select<ToolController, bool>(
      (controller) => controller.loadedProperties.isNotEmpty,
    );

    if (!hasProperties) {
      return const SizedBox.shrink();
    }

    final toolController = context.read<ToolController>();

    return MenuAnchor(
      alignmentOffset: const Offset(0, 8),
      style: MenuStyle(
        alignment: Alignment.bottomLeft,
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      builder: (context, controller, child) {
        return IconButton.filled(
          isSelected: controller.isOpen,
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(Icons.format_paint),
        );
      },
menuChildren: [
  SizedBox(
    width: 180,
    child: ChangeNotifierProvider<ToolController>.value(
      value: toolController,
      child: Consumer<ToolController>(
        builder: (context, controller, child) {
          final propertiesList = controller.loadedProperties;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              
              mainAxisSize: MainAxisSize.min, 
              children: List.generate(
                propertiesList.length,
                (index) {
                  final property = propertiesList[index];
                  return PropertyListTile(
                    property: property,
                    toolController: controller,
                  );
                },
              ),
              
            ),
          );
        },
      ),
    ),
  ),
],

    );
  }
}
