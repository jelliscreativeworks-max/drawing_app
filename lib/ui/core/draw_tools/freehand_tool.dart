import 'dart:ui';
import 'package:drawing_app/domain/models/property_data/property_data.dart';
import 'package:drawing_app/domain/models/property_data/property_type.dart';
import 'package:drawing_app/domain/models/tool_input_data/tool_input_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/commands/draw_command.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';

class FreehandTool extends DrawTool with StrokeTool {
  FreehandData? _activeStroke;
  bool _isDrawing = false;


  FreehandTool({
    required super.toolName,
    required super.toolIcon,
  });

  @override
  bool get isActive => _isDrawing;
  @override
  List<DrawData> get activePreview =>
      _activeStroke != null ? [_activeStroke!] : const [];

  @override
  void onToolStart(
    ToolStartInput toolStartInput,
    String layerId,
    int strokeIndex,
  ) {
    _isDrawing = true;
    _activeStroke = FreehandData(
      layerId: layerId,
      strokePaint: Paint.from(strokePaint),
      id: uuid.v4(),
      index: strokeIndex,
      points: [toolStartInput.snappedWorldPoint],
      strokeType: strokeTypeOptions

    );
  }

  @override
  void onToolUpdate(ToolUpdateInput toolUpdateInput, String layerId) {
    if (!_isDrawing) return;
    final updatedPoints = List<Offset>.from(_activeStroke!.points)
      ..add(toolUpdateInput.snappedWorldPoint);
    _activeStroke = _activeStroke!.copyWith(points: updatedPoints);
  }

  @override
  CanvasCommand? onToolEnd() {
    if (!_isDrawing || _activeStroke == null) return null;

    _isDrawing = false;

    final completedStroke = _activeStroke;
    _activeStroke = null;

    return DrawCommand(drawData: completedStroke!);
  }

  @override
  List<PropertyData> get toolProperties {
    return [
     ...strokeProperties
    ];
  }

  @override
  void updatePropertyStateValue(PropertyId<dynamic> targetId, newValue) {
    if(updateStrokeProperty(targetId, newValue)) {
      return;
      }
  }
}
