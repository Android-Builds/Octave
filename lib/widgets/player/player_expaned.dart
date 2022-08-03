import 'package:audio_service/audio_service.dart';
import 'package:beats/widgets/player/player_playlist.dart';
import 'package:beats/widgets/player/poster_widget.dart';
import 'package:flutter/material.dart';
import 'package:beats/widgets/player/control_buttons.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'common.dart';
import '../../utils/player_manager.dart';

class PlayerExpanded extends StatelessWidget {
  final ScrollController scrollController;
  final PanelController panelController;

  const PlayerExpanded(
      {super.key,
      required this.scrollController,
      required this.panelController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          centerTitle: true,
          leading: IconButton(
            onPressed: () => panelController.close(),
            icon: const Icon(Icons.keyboard_arrow_down),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Playing From',
                style: TextStyle(fontSize: PlayerManager.size.width * 0.04),
              ),
              StreamBuilder<MediaItem?>(
                stream: PlayerManager.audioHandler.mediaItem,
                builder: (context, snapshot) {
                  final mediaItem = snapshot.data;
                  if (mediaItem == null) return const Text("");
                  return Text(
                    mediaItem.album ?? "",
                    style: TextStyle(
                      fontSize: PlayerManager.size.width * 0.03,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            )
          ],
        ),
        Flexible(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            controller: scrollController,
            children: [
              SizedBox(
                height: PlayerManager.size.height * 0.72,
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: PosterWidget(),
                ),
              ),
              const SizedBox(height: 20.0),
              const Playlist()
            ],
          ),
        ),
        SizedBox(
          height: PlayerManager.size.height * 0.15,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -22,
                left: 0,
                right: 0,
                child: StreamBuilder<PositionData>(
                  stream: PlayerManager.positionDataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data ??
                        PositionData(
                            Duration.zero, Duration.zero, Duration.zero);
                    return SeekBar(
                      duration: positionData.duration,
                      position: positionData.position,
                      bufferedPosition: positionData.bufferedPosition,
                      onChangeEnd: (newPosition) {
                        PlayerManager.audioHandler.seek(newPosition);
                      },
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: ControlButtons(PlayerManager.audioHandler),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
