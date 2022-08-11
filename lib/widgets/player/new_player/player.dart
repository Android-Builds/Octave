// ignore_for_file: depend_on_referenced_packages

import 'package:audio_service/audio_service.dart';
import 'package:beats/widgets/player/new_player/collapsed_player.dart';
import 'package:beats/widgets/player/new_player/expaned_player.dart';
import 'package:flutter/material.dart';
import 'package:miniplayer/miniplayer.dart';
import '../common.dart';
import '../../../utils/constants.dart';
import '../../../utils/player_manager.dart';

class Player extends StatefulWidget {
  const Player({Key? key}) : super(key: key);

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: PlayerManager.multiStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData &&
            snapshot.data[0] != null &&
            snapshot.data[1] != null) {
          final PlaybackState playbackState = snapshot.data[0];
          final MediaItem mediaItem = snapshot.data[1];
          final PositionData positionData = snapshot.data[2];
          return Miniplayer(
            controller: PlayerManager.miniplayerController,
            backgroundColor: Theme.of(context).colorScheme.background,
            valueNotifier: PlayerManager.playerExpandProgress,
            minHeight: Constants.minHeight,
            maxHeight: Constants.maxHeight,
            onDismiss: () {
              PlayerManager.audioHandler.stop();
            },
            builder: (height, percentage) {
              final bool miniplayer = percentage < 0.2;
              if (!miniplayer) {
                return ExpandedPlayer(
                  height: height,
                  mediaItem: mediaItem,
                  positionData: positionData,
                );
              } else {
                return CollapsedPlayer(
                  height: height,
                  mediaItem: mediaItem,
                  positionData: positionData,
                  playbackState: playbackState,
                );
              }
            },
          );
        } else {
          return Container();
        }
      },
    );
  }
}
