
import 'package:drawing_app/config/input_changed_notifier.dart';
import 'package:drawing_app/data/repositories/canvas_data_repository/canvas_data_repository.dart';
import 'package:drawing_app/data/repositories/canvas_data_repository/canvas_data_repository_local.dart';
import 'package:drawing_app/data/repositories/layer_data_repository/layer_data_repository.dart';
import 'package:drawing_app/data/repositories/layer_data_repository/layer_data_repository_local.dart';
import 'package:drawing_app/data/services/local_data_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> get providersLocal {
  return [
    Provider<LocalDataService>(
      create: (_) => LocalDataService(),
    ),

    Provider<LayerDataRepository>(
      create: (context) => LayerDataRepositoryLocal(
        localDataService: context.read<LocalDataService>(),
      ),
    ),

    Provider<CanvasDataRepository>(
      create: (context) => CanvasDataRepositoryLocal(
        localDataService: context.read<LocalDataService>(),
      ),
    ),


  ];
}

List<SingleChildWidget> get providersGlobal{
  return [
    ChangeNotifierProvider(
      create: (_) => InputChangedNotifier()
      ),
  ];
}

