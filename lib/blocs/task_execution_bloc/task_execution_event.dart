part of 'task_execution_bloc.dart';

abstract class TaskExecutionEvent extends Equatable {
  const TaskExecutionEvent();

  @override
  List<Object> get props => [];
}

class LoadSongAndPlaylistTask extends TaskExecutionEvent {
  final TrendingSong song;

  const LoadSongAndPlaylistTask(this.song);
}

class SongAndPlaylistLoaded extends TaskExecutionEvent {}
