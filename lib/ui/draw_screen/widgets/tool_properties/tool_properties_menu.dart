import 'package:drawing_app/domain/models/property_data/property_data.dart';
import 'package:drawing_app/ui/core/draw_tools/canvas_tool.dart';
import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:drawing_app/ui/draw_screen/view_models/tool_controller.dart';
import 'package:drawing_app/ui/draw_screen/widgets/tool_properties/property_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class ToolPropertiesMenu extends StatefulWidget {
  const ToolPropertiesMenu({super.key});

  @override
  State<ToolPropertiesMenu> createState() => _ToolPropertiesMenuState();
}

class _ToolPropertiesMenuState extends State<ToolPropertiesMenu> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final toolController = context.read<ToolController>();

    final hasProperties = context.select<ToolController, bool>(
      (controller) => controller.loadedProperties.isNotEmpty,
    );

    if (!hasProperties) {
      return const SizedBox.shrink();
    }

    final propertiesList = context.select<ToolController, List<PropertyData>>(
      (controller) => controller.loadedProperties,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isOpen)
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            constraints: const BoxConstraints(
              minWidth: 120,
              maxWidth: 180,
              minHeight: 80,
              maxHeight: 400,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: propertiesList.length,
              itemBuilder: (context, index) {
                final property = propertiesList[index];
                return PropertyListTile(
                  property: property,
                  toolController: toolController,
                );
              },
            ),
          ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(360),
          ),
          child: IconButton(
            onPressed: () => setState(() => _isOpen = !_isOpen),
            icon: const Icon(Icons.format_paint),
          ),
        ),
      ],
    );
  }
}
