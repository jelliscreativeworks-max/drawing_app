import 'package:drawing_app/domain/models/property_data/property_data.dart';
import 'package:drawing_app/ui/core/draw_tools/canvas_tool.dart';
import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:drawing_app/ui/draw_screen/view_models/tool_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ToolPropertiesMenu extends StatefulWidget{
  const ToolPropertiesMenu({super.key});



  @override
  State<ToolPropertiesMenu> createState() => _ToolPropertiesMenuState();
}

class _ToolPropertiesMenuState extends State<ToolPropertiesMenu> {
  bool _isOpen = false;
  @override
  Widget build(BuildContext context) {
    final ToolController toolController = context.read<ToolController>();

    final currentTool = context.select<ToolController, CanvasTool>((controller) => controller.currentTool);

    if(currentTool.toolProperties.isEmpty){
      _isOpen = false;
      return SizedBox.shrink();
    } else{

    return Column(
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
              maxWidth: 200,
              minHeight: 80, 
              maxHeight: 400, 
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                ...toolController.loadedProperties.map((property) => property.toListTileWidget(context, toolController))
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
      );
  
  }}
}