// ignore_for_file: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'api_call_event.dart';
part 'api_call_state.dart';

class ApiCallBloc extends Bloc<ApiCallBlocEvent, ApiCallBlocState> {
  ApiCallBloc() : super(ApiCallBlocInitial()) {
    on<FetchApiWithNoParams>((event, emit) async {
      emit(ApiCallBlocLaoding());
      var data = await event.function();
      emit(ApiCallBlocFinal(data));
    });
    on<FetchApiWithOneParams>((event, emit) async {
      emit(ApiCallBlocLaoding());
      var data = await event.function(
        event.argument,
      );
      emit(ApiCallBlocFinal(data));
    });
    on<FetchApiWithTwoParams>((event, emit) async {
      emit(ApiCallBlocLaoding());
      var data = await event.function(
        event.argument,
        event.argument2,
      );
      emit(ApiCallBlocFinal(data));
    });
    on<FetchApiWithThreeParams>((event, emit) async {
      emit(ApiCallBlocLaoding());
      var data = await event.function(
        event.argument,
        event.argument2,
        event.argument3,
      );
      emit(ApiCallBlocFinal(data));
    });
  }
}
