import 'package:flutter/material.dart';

import 'result.dart';


typedef CommandAction0<T> = Future<Result<T>> Function();
typedef CommandAction1<T, A> = Future<Result<T>> Function(A);
typedef CommandAction2<T, A, B> = Future<Result<T>> Function(A, B);
typedef CommandAction3<T, A, B, C> = Future<Result<T>> Function(A, B, C);
typedef CommandAction4<T, A, B, C, D> = Future<Result<T>> Function(A, B, C, D);
typedef CommandAction5<T, A, B, C, D, E> = Future<Result<T>> Function(A, B, C, D, E);
typedef CommandAction6<T, A, B, C, D, E, F> = Future<Result<T>> Function(A, B, C, D, E, F);

abstract class Command<T> extends ChangeNotifier{
  Command();

  bool _running = false;

  bool get running => _running;

  Result<T>? _result;

  bool get error => _result is Error;

  bool get completed => _result is Ok;

  Result? get result => _result;

  void clearResult(){
    _result = null;
    notifyListeners();
  }


  Future<void> _execute(CommandAction0<T> action) async{
    if(_running) return;

    _running = true;
    _result = null;
    notifyListeners();

    try{
      _result = await action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}
class Command0<T> extends Command<T>{
  Command0(this._action);

  final CommandAction0<T> _action;

  Future<void> execute() async{
    await _execute(_action);
  }
}

class Command1<T, A> extends Command<T>{
  Command1(this._action);

  final CommandAction1<T, A> _action;

  Future<void> execute(A argument) async{
    await _execute(() => _action(argument));
  }
}

class Command2<T, A, B> extends Command<T>{
  Command2(this._action);

  final CommandAction2<T, A, B> _action;

  Future<void> execute(A argumentA, B argumentB) async{
    await _execute(() => _action(argumentA, argumentB));
  }
}

class Command3<T, A, B, C> extends Command<T>{
  Command3(this._action);

  final CommandAction3<T, A, B, C> _action;

  Future<void> execute(A argumentA, B argumentB, C argumentC) async{
    await _execute(() => _action(argumentA, argumentB, argumentC));
  }
}

class Command4<T, A, B, C, D> extends Command<T>{
  Command4(this._action);

  final CommandAction4<T, A, B, C, D> _action;

  Future<void> execute(A argumentA, B argumentB, C argumentC, D argumentD) async{
    await _execute(() => _action(argumentA, argumentB, argumentC, argumentD));
  }
}

class Command5<T, A, B, C, D, E> extends Command<T>{
  Command5(this._action);

  final CommandAction5<T, A, B, C, D, E> _action;

  Future<void> execute(A argumentA, B argumentB, C argumentC, D argumentD, E argumentE) async{
    await _execute(() => _action(argumentA, argumentB, argumentC, argumentD, argumentE));
  }
}

class Command6<T, A, B, C, D, E, F> extends Command<T>{
  Command6(this._action);

  final CommandAction6<T, A, B, C, D, E, F> _action;

  Future<void> execute(A argumentA, B argumentB, C argumentC, D argumentD, E argumentE, F argumentF) async{
    await _execute(() => _action(argumentA, argumentB, argumentC, argumentD, argumentE, argumentF));
  }
}