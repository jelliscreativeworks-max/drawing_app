import 'package:drawing_app/domain/models/property_data/property_data.dart';
import 'package:drawing_app/ui/draw_screen/view_models/tool_controller.dart';
import 'package:drawing_app/ui/draw_screen/widgets/tool_properties/property_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ToolPropertiesMenu extends StatefulWidget {
  const ToolPropertiesMenu({super.key,});


  @override
  State<ToolPropertiesMenu> createState() => _ToolPropertiesMenuState();
}

class _ToolPropertiesMenuState extends State<ToolPropertiesMenu> {
  final LayerLink _layerLink = LayerLink();
      final buttonStateController = WidgetStatesController();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggleMenu() {
    if (_isOpen) {
      _overlayEntry?.remove();
    } else {
      _overlayEntry = _createOverlayEntry(context);
      Overlay.of(context).insert(_overlayEntry!);
    }

    setState(() {
      _isOpen = !_isOpen;
    });
  }

  OverlayEntry _createOverlayEntry(BuildContext originalContext) {

    final toolController = originalContext.read<ToolController>();


    return OverlayEntry(
      builder: (overlayContext) {
        return ChangeNotifierProvider<ToolController>.value(
          value: toolController,
          child: Consumer<ToolController>( 
            builder: (context, controller, child) {
              final propertiesList = controller.loadedProperties;

              return Positioned(
                width: 180,
                child: CompositedTransformFollower(
                  targetAnchor: Alignment.topLeft,
                  followerAnchor: Alignment.bottomLeft,
                  offset: Offset(0, -15),
                  link: _layerLink,
                  showWhenUnlinked: false,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: propertiesList.length,
                      itemBuilder: (context, index) {
                        final property = propertiesList[index];
                        return PropertyListTile(
                          property: property,
                          toolController: controller,
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void deactivate() {
    if (_isOpen) {
      _overlayEntry?.remove();
      _isOpen = false;
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _overlayEntry?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasProperties = context.select<ToolController, bool>(
      (controller) => controller.loadedProperties.isNotEmpty,
    );

    if (!hasProperties) {
      return const SizedBox.shrink();
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: IconButton.filled(
        isSelected: _isOpen,
        onPressed: _toggleMenu,
        icon: const Icon(Icons.format_paint),
      ),
    );
  }
}
