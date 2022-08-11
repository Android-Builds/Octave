import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/task_execution_bloc/task_execution_bloc.dart';
import '../utils/player_manager.dart';
import 'player/player_collapsed.dart';

class AppDefinitions extends StatelessWidget {
  final Widget? child;
  const AppDefinitions({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          child!,
          ValueListenableBuilder(
            valueListenable: PlayerManager.navbarHeight,
            builder: (context, double value, child) {
              return Positioned(
                left: 0,
                right: 0,
                bottom: value,
                child: const PlayerCollapsed(),
                // child: BlocBuilder<TaskExecutionBloc, TaskExecutionState>(
                //   builder: (context, state) {
                //     if (state is TaskIsExecuting) {
                //       return Container(
                //         height: kBottomNavigationBarHeight * 1.5,
                //         color: Theme.of(context).colorScheme.background,
                //         child: Row(
                //           children: [Text(state.song.title)],
                //         ),
                //       );
                //     }
                //     return const PlayerCollapsed();
                //   },
                // ),
              );
            },
          ),
        ],
      ),
    );
  }
}
