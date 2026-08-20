import 'package:drawing_app/painter_controller.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> get providersLocal{
  return [
    ChangeNotifierProvider(create: (context) => PainterController()),
    
  ];
}