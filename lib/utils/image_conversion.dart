import 'dart:async';
import 'dart:typed_data';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

class ImageProcessingPayload {
  final int width;
  final int height;
  final Uint8List rawRgbaBytes;
  final double transparencyFactor;

  ImageProcessingPayload({
    required this.width,
    required this.height,
    required this.rawRgbaBytes,
    required this.transparencyFactor,
  });
}

class CanvasToImageProcessor {
  bool isProcessing = false;

  // Background Isolate function handling the heavy image package logic safely
  static Future<Uint8List> _manipulateAndEncodePng(ImageProcessingPayload payload) async {
    final img.Image image = img.Image.fromBytes(
      width: payload.width,
      height: payload.height,
      bytes: payload.rawRgbaBytes.buffer,
      order: img.ChannelOrder.rgba,
    );

    // Perform pixel-level transparency tweaks safely in the worker isolate pool
    for (final img.Pixel pixel in image) {
      pixel.a = (pixel.a * payload.transparencyFactor).clamp(0, 255);
    }

    return Uint8List.fromList(img.encodePng(image));
  }

  // 🌟 THE PRODUCTION FIX: Render pure vector arrays directly to an offscreen image buffer!
  Future<Uint8List?> generateLayerSnapshotFromVectors({
    required List<DrawData> layerHistory,
    required Map<Type, DrawTool> drawTools,
    double transparency = 1.0,
    double targetWidth = 500.0,
    double targetHeight = 500.0,
  }) async {
    isProcessing = true;

    if (layerHistory.isEmpty) {
      isProcessing = false;
      return Uint8List(0); // Return empty array safely if layer contains no content
    }

    // 1. Initialize an offscreen GPU graphics recorder
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    
    // 2. Instantiate a raw drawing canvas bound directly to the recorder canvas grid
    final ui.Canvas offscreenCanvas = ui.Canvas(
      recorder, 
      Rect.fromLTWH(0, 0, targetWidth, targetHeight),
    );

    // 3. OPTIONAL COORD SCALE NUDGE: Scale down your massive 2000x2000 coordinates 
    // to cleanly fit inside your compact 500x500 thumbnail box preview window frame
    final double scaleX = targetWidth / 2000.0;
    final double scaleY = targetHeight / 2000.0;
    offscreenCanvas.scale(scaleX, scaleY);

    // 4. DRAW THE VECTORS PASSIVELY (Completely free from InteractiveViewer pan/zoom offsets!)
    for (DrawData command in layerHistory) {
      final tool = drawTools.values.singleWhere((tool) => tool.toolName == command.toolName);
        tool.draw(offscreenCanvas, command);
      }


    // 5. Finalize recording and compile directly into an un-compressed raw image buffer matrix
    final ui.Picture picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(targetWidth.toInt(), targetHeight.toInt());

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

    // 6. Offload raw bytes to your Isolate worker block for PNG compression encoding
    final Uint8List processedPng = await compute(_manipulateAndEncodePng, payload);
    
    isProcessing = false;
    return processedPng;
  }
}
