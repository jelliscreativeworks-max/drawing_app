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
    // _log.info('Getting local file: $fileNameWithExt');
    return File('$path/$relPathWithNameAndExt');
  }

  Future<void> _writeJsonToFile(
    Map<String, dynamic> data,
    String relPathWithNameAndExt,
  ) async {
    final file = await _getlocalFile(relPathWithNameAndExt);

    // 1. Ensure the parent directory exists before writing
    // (create() does nothing if the folder already exists)
    await file.parent.create(recursive: true);

    // 2. Encode and write the data safely
    String json = jsonEncode(data);
    await file.writeAsString(json);
  }

  Future<List<CanvasData>> loadCanvasDataList() async {
    final List<CanvasData> loadedData = [];
    final dir = Directory('${await _localPath}\\projects');

    if (!await dir.exists()) return loadedData;

    // 1. List only the top-level project folders
    await for (final FileSystemEntity projectDir in dir.list()) {
      if (projectDir is Directory) {
        // 2. Point directly to the explicit metadata file path
        final metaFile = File('${projectDir.path}\\project_meta.json');

        // 3. Only read if the metadata file actually exists
        if (await metaFile.exists()) {
          try {
                final data = await metaFile.readAsString();
              final json = jsonDecode(data) as Map<String, dynamic>;
            loadedData.add(CanvasData.fromJson(json));
          } catch (e) {
            // Prevent one corrupted file from breaking the entire app load
            print('Failed to parse metadata for ${projectDir.path}: $e');
          }
        }
      }
    }

    // Optional: Sort by newest project firstz
    return loadedData;
  }

  Future<void> deleteCanvas(String canvasId) async {
    final file = File(
      '${await _localPath}\\projects\\$canvasId\\project_meta.json',
    );

    if (await file.exists()) {
      await file.delete();
    }

    final projectDir = Directory('${await _localPath}\\projects\\$canvasId');
    if (await projectDir.exists() && (await projectDir.list().isEmpty)) {
      await projectDir.delete();
    }
  }

  Future<void> saveCanvasData(CanvasData data) async {
    final mappedData = data.toJson();

    await _writeJsonToFile(mappedData, 'projects\\${data.id}\\project_meta.json');
  }


  Future<void> deleteAllLayersForProject(String canvasId) async {
    final layersDir = Directory(
      '${await _localPath}\\projects\\$canvasId\\layers',
    );

    if (await layersDir.exists()) {
      // recursive: true deletes the folder and all containing files at once
      await layersDir.delete(recursive: true);
    }
  }

  Future<List<LayerData>> loadDrawLayers(String canvasId) async {
    final List<LayerData> loadedLayers = [];
    final layersDir = Directory(
      '${await _localPath}\\projects\\$canvasId\\layers',
    );

    // 1. If the folder doesn't exist (e.g., brand new project), return empty list
    if (!await layersDir.exists()) return loadedLayers;

    final List<Future<LayerData?>> readTasks = [];

    // 2. Scan the layers directory
    await for (final FileSystemEntity entity in layersDir.list()) {
      if (entity is File && entity.path.endsWith('.json')) {
        // 3. Queue up the file reading task without awaiting it yet
        final task = _readLayerFile(entity.path);
        readTasks.add(task);
      }
    }

    // 4. Read all layer files from disk simultaneously
    final List<LayerData?> results = await Future.wait(readTasks);
    
    // 5. Filter out any corrupted null results and add to our list
    for (var layer in results) {
      if (layer != null) {
        loadedLayers.add(layer);
      }
    }

    return loadedLayers;
  }

  // Helper method to safely read and parse a single layer file
  Future<LayerData?> _readLayerFile(String absolutePath) async {
    try {
        File file = File(absolutePath);
          if (!await file.exists()) {
      return null;
    }
    final data = await file.readAsString();
    final json = jsonDecode(data) as Map<String, dynamic>;
      return LayerData.fromJson(
        json,
      ).copyWith(isDirty: false); // Loaded layers are clean!
    } catch (e) {
      print('Failed to parse layer file at $absolutePath: $e');
      return null; // Return null to prevent one bad layer from crashing the app load
    }
  }

  Future<void> saveDrawLayers(List<LayerData> data) async {
    List<Future<void>> futures = [];

    for (int i = 0; i < data.length; i++) {
      final mappedData = data[i].toJson();

      final future = _writeJsonToFile(
        mappedData,
        'projects\\${data[i].canvasId}\\layers\\${data[i].id}.json',
      );
      futures.add(future);
    }

    await Future.wait(futures);
  }

  Future<void> deleteDrawLayer(LayerData layer) async {
        final path = 'projects\\${layer.canvasId}\\layers\\${layer.id}.json';
        final file = await _getlocalFile(path); 

        if(await file.exists()){
          await file.delete();
        }
  }


  //   Future<List<Map<String, dynamic>>> _loadJsonListFromFile(String relPathWithNameAndExt) async {
  //   final file = await _getlocalFile(relPathWithNameAndExt);
  //   if(await file.exists() == false){
  //     return [];
  //   }
  //   final data = await file.readAsString();
  //   return(jsonDecode(data) as List).cast<Map<String,dynamic>>();
  // }

  // Future<void> saveMaterialDataList(List<MaterialData> data) async {
  //   final dataMap = data.map((material) => material.toJson()).toList();
  //   await _writeJsonToFile(dataMap, materialFile);
  // }

  // Future<void> saveHistoricalDataList(List<HistoricalData> data) async {
  //   final dataMap = data.map((historical) => historical.toJson()).toList();
  //   await _writeJsonToFile(dataMap, historicalFile);
  // }

  // Future<List<Map<String, dynamic>>> _loadJsonFromFile(String fileNameWithExt) async {
  //   final file = await _getlocalFile(fileNameWithExt);
  //   if(await file.exists() == false){
  //     _log.info('File does not exist, returning empty list: $fileNameWithExt');
  //     return [];
  //   }
  //   final data = await file.readAsString();
  //   _log.info('Data loaded from file: $fileNameWithExt');
  //   return(jsonDecode(data) as List).cast<Map<String,dynamic>>();
  // }

  // Future<List<MaterialData>> loadMaterialDataList() async {
  //   final json = await _loadJsonFromFile(materialFile);
  //   return json.map<MaterialData>(MaterialData.fromJson).toList();
  // }

  //   Future<List<HistoricalData>> loadHistoricalDataList() async {
  //   final json = await _loadJsonFromFile(historicalFile);
  //   return json.map<HistoricalData>(HistoricalData.fromJson).toList();
  // }

  // Future<List<MaterialData>> getMaterialDataList() async {
  //   final json = await _loadStringAsset(Assets.materialData);
  //   return json.map<MaterialData>(MaterialData.fromJson).toList();
  // }

  //   Future<List<Map<String, dynamic>>> _loadStringAsset(String asset) async {
  //   final localData = await rootBundle.loadString(asset);
  //   return (jsonDecode(localData) as List).cast<Map<String, dynamic>>();
  // }

  // Future<List<Map<String, dynamic>>> _saveStringAsset(List<Map<String, dynamic>> asset) async {
  //   final json = jsonEncode(asset);
  //   rootBundle.
  // }
}
