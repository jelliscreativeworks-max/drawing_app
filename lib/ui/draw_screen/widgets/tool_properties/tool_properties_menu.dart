import 'package:drawing_app/domain/models/property_data/property_data.dart';
import 'package:drawing_app/ui/draw_screen/view_models/tool_properties_controller.dart';
import 'package:flutter/material.dart';

class ToolPropertiesMenu extends StatefulWidget{
  const ToolPropertiesMenu({super.key, required ToolPropertiesController toolPropertiesController}) : _toolPropertiesController = toolPropertiesController;

  final ToolPropertiesController _toolPropertiesController;

  @override
  State<ToolPropertiesMenu> createState() => _ToolPropertiesMenuState();
}

class _ToolPropertiesMenuState extends State<ToolPropertiesMenu> {
  bool _isOpen = false;
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(listenable: widget._toolPropertiesController, builder: (context, child) => widget._toolPropertiesController.loadedProperties.isEmpty ? SizedBox.shrink() : Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          _isOpen ? Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20)
              ),
                
            constraints: const BoxConstraints(
              minWidth: 120, 
              maxWidth: 140,
              minHeight: 80, 
              maxHeight: 400, 
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                ...widget._toolPropertiesController.loadedProperties.map((property) => property.toWidget())
              ]) 
            ) : SizedBox.shrink(),
            SizedBox(height: 5,),
            Container(
              decoration: BoxDecoration(
                color:  Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(360)
                ),
              child: IconButton(onPressed: () => setState(() => _isOpen = !_isOpen), icon: Icon(Icons.format_paint))),
        ],
      ),
    ));
    
    // return Container(
    //   constraints: const BoxConstraints(
    //     minWidth: 120, 
    //     maxWidth: 140,
    //     minHeight: 80, 
    //     maxHeight: 400, 
    //   ),
    //   child: ListView(children: [
    //     ListTile(
    //       title: const Text('Property 1'),
    //       onTap: () {
    //         // Handle property 1 tap
    //       },
    //     ),
    //     ListTile(
    //       title: const Text('Property 2'),
    //       onTap: () {
    //         // Handle property 2 tap
    //       },
    //     ),
    //     // Add more properties as needed
    //   ]));
  }
}