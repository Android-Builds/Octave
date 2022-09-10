part of 'api_call_bloc.dart';

abstract class ApiCallBlocState extends Equatable {
  const ApiCallBlocState();

  @override
  List<Object> get props => [];
}

class ApiCallBlocInitial extends ApiCallBlocState {}

class ApiCallBlocLaoding extends ApiCallBlocState {}

class ApiCallBlocFinal extends ApiCallBlocState {
  final dynamic data;

  const ApiCallBlocFinal(this.data);

  @override
  List<Object> get props => [data];
}
