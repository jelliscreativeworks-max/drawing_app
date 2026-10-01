import 'dart:convert';
import 'dart:io';

import 'package:drawing_app/domain/models/canvas_data/canvas_data.dart';
import 'package:drawing_app/domain/models/layer_data/layer_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

const String materialFile = 'material_data.json';
const String historicalFile = 'historical_data.json';

class LocalDataService {
  LocalDataService({required this.logger});
  final Logger logger;

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
  // TODO: Change Projects to Canvases. One project could have more than one canvas and a canvas is not a project
  Future<List<CanvasDataCreated>> loadCanvasDataList() async {
    final List<CanvasDataCreated> loadedData = [];
    final dir = Directory('${await _localPath}/projects');
    
    if (!await dir.exists()) {
      logger.d('No file exists to load data from at ${dir.path} \n Returned data: $loadedData');
      return loadedData;
    }

    await for (final FileSystemEntity projectDir in dir.list()) {
      if (projectDir is Directory) {
        final metaFile = File('${projectDir.path}/project_meta.json');

        if (await metaFile.exists()) {
          try {
            final data = await metaFile.readAsString();
            final json = jsonDecode(data) as Map<String, dynamic>;
            loadedData.add(CanvasDataCreated.fromJson(json));
          } catch (e) {
            logger.e('Failed to parse metadata for ${projectDir.path}: \n Exception: $e');
          }
        } else{
          logger.d('No project meta data found at ${projectDir.path} \n Returned data: $loadedData');
        }
      }
    }

    return loadedData;
  }

  Future<void> deleteCanvas(String canvasId) async {

    final file = File(
      '${await _localPath}/projects/$canvasId/project_meta.json',
    );

    if (await file.exists()) {
      logger.d('Canvas metadata file exists at ${file.path}, deleting now');
      await file.delete();
    } else{
      logger.d('Canvas metadata file does not exist at ${file.path}, nothing deleted');
    }

    final projectDir = Directory('${await _localPath}/projects/$canvasId');
    if (await projectDir.exists() && (await projectDir.list().isEmpty)) {
      logger.d('Project folder found empty at ${projectDir.path}, deleting now');
      await projectDir.delete();
    }
  }

  Future<void> saveCanvasData(CanvasDataCreated data) async {
    final mappedData = data.toJson();
    logger.d('Saving canvas metadeta to file \n json: $mappedData');
    await _writeJsonToFile(mappedData, 'projects/${data.id}/project_meta.json');
  }

  Future<void> deleteAllLayersForProject(String canvasId) async {

    final layersDir = Directory(
      '${await _localPath}/projects/$canvasId/layers',
    );

    if (await layersDir.exists()) {
      logger.d('Layer directory exists at ${layersDir.path}, deleting directory');
      await layersDir.delete(recursive: true);
    } else{

    }
  }

  Future<List<LayerData>> loadDrawLayers(String canvasId) async {
    final List<LayerData> loadedLayers = [];

    final layersDir = Directory(
      '${await _localPath}/projects/$canvasId/layers',
    );

    if (!await layersDir.exists()) {
      logger.d('No layer directory found ${layersDir.path}, returning: $loadedLayers');
      return loadedLayers;
    } else{
      logger.d('Layer directory found at ${layersDir.path}');
    }

    final List<Future<LayerData?>> readTasks = [];
    await for (final FileSystemEntity entity in layersDir.list()) {
      if (entity is File && entity.path.endsWith('.json')) {
        logger.d('Found layer file at ${entity.path}, adding to future list to be loaded together');
        final task = _readLayerFile(entity.path);
        readTasks.add(task);
      }
    }

    final List<LayerData?> results = await Future.wait(readTasks);
    
    for (var layer in results) {
      if (layer != null) {
        logger.d('Added layer with id of ${layer.id} to loaded layers list');
        loadedLayers.add(layer);
      } else{
        logger.d('Loaded layer file is equal to null, skipping: $layer');
      }
    }

    logger.d('Returning loadedLayers list with length of: ${loadedLayers.length}');
    return loadedLayers;
  }

  Future<LayerData?> _readLayerFile(String absolutePath) async {
    try {
      File file = File(absolutePath);
      if (!await file.exists()) {
        logger.d('No layer data found at $absolutePath, returning null');
        return null;
      }
      final data = await file.readAsString();
      final json = jsonDecode(data) as Map<String, dynamic>;
      logger.d('Loaded LayerData json from $absolutePath');
      return LayerData.fromJson(json).copyWith(isDirty: false);
    } catch (e) {
      logger.e('Failed to parse layer file at $absolutePath: $e');
      return null;
    }
  }

  Future<void> saveDrawLayers(List<LayerData> data) async {
    List<Future<void>> futures = [];
    
    for (int i = 0; i < data.length; i++) {
      final mappedData = data[i].toJson();

      final future = _writeJsonToFile(
        mappedData,
        'projects/${data[i].canvasId}/layers/${data[i].id}.json',
      );
      futures.add(future);
    }

    logger.d('Added ${futures.length} json converted layer data/s to future list to be awaited in Future.wait');

    await Future.wait(futures);
    logger.d('Finished saving layers to disk');
  }

  Future<void> deleteDrawLayer(LayerData layer) async {
    final path = 'projects/${layer.canvasId}/layers/${layer.id}.json';
    final file = await _getlocalFile(path); 

    if (await file.exists()) {
      await file.delete();
      logger.d('Deleted layer file successfully from disk at: $path');
    } else {
      logger.w('Forced removal pass skipped: No file found matching coordinates: $path');
    }
  }
}
