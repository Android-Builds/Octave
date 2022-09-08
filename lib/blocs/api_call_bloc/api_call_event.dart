part of 'api_call_bloc.dart';

abstract class ApiCallBlocEvent extends Equatable {
  const ApiCallBlocEvent();

  @override
  List<Object> get props => [];
}

class FetchApiWithNoParams extends ApiCallBlocEvent {
  final Function function;

  const FetchApiWithNoParams(this.function);
}

class FetchApiWithOneParams extends ApiCallBlocEvent {
  final Function function;
  final dynamic argument;

  const FetchApiWithOneParams(
    this.function,
    this.argument,
  );
}

class FetchApiWithTwoParams extends ApiCallBlocEvent {
  final Function function;
  final dynamic argument;
  final dynamic argument2;

  const FetchApiWithTwoParams(
    this.function,
    this.argument,
    this.argument2,
  );
}

class FetchApiWithThreeParams extends ApiCallBlocEvent {
  final Function function;
  final dynamic argument;
  final dynamic argument2;
  final dynamic argument3;

  const FetchApiWithThreeParams(
    this.function,
    this.argument,
    this.argument2,
    this.argument3,
  );
}
