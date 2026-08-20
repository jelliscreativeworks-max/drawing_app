import 'package:drawing_app/domain/models/recordable_action/recorable_controller.dart';

abstract class RecordableAction {
  const RecordableAction();
  
  void undo(RecorableController rController);
  void execute(RecorableController rController);
}