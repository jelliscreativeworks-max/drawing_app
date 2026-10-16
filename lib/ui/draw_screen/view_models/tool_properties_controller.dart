import 'package:drawing_app/domain/models/property_data/property_data.dart';
import 'package:drawing_app/domain/models/property_data/property_type.dart';
import 'package:drawing_app/ui/draw_screen/view_models/tool_controller.dart';
import 'package:flutter/material.dart';

class ToolPropertiesController extends ChangeNotifier {
  ToolPropertiesController({required ToolController toolController}) 
      : _toolController = toolController {
    

    _syncProperties();

    _toolController.addListener(_onToolControllerUpdated);
  }

  final ToolController _toolController;
  List<PropertyData> _cachedProperties = [];

  PropertyId? _lastModifiedId;

  PropertyId? get lastModifiedId => _lastModifiedId;

  List<PropertyData> get loadedProperties => _cachedProperties;

  void _onToolControllerUpdated() {
    _syncProperties();
  }

  void _syncProperties() {
    final tool = _toolController.currentTool;
    
    final newProperties = tool.getToolProperties(_onPropertyChanged);

    _cachedProperties = newProperties;
    notifyListeners();
  }

  void _onPropertyChanged(PropertyId id) {
    _lastModifiedId = id;
    _syncProperties();
  }

  @override
  void dispose() {
    _toolController.removeListener(_onToolControllerUpdated);
    super.dispose();
  }
}
