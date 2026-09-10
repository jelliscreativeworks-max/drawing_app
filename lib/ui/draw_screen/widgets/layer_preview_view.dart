import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:drawing_app/ui/draw_screen/view_models/tool_controller.dart';
import 'package:drawing_app/domain/models/draw_data/draw_data.dart';

class LayerPreviewWidget extends StatefulWidget {
  final String layerId;
  final DrawScreenViewModel viewModel;
  final ToolController toolController;

  const LayerPreviewWidget({
    super.key,
    required this.layerId,
    required this.viewModel,
    required this.toolController,
  });

  @override
  State<LayerPreviewWidget> createState() => _LayerPreviewWidgetState();
}

class _LayerPreviewWidgetState extends State<LayerPreviewWidget> {
  // Stable list reference cache to spot exact timeline changes across Undo/Redo cycles
  List<DrawData> _lastKnownHistorySnapshot = const [];

  @override
  void initState() {
    super.initState();
    _syncHistorySnapshotCache();
    _checkAndScheduleSnapshot();
    
    // Direct gesture listener: captures live brush and eraser stroke completions
    widget.toolController.addListener(_onToolStateChanged);
  }

  @override
  void dispose() {
    widget.toolController.removeListener(_onToolStateChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LayerPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.toolController != widget.toolController) {
      oldWidget.toolController.removeListener(_onToolStateChanged);
      widget.toolController.addListener(_onToolStateChanged);
    }

    // DELETION PROTECTION SHIELD: If this layer was just pruned from the list, abort immediately
    final bool layerStillExists = widget.viewModel.layers.any((l) => l.id == widget.layerId);
    if (!layerStillExists) return;

    // THE UNDO/REDO REACTION ENGINE:
    final List<DrawData> currentHistory = widget.viewModel.getHistoryForLayer(widget.layerId);

    // Instead of measuring flat lengths, we check if the exact elements match our cached array references.
    if (oldWidget.layerId != widget.layerId || !_areHistoriesIdentical(currentHistory, _lastKnownHistorySnapshot)) {
      _lastKnownHistorySnapshot = List<DrawData>.from(currentHistory);
      _checkAndScheduleSnapshot(force: true);
    }
  }

  void _syncHistorySnapshotCache() {
    final bool layerStillExists = widget.viewModel.layers.any((l) => l.id == widget.layerId);
    if (layerStillExists) {
      _lastKnownHistorySnapshot = List<DrawData>.from(
        widget.viewModel.getHistoryForLayer(widget.layerId),
      );
    }
  }

  /// Evaluates absolute element equivalence to catch out-of-order re-insertions during timeline rollbacks
  bool _areHistoriesIdentical(List<DrawData> listA, List<DrawData> listB) {
    if (listA.length != listB.length) return false;
    for (int i = 0; i < listA.length; i++) {
      if (listA[i] != listB[i]) return false;
    }
    return true;
  }

  void _onToolStateChanged() {
    // If the active tool just completed its touch painting/erasing session, evaluate the data state
    if (!widget.toolController.currentTool.isActive && mounted) {
      final bool layerStillExists = widget.viewModel.layers.any((l) => l.id == widget.layerId);
      if (!layerStillExists) return;

      final List<DrawData> currentHistory = widget.viewModel.getHistoryForLayer(widget.layerId);
      
      // Only execute a snapshot rewrite if the drawing gesture genuinely altered the dataset
      if (!_areHistoriesIdentical(currentHistory, _lastKnownHistorySnapshot)) {
        _lastKnownHistorySnapshot = List<DrawData>.from(currentHistory);
        _checkAndScheduleSnapshot(force: true);
      }
    }
  }

  void _checkAndScheduleSnapshot({bool force = false}) {
    if (force || widget.viewModel.layerSnapshots[widget.layerId] == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        
        final bool layerStillExists = widget.viewModel.layers.any((l) => l.id == widget.layerId);
        if (!layerStillExists) return;

        // Give the graphics pipeline exactly 1 frame tick to stabilize path metrics cleanly
        await Future.delayed(Duration.zero);
        
        if (mounted) {
          final drawToolsMap = widget.toolController.tools;
          widget.viewModel
              .getSnapshotCommandForLayer(widget.layerId, drawToolsMap)
              .execute(widget.layerId, drawToolsMap);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool layerStillExists = widget.viewModel.layers.any((l) => l.id == widget.layerId);
    if (!layerStillExists) return const SizedBox.shrink();

    final drawToolsMap = widget.toolController.tools;
    final layerCommand = widget.viewModel.getSnapshotCommandForLayer(widget.layerId, drawToolsMap);

    // Listens EXCLUSIVELY to the asynchronous layerCommand task background loops,
    // ensuring your preview cards remain completely immune to real-time zoom or pan matrix updates.
    return ListenableBuilder(
      listenable: layerCommand,
      builder: (context, child) {
        final cachedBytes = widget.viewModel.layerSnapshots[widget.layerId];
        final isSelected = widget.viewModel.activeLayerId == widget.layerId;
        final isThisLayerProcessing = layerCommand.running;

        // TIMELINE CHANGE FALLBACK: Catch background Undo/Redo timeline modifications gracefully
        final List<DrawData> currentHistory = widget.viewModel.getHistoryForLayer(widget.layerId);
        if (!_areHistoriesIdentical(currentHistory, _lastKnownHistorySnapshot)) {
          _lastKnownHistorySnapshot = List<DrawData>.from(currentHistory);
          _checkAndScheduleSnapshot(force: true);
        }

        return Material(
          type: MaterialType.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: isSelected 
                ? const BorderSide(color: Colors.blueAccent, width: 2.0) 
                : BorderSide(color: Colors.grey.shade800, width: 1.0),
          ),
          color: Colors.grey.shade900,
          child: Ink(
            width: 60,
            height: 60,
            child: InkWell(
              splashFactory: NoSplash.splashFactory,
              onTap: () {
                final int dynamicIndex = widget.viewModel.layers.indexWhere(
                  (l) => l.id == widget.layerId,
                );
                if (dynamicIndex != -1) {
                  widget.viewModel.setActiveLayer(dynamicIndex);
                }
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: Container(color: Colors.grey),
                  ),

                  if (cachedBytes != null && cachedBytes.isNotEmpty)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Image.memory(
                          cachedBytes, 
                          fit: BoxFit.contain, 
                          gaplessPlayback: true, 
                        ),
                      ),
                    ),
                      
                  if (isThisLayerProcessing)
                    Container(
                      color: Colors.black45, 
                      child: const Center(
                        child: SizedBox(
                          width: 14, 
                          height: 14, 
                          child: CircularProgressIndicator(
                            strokeWidth: 2, 
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
