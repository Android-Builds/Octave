import 'package:audio_service/audio_service.dart';
import 'package:beats/utils/player_manager.dart';
import 'package:flutter/material.dart';

class MiniPlayerBottomPadder extends StatelessWidget {
  const MiniPlayerBottomPadder({
    super.key,
    this.height = kBottomNavigationBarHeight,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlaybackState>(
      stream: PlayerManager.audioHandler.playbackState,
      builder: (context, snapshot) {
        final playbackState = snapshot.data;
        final stopped =
            playbackState?.processingState == AudioProcessingState.idle;
        return SizedBox(
          height: stopped ? 0 : height,
        );
      },
    );
  }
}
