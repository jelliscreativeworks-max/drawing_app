import 'dart:ui';

import 'package:drawing_app/domain/models/property_data/property_data.dart';
import 'package:drawing_app/domain/models/property_data/property_type.dart';
import 'package:drawing_app/domain/models/tool_input_data/tool_input_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:drawing_app/ui/core/commands/erase_draw_command.dart';
import 'package:drawing_app/ui/core/draw_tools/history_consumer.dart';

class EraseTool extends DrawTool implements HistoryConsumer  {
  final List<CanvasHistoryEntry> _erasedDrawData = [];

  Set<String> get targetedForDeletion =>
      _erasedDrawData.map((entry) => entry.originalData.id).toSet();

  List<DrawData> _drawHistory = const [];
  String _currentLayerId = '';

  double _strokeWidth = 5.0;

  bool _isErasing = false;
  Offset? _lastActivePoint;

  EraseTool({
    required super.toolName,
    required super.toolIcon,

  });

  @override
  bool get isActive => _isErasing;

  @override
  void setHistorySnapshot(List<DrawData> drawHistory) =>
      _drawHistory = drawHistory;

  @override
  void onToolStart(
    ToolStartInput toolStartInput,
    String layerId,
    int strokeIndex,
  ) {
    _isErasing = true;
    _currentLayerId = layerId;
    _lastActivePoint = toolStartInput.snappedWorldPoint;
    _erasedDrawData.clear();

    _checkCollisions(
      toolStartInput.snappedWorldPoint,
      toolStartInput.snappedWorldPoint,
    );
  }

  @override
  void onToolUpdate(ToolUpdateInput toolUpdateInput, String layerId) {
    if (!_isErasing || _lastActivePoint == null) return;
    _checkCollisions(_lastActivePoint!, toolUpdateInput.snappedWorldPoint);
    _lastActivePoint = toolUpdateInput.snappedWorldPoint;
  }

  @override
  CanvasCommand? onToolEnd() {
    // 1. If no shapes were hit during this swipe session, return null early.
    if (!_isErasing || _erasedDrawData.isEmpty) {
      _isErasing = false;
      _lastActivePoint = null;
      return null;
    }

    _isErasing = false;
    _lastActivePoint = null;

    // By checking '_drawHistory.length' exactly when the finger lifts,
    // we capture the true chronological timeline placement of this transaction,
    // completely neutralizing any blank misses or layer swaps that came before it.
    final int dynamicCommitIndex = _drawHistory.length;

    final eraseCommand = EraseDrawCommand(
      layerId: _currentLayerId,
      index:
          dynamicCommitIndex, // Binds safely to the absolute top of the timeline
      erasedDrawData: List<CanvasHistoryEntry>.from(_erasedDrawData),
    );

    _erasedDrawData.clear();
    return eraseCommand;
  }

  void _checkCollisions(Offset p1, Offset p2) {
    final double eraserRadius = (_strokeWidth) / 2.0;

    for (int i = 0; i < _drawHistory.length; i++) {
      final data = _drawHistory[i];

      if (data.layerId != _currentLayerId) continue;

      // Prevent duplicate logging during the active gesture session
      final bool alreadyCached = _erasedDrawData.any(
        (entry) => entry.originalData == data,
      );
      if (alreadyCached) continue;
      bool hitDetected = data.checkPointCollision(p1, p2, eraserRadius);

      // 3. TRANSACTION REGISTER
      if (hitDetected) {
        // look up the live position matching the exact structural 'index' identifier property.
        final int liveCurrentIndex = _drawHistory.indexWhere(
          (stroke) => stroke.index == data.index,
        );

        if (liveCurrentIndex != -1) {
          _erasedDrawData.add(
            CanvasHistoryEntry(
              originalIndex: liveCurrentIndex,
              originalData: data,
            ),
          );
        }
      }
    }
  }

  @override
  List<PropertyData> get toolProperties {
    return [
      PropertyData.double(
        value: _strokeWidth,
        minValue: 0,
        maxValue: 20,
        id: const StrokeSizeId()
      ),
    ];
  }

  @override
  void updatePropertyStateValue(PropertyId<dynamic> targetId, newValue) {
    if(targetId is StrokeSizeId){
      _strokeWidth = newValue as double;
    }
  }
}
