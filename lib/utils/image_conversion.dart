
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img; // Import the image package

class ImageProcessingPayload {
  final int width;
  final int height;
  final Uint8List rawRgbaBytes;   // e.g., 1.0 = normal, 1.5 = high contrast
  final double transparencyFactor;  // e.g., 0.5 = 50% opacity reduction

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
  static Future<Uint8List> _manipulateAndEncodePng(ImageProcessingPayload payload) async {
    // 1. Reconstruct the image package structure from raw RGBA bytes
    final img.Image image = img.Image.fromBytes(
      width: payload.width,
      height: payload.height,
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

    // Capture the view into raw Flutter ui.Image object
    final ui.Image image = await boundary.toImage();

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