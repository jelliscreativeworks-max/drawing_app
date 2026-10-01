
import 'package:drawing_app/data/repositories/canvas_data_repository/canvas_data_repository.dart';
import 'package:drawing_app/data/repositories/canvas_data_repository/canvas_data_repository_local.dart';
import 'package:drawing_app/data/repositories/layer_data_repository/layer_data_repository.dart';
import 'package:drawing_app/data/repositories/layer_data_repository/layer_data_repository_local.dart';
import 'package:drawing_app/data/services/local_data_service.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> get providersLocal {
  return [
     Provider<Logger>(
      create: (_) => Logger(
        filter: DevelopmentFilter(),
        printer: PrettyPrinter(methodCount: 1,colors: false, dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart),
      ),
      dispose: (_, logger) => logger.close(),
    ),

    Provider<LocalDataService>(
      create: (context) => LocalDataService(logger: context.read<Logger>()),
    ),


    Provider<LayerDataRepository>(
      create: (context) => LayerDataRepositoryLocal(
        localDataService: context.read<LocalDataService>(),
        logger: context.read<Logger>()
      ),
    ),

    Provider<CanvasDataRepository>(
      create: (context) => CanvasDataRepositoryLocal(
        localDataService: context.read<LocalDataService>(),
        logger: context.read<Logger>()
      ),
    ),


  ];
}

List<SingleChildWidget> get providersGlobal{
  return [
  ];
}

