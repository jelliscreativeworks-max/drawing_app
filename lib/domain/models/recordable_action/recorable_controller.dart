import 'package:drawing_app/domain/models/recordable_action/recordable_action.dart';
import 'package:flutter/material.dart';

class RecorableController extends ChangeNotifier {
  List<RecordableAction> recordedActions = [];
  List<RecordableAction> redoableActions = [];

  void record(RecordableAction action){
    action.execute(this);
    recordedActions.add(action);
    redoableActions.clear();
    notifyListeners();
  }

  void undo(RecorableController action){
    if(recordedActions.isEmpty) return;

    final lastAction = recordedActions.removeLast();
    lastAction.undo(this);
    redoableActions.add(lastAction);
    notifyListeners();

  }

  void redo(RecordableAction action){
    if (redoableActions.isEmpty) return;

    final lastAction = redoableActions.removeLast();
    lastAction.execute(this);
    recordedActions.add(lastAction);
    notifyListeners();
  }
}