import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:maestro_test/core/failures/failure.dart';

typedef CommandAction0<T> = Future<Either<Failure, T>> Function();
typedef CommandAction1<T, A> = Future<Either<Failure, T>> Function(A);
typedef CommandAction2<T, A, B> = Future<Either<Failure, T>> Function(A, B);

abstract class Command<T> extends ChangeNotifier {
  bool _running = false;
  bool get running => _running;

  Either<Failure, T>? _result;

  bool get hasError => _result?.isLeft() ?? false;
  bool get isSuccess => _result?.isRight() ?? false;

  Failure? get failure => _result?.fold((f) => f, (_) => null);
  T? get value => _result?.fold((_) => null, (v) => v);

  void clearResult() {
    _result = null;
    notifyListeners();
  }

  Future<void> _execute(CommandAction0<T> action) async {
    if (_running) return;

    _running = true;
    _result = null;
    notifyListeners();

    try {
      _result = await action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

final class Command0<T> extends Command<T> {
  Command0(this._action);
  final CommandAction0<T> _action;

  Future<void> execute() async => await _execute(_action);
}

final class Command1<T, A> extends Command<T> {
  Command1(this._action);
  final CommandAction1<T, A> _action;

  Future<void> execute(A arg) async => await _execute(() => _action(arg));
}

final class Command2<T, A, B> extends Command<T> {
  Command2(this._action);
  final CommandAction2<T, A, B> _action;

  Future<void> execute(A arg1, B arg2) async {
    await _execute(() => _action(arg1, arg2));
  }
}
