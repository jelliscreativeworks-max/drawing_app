import 'dart:convert';
import 'dart:io';

import 'package:drawing_app/domain/models/canvas_data/canvas_data.dart';
import 'package:drawing_app/domain/models/layer_data/layer_data.dart';
import 'package:path_provider/path_provider.dart';

const String materialFile = 'material_data.json';
const String historicalFile = 'historical_data.json';

class LocalDataService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _getlocalFile(String relPathWithNameAndExt) async {
    final path = await _localPath;
    return File('$path/$relPathWithNameAndExt');
  }

  Future<void> _writeJsonToFile(
    Map<String, dynamic> data,
    String relPathWithNameAndExt,
  ) async {
    final file = await _getlocalFile(relPathWithNameAndExt);

    // Ensure the parent directory exists before writing
    await file.parent.create(recursive: true);

    String json = jsonEncode(data);
    await file.writeAsString(json);
  }

  Future<List<CanvasData>> loadCanvasDataList() async {
    final List<CanvasData> loadedData = [];
    // 🟢 FIXED: Swapped backslashes for forward slashes
    final dir = Directory('${await _localPath}/projects');

    if (!await dir.exists()) return loadedData;

    await for (final FileSystemEntity projectDir in dir.list()) {
      if (projectDir is Directory) {
        // 🟢 FIXED: Standardized metadata lookup path trajectory strings
        final metaFile = File('${projectDir.path}/project_meta.json');

        if (await metaFile.exists()) {
          try {
            final data = await metaFile.readAsString();
            final json = jsonDecode(data) as Map<String, dynamic>;
            loadedData.add(CanvasData.fromJson(json));
          } catch (e) {
            print('Failed to parse metadata for ${projectDir.path}: $e');
          }
        }
      }
    }

    return loadedData;
  }

  Future<void> deleteCanvas(String canvasId) async {
    // 🟢 FIXED: Standardized path strings
    final file = File(
      '${await _localPath}/projects/$canvasId/project_meta.json',
    );

    if (await file.exists()) {
      await file.delete();
    }

    final projectDir = Directory('${await _localPath}/projects/$canvasId');
    if (await projectDir.exists() && (await projectDir.list().isEmpty)) {
      await projectDir.delete();
    }
  }

  Future<void> saveCanvasData(CanvasData data) async {
    final mappedData = data.toJson();
    // 🟢 FIXED: Standardized backslashes out of your project manifests writer paths
    await _writeJsonToFile(mappedData, 'projects/${data.id}/project_meta.json');
  }

  Future<void> deleteAllLayersForProject(String canvasId) async {
    // 🟢 FIXED: Standardized layout directory paths
    final layersDir = Directory(
      '${await _localPath}/projects/$canvasId/layers',
    );

    if (await layersDir.exists()) {
      await layersDir.delete(recursive: true);
    }
  }

  Future<List<LayerData>> loadDrawLayers(String canvasId) async {
    final List<LayerData> loadedLayers = [];
    // 🟢 FIXED: Standardized layout directory paths
    final layersDir = Directory(
      '${await _localPath}/projects/$canvasId/layers',
    );

    if (!await layersDir.exists()) return loadedLayers;

    final List<Future<LayerData?>> readTasks = [];

    await for (final FileSystemEntity entity in layersDir.list()) {
      if (entity is File && entity.path.endsWith('.json')) {
        final task = _readLayerFile(entity.path);
        readTasks.add(task);
      }
    }

    final List<LayerData?> results = await Future.wait(readTasks);
    
    for (var layer in results) {
      if (layer != null) {
        loadedLayers.add(layer);
      }
    }

    return loadedLayers;
  }

  Future<LayerData?> _readLayerFile(String absolutePath) async {
    try {
      File file = File(absolutePath);
      if (!await file.exists()) {
        return null;
      }
      final data = await file.readAsString();
      final json = jsonDecode(data) as Map<String, dynamic>;
      return LayerData.fromJson(json).copyWith(isDirty: false);
    } catch (e) {
      print('Failed to parse layer file at $absolutePath: $e');
      return null;
    }
  }

  Future<void> saveDrawLayers(List<LayerData> data) async {
    List<Future<void>> futures = [];

    for (int i = 0; i < data.length; i++) {
      final mappedData = data[i].toJson();

      // 🟢 FIXED: Swapped Windows backslashes for cross-platform forward slashes!
      final future = _writeJsonToFile(
        mappedData,
        'projects/${data[i].canvasId}/layers/${data[i].id}.json',
      );
      futures.add(future);
    }

    await Future.wait(futures);
  }

  Future<void> deleteDrawLayer(LayerData layer) async {
    // 🟢 FIXED: Clean trajectory path. Now matches exactly on all testing devices!
    final path = 'projects/${layer.canvasId}/layers/${layer.id}.json';
    final file = await _getlocalFile(path); 

    if (await file.exists()) {
      await file.delete();
      print('Scrubbed layer file successfully from disk: $path');
    } else {
      print('Forced removal pass skipped: No file found matching coordinates: $path');
    }
  }
}
