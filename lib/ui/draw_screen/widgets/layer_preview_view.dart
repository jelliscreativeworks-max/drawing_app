import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';

class LayerPreviewWidget extends StatefulWidget {
  final String layerId;
  final DrawScreenViewModel viewModel;
  
  /// Injected from your view panel sidebar ribbon loop layout (e.g. toolController.tools)
  final Map<Type, DrawTool> drawTools;

  const LayerPreviewWidget({
    super.key,
    required this.layerId,
    required this.viewModel,
    required this.drawTools,
  });

  @override
  State<LayerPreviewWidget> createState() => _LayerPreviewWidgetState();
}

class _LayerPreviewWidgetState extends State<LayerPreviewWidget> {
  @override
  void initState() {
    super.initState();
    _checkAndScheduleSnapshot();
  }

  @override
  void didUpdateWidget(covariant LayerPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Secure guard check: If the layout item shifts, ensure alternative tracks refresh
    if (oldWidget.layerId != widget.layerId || oldWidget.drawTools != widget.drawTools) {
      _checkAndScheduleSnapshot();
    }
  }

  void _checkAndScheduleSnapshot() {
    // HOT RESTART & COLD BOOT RECOVERY FIX: If memory caches are clear on initialization,
    // look up its concurrent command script blueprint and run an isolation calculation pass.
    if (widget.viewModel.layerSnapshots[widget.layerId] == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        
        // Give Flutter's master engine layout loop exactly 1 tick to build visual dimensions
        // before we request background isolate image rendering computations
        await Future.delayed(Duration.zero);
        
        if (mounted) {
          // 🟢 FIXED: Successfully passes both mandatory arguments down the timeline pipeline map
          widget.viewModel
              .getSnapshotCommandForLayer(widget.layerId, widget.drawTools)
              .execute(widget.layerId, widget.drawTools);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pull the specific command tracker instance from our centralized map registry
    final layerCommand = widget.viewModel.getSnapshotCommandForLayer(widget.layerId, widget.drawTools);

    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.viewModel, // Listens to row layer selection adjustments
        layerCommand,     // Listens to async .running snapshot generation cycles
      ]),
      builder: (context, child) {
        final cachedBytes = widget.viewModel.layerSnapshots[widget.layerId];
        final isSelected = widget.viewModel.activeLayerId == widget.layerId;
        final isThisLayerProcessing = layerCommand.running;

        return Material(
          type: MaterialType.button,
          // 🟢 FIXED: Corrected abstract BorderRadiusGeometry typo to explicit concrete BorderRadius
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: isSelected 
                ? const BorderSide(color: Colors.blueAccent, width: 2.0) 
                : BorderSide(color: Colors.grey.shade800, width: 1.0),
          ),
          color: Colors.grey.shade50,
          child: Ink(
            width: 60,
            height: 60,
            child: InkWell(
              splashFactory: NoSplash.splashFactory,
              // Cleaned selection focus mapping assignment loop:
              onTap: () => widget.viewModel.setActiveLayer(
                widget.viewModel.layers.indexWhere((l) => l.id == widget.layerId),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // A. Transparent Grid Checker Blueprint Canvas Back-Background
                  Positioned.fill(
                    child: Container(color: Colors.grey.shade900),
                  ),

                  // B. Stable Image Snapshot Binary Bytes Render
                  if (cachedBytes != null && cachedBytes.isNotEmpty)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Image.memory(
                          cachedBytes, 
                          fit: BoxFit.contain, 
                          gaplessPlayback: true, // Prevents annoying white flickering during real-time brush strokes
                        ),
                      ),
                    ),
                      
                  // C. High-Performance Overlay Loader Spinner Indicator
                  if (isThisLayerProcessing)
                    Container(
                      color: Colors.black45, // Dim background sheet slightly while drawing
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
