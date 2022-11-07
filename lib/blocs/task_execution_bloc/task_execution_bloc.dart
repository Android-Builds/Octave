// ignore_for_file: depend_on_referenced_packages

import 'package:octave/classes/trending_songs.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'task_execution_event.dart';
part 'task_execution_state.dart';

class TaskExecutionBloc extends Bloc<TaskExecutionEvent, TaskExecutionState> {
  TaskExecutionBloc() : super(TaskIsInitializing()) {
    on<LoadSongAndPlaylistTask>((event, emit) async {
      emit(TaskIsExecuting(event.song));
      // Playlist playlist = await PlayerManager.playMusic(
      //     event.song.videoId, event.song.playlistId);
      // emit(TaskIsExecuted());
      // await PlayerManager.doNext(
      //     event.song.videoId, event.song.playlistId, playlist);
    });
    on<SongAndPlaylistLoaded>((event, emit) async {
      emit(TaskIsExecuted());
    });
  }
}
