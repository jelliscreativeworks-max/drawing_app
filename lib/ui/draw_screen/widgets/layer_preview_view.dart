import 'dart:typed_data';
import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:drawing_app/utils/result.dart';
import 'package:flutter/material.dart';

class LayerPreviewWidget extends StatelessWidget {
  final String layerId;
  final DrawScreenViewModel viewModel; // Pass viewModel to read cached map data

  const LayerPreviewWidget({
    super.key,
    required this.layerId,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    // 🟢 FIX: Fetch the isolated command instance dedicated exclusively to THIS layer
    final layerCommand = viewModel.getSnapshotCommandForLayer(layerId);

    return ListenableBuilder(
      // 🟢 FIX: Listen ONLY to this layer's individual command changes
      listenable: layerCommand,
      builder: (context, child) {
        // Read the processed snapshot bytes safely from your public getter map
        final cachedBytes = viewModel.layerSnapshots[layerId];
        
        // Check if THIS specific layer is currently running a background capture task
        final isThisLayerProcessing = layerCommand.running; 

        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(4),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Display the background snapshot pixels if cached
              if (cachedBytes != null && cachedBytes.isNotEmpty)
                Image.memory(
                  cachedBytes,
                  fit: BoxFit.contain,
                  gaplessPlayback: true, // Crucial: Stops flash flickering on updates
                )
              else
                const Icon(Icons.image, color: Colors.grey),

              // 2. Display an isolated loader on top of the old image while capturing updates
              if (isThisLayerProcessing)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                  ),
                ),
                
              // 3. Fallback visual check for errors
              if (layerCommand.error)
                const Positioned(
                  top: 2,
                  right: 2,
                  child: Icon(Icons.error, size: 12, color: Colors.red),
                ),
            ],
          ),
        );
      },
    );
  }
}
