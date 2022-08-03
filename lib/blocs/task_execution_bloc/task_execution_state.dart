part of 'task_execution_bloc.dart';

abstract class TaskExecutionState extends Equatable {
  const TaskExecutionState();

  @override
  List<Object> get props => [];
}

class TaskIsInitializing extends TaskExecutionState {}

class TaskIsExecuting extends TaskExecutionState {
  final TrendingSong song;

  const TaskIsExecuting(this.song);
}

class TaskIsExecuted extends TaskExecutionState {}

class TaskExecutionError extends TaskExecutionState {}
