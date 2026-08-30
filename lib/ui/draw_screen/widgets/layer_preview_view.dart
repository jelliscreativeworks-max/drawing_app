import 'dart:typed_data';
import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:drawing_app/utils/result.dart';
import 'package:flutter/material.dart';
class LayerPreviewWidget extends StatefulWidget {
  final String layerId;
  final DrawScreenViewModel viewModel;


  const LayerPreviewWidget({
    super.key,
    required this.layerId,
    required this.viewModel,
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
    // If the layer changes, check if we need to load data for the new ID
    if (oldWidget.layerId != widget.layerId) {
      _checkAndScheduleSnapshot();
    }
  }

  void _checkAndScheduleSnapshot() {
    // 🟢 HOT RESTART & COLD BOOT FIX: If memory cache is empty when this widget mounts,
    // look up its unique command instance and request an isolated snapshot pass.
    if (widget.viewModel.layerSnapshots[widget.layerId] == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        
        // Give the main canvas painter one tiny engine event loop tick 
        // to render its vector paths cleanly before we capture its pixels.
        await Future.delayed(Duration.zero);
        
        if (mounted) {
          widget.viewModel
              .getSnapshotCommandForLayer(widget.layerId)
              .execute(widget.layerId);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final layerCommand = widget.viewModel.getSnapshotCommandForLayer(widget.layerId);

    return ListenableBuilder(
      listenable: layerCommand,
      builder: (context, child) {
        final cachedBytes = widget.viewModel.layerSnapshots[widget.layerId];
        final isThisLayerProcessing = layerCommand.running;

        return Material(
          type: MaterialType.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(4),
            side: widget.viewModel.activeLayerId == widget.layerId ? BorderSide(color: Colors.blueAccent) : BorderSide.none),
          color: DrawScreenViewModel.canvasBackgroundColor,
          child: Ink(

            width: 60,
            height: 60,
            child: InkWell(
              splashFactory: NoSplash.splashFactory,
              onTap: () => widget.viewModel.activeLayerId == widget.layerId ? widget.viewModel.deleteLayer.execute(widget.layerId) :widget.viewModel.setActiveLayer(widget.layerId),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (cachedBytes != null && cachedBytes.isNotEmpty)
                    Image.memory(
                      cachedBytes, 
                      fit: BoxFit.contain, 
                      gaplessPlayback: true, // Prevents white flashes on brush strokes
                    )
                  // else
                  //   const Icon(Icons.image, color: Colors.grey),
                      
                  // if (isThisLayerProcessing)
                  //   const Center(
                  //     child: SizedBox(
                  //       width: 12, 
                  //       height: 12, 
                  //       child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  //     ),
                  //   ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
