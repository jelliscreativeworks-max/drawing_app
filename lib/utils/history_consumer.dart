import 'package:drawing_app/domain/models/draw_data/draw_data.dart';

abstract class HistoryConsumer {
  void setHistorySnapshot(List<DrawData> drawHistory);
}