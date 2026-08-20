import 'package:drawing_app/domain/models/draw_command/draw_command.dart';
import 'package:drawing_app/painter_controller.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> get providersLocal{
  return [
    ChangeNotifierProvider(create: (context) => PainterController(drawCommandHistory: <DrawCommand>[])),
    
  ];
}