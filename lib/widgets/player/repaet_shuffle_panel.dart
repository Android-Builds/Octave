import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import '../../utils/player_manager.dart';

class RepeatShuffelPanel extends StatelessWidget {
  const RepeatShuffelPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        StreamBuilder<AudioServiceRepeatMode>(
          stream: PlayerManager.audioHandler.playbackState
              .map((state) => state.repeatMode)
              .distinct(),
          builder: (context, snapshot) {
            final repeatMode = snapshot.data ?? AudioServiceRepeatMode.none;
            const icons = [
              Icon(Icons.repeat, color: Colors.grey),
              Icon(Icons.repeat, color: Colors.orange),
              Icon(Icons.repeat_one, color: Colors.orange),
            ];
            const cycleModes = [
              AudioServiceRepeatMode.none,
              AudioServiceRepeatMode.all,
              AudioServiceRepeatMode.one,
            ];
            final index = cycleModes.indexOf(repeatMode);
            return IconButton(
              icon: icons[index],
              onPressed: () {
                PlayerManager.audioHandler.setRepeatMode(cycleModes[
                    (cycleModes.indexOf(repeatMode) + 1) % cycleModes.length]);
              },
            );
          },
        ),
        StreamBuilder<bool>(
          stream: PlayerManager.audioHandler.playbackState
              .map((state) => state.shuffleMode == AudioServiceShuffleMode.all)
              .distinct(),
          builder: (context, snapshot) {
            final shuffleModeEnabled = snapshot.data ?? false;
            return IconButton(
              icon: shuffleModeEnabled
                  ? const Icon(Icons.shuffle, color: Colors.orange)
                  : const Icon(Icons.shuffle, color: Colors.grey),
              onPressed: () async {
                final enable = !shuffleModeEnabled;
                await PlayerManager.audioHandler.setShuffleMode(enable
                    ? AudioServiceShuffleMode.all
                    : AudioServiceShuffleMode.none);
              },
            );
          },
        ),
      ],
    );
  }
}
