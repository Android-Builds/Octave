// ignore_for_file: depend_on_referenced_packages

import 'package:beats/api/youtube_api.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    on<GetSearchResults>((event, emit) async {
      emit(SearchLoading());
      List searchResults =
          await YoutubeMusicApi.getSearchResults(event.query, event.searchType);
      emit(SearchLoaded(searchResults, individual: event.searchType == null));
    });
  }
}
