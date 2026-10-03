import 'package:drawing_app/domain/models/property_data/property_data.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:drawing_app/ui/draw_screen/view_models/tool_controller.dart';
import 'package:flutter/material.dart';

class ToolPropertiesController extends ChangeNotifier {
  ToolPropertiesController({required ToolController toolController}) 
      : _toolController = toolController {
    

    if (_toolController.currentTool case DrawTool initialDrawTool) {
      _currentTool = initialDrawTool;
      _loadedProperties = initialDrawTool.getToolProperties();
    }
    
    _toolController.addListener(_onToolChanged);
  }

  DrawTool? _currentTool;
  List<PropertyData> _loadedProperties = [];
  final ToolController _toolController;

  List<PropertyData> get loadedProperties => _loadedProperties;

  void _onToolChanged() {
    final nextTool = _toolController.currentTool;

    if (nextTool is DrawTool && nextTool.runtimeType != _currentTool?.runtimeType) {
      _currentTool = nextTool;
      _loadedProperties = nextTool.getToolProperties();
      notifyListeners(); // This fires *only* when switching tool types
    }
  }

  @override
  void dispose() {
    _toolController.removeListener(_onToolChanged);
    super.dispose();
  }
}
