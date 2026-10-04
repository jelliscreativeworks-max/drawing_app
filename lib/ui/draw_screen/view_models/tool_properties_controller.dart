import 'package:drawing_app/domain/models/property_data/property_data.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:drawing_app/ui/draw_screen/view_models/tool_controller.dart';
import 'package:flutter/material.dart';

class ToolPropertiesController extends ChangeNotifier {
  ToolPropertiesController({required ToolController toolController}) 
      : _toolController = toolController {
    
    if (_toolController.currentTool case DrawTool initialDrawTool) {
      _currentTool = initialDrawTool;
    }
    
    _toolController.addListener(_onToolChanged);
  }

  DrawTool? _currentTool;
  final ToolController _toolController;

  // 1. Generate the list dynamically on every read/notify step
  List<PropertyData> get loadedProperties {
    final tool = _currentTool;
    if (tool == null) return [];
    
    // We pass our controller's notifyListeners directly down to the tool's factories
    return tool.getToolProperties(notifyListeners);
  }

  void _onToolChanged() {
    final nextTool = _toolController.currentTool;

    if (nextTool is DrawTool && nextTool.runtimeType != _currentTool?.runtimeType) {
      _currentTool = nextTool;
      notifyListeners(); // This forces the dynamic getter to rebuild with the new tool's properties
    }
  }

  @override
  void dispose() {
    _toolController.removeListener(_onToolChanged);
    super.dispose();
  }
}

