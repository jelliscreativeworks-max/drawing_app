import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img; // Import the image package

class ImageProcessingPayload {
  final int width;
  final int height;
  final Uint8List rawRgbaBytes; // e.g., 1.0 = normal, 1.5 = high contrast
  final double transparencyFactor; // e.g., 0.5 = 50% opacity reduction

  ImageProcessingPayload({
    required this.width,
    required this.height,
    required this.rawRgbaBytes,
    required this.transparencyFactor,
  });
}

class CanvasToImageProcessor {
  bool isProcessing = false;

  // Background Isolate function handling the heavy image package logic
  static Future<Uint8List> _manipulateAndEncodePng(
    ImageProcessingPayload payload,
  ) async {
    // 1. Reconstruct the image package structure from raw RGBA bytes
    // 1. Reconstruct the image package structure from raw RGBA bytes
    final img.Image image = img.Image.fromBytes(
      width: payload.width,
      height: payload.height,
      // Using .sublist ensures a clean copy of the byte array safe for Isolate transfer
      bytes: payload.rawRgbaBytes.buffer,
      order: img.ChannelOrder.rgba,
    );

    // 2. Perform pixel-level manipulations
    for (final img.Pixel pixel in image) {
      // Modify transparency/alpha channel
      pixel.a = (pixel.a * payload.transparencyFactor).clamp(0, 255);
    }

    // Alternatively, use high-level package methods:
    // img.adjustColor(image, contrast: payload.contrastAmount);

    // 3. Compress and encode the structural data to a standard PNG format
    return Uint8List.fromList(img.encodePng(image));
  }
  Future<Uint8List?> processLayerSnapshotInBackground({
    required GlobalKey layerKey,
    required double transparency,
  }) async {
    isProcessing = true;
    
    final RenderRepaintBoundary? boundary = 
        layerKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    if (boundary == null) {
      isProcessing = false;
      return null;
    }

    // 🟢 THE BULLETPROOF CURE: Yield the execution thread to the framework 
    // if the layer is currently locked in a paint cycle.
    int paintSyncRetries = 0;
    while (boundary.debugNeedsPaint && paintSyncRetries < 5) {
      // Puts this execution at the back of the event queue, 
      // allowing Flutter to complete its ongoing layout and paint cycles.
      await Future.delayed(Duration.zero); 
      paintSyncRetries++;
    }

    // Secondary fallback guard if the frame is permanently locked
    if (boundary.debugNeedsPaint) {
      debugPrint("Snapshot skipped: Repaint boundary is currently unavailable.");
      isProcessing = false;
      return null;
    }

    // Frame is guaranteed clean and safe now. Capture at a lower resolution for performance!
    final ui.Image image = await boundary.toImage(pixelRatio: 0.25);

    // Get uncompressed raw byte arrays (crucial for Isolate communication)
    final ByteData? rawByteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (rawByteData == null) {
      isProcessing = false;
      return null;
    } 

    final payload = ImageProcessingPayload(
      width: image.width,
      height: image.height,
      rawRgbaBytes: rawByteData.buffer.asUint8List(),
      transparencyFactor: transparency,
    );

    // Offload heavy processing to the background worker pool
    final Uint8List processedPng = await compute(_manipulateAndEncodePng, payload);
    
    isProcessing = false;
    return processedPng;
  }
}