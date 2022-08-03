import 'package:audio_service/audio_service.dart';
import 'package:beats/api/youtube_api.dart';
import 'package:beats/widgets/marquee_widget.dart';
import 'package:beats/widgets/player/player_playlist.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:miniplayer/miniplayer.dart';

import '../common.dart';
import '../../../utils/constants.dart';
import '../../../utils/player_manager.dart';
import '../control_buttons.dart';

class ExpandedPlayer extends StatelessWidget {
  const ExpandedPlayer({
    Key? key,
    required this.height,
    required this.mediaItem,
    required this.positionData,
  }) : super(key: key);

  final double height;
  final MediaItem mediaItem;
  final PositionData positionData;

  @override
  Widget build(BuildContext context) {
    var percentageExpandedPlayer = PlayerManager.percentageFromValueInRange(
      min: Constants.maxHeight * 0.2 + Constants.minHeight,
      max: Constants.maxHeight,
      value: height,
    );

    var opacity = PlayerManager.percentageFromValueInRange(
      min: Constants.maxHeight * 0.5 + Constants.minHeight,
      max: Constants.maxHeight,
      value: height,
    );

    if (percentageExpandedPlayer < 0) percentageExpandedPlayer = 0;
    if (opacity < 0) opacity = 0;

    final paddingVertical = PlayerManager.valueFromPercentageInRange(
      min: 0,
      max: 10,
      percentage: percentageExpandedPlayer,
    );
    final double heightWithoutPadding = height - paddingVertical * 2;
    final double imageSize = heightWithoutPadding > Constants.maxImgSize
        ? Constants.maxImgSize
        : heightWithoutPadding;
    final paddingLeft = PlayerManager.valueFromPercentageInRange(
          min: 0,
          max: PlayerManager.size.width - imageSize,
          percentage: percentageExpandedPlayer,
        ) /
        2;

    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: SizedBox(
              height: kToolbarHeight * 1.5,
              child: AppBar(
                centerTitle: true,
                leading: IconButton(
                  onPressed: () =>
                      PlayerManager.miniplayerController.animateToHeight(
                    state: PanelState.MIN,
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Playing From',
                      style:
                          TextStyle(fontSize: PlayerManager.size.width * 0.04),
                    ),
                    Text(
                      mediaItem.album!.isNotEmpty
                          ? mediaItem.album
                          : mediaItem.extras!['playlist'] ?? "",
                      style: TextStyle(
                        fontSize: PlayerManager.size.width * 0.03,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
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
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: paddingLeft,
                top: paddingVertical,
                bottom: paddingVertical,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: CachedNetworkImage(
                  height: imageSize,
                  width: imageSize,
                  fit: BoxFit.cover,
                  imageUrl: mediaItem.artUri.toString(),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Opacity(
                opacity: opacity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(child: SizedBox(height: 20)),
                    Flexible(
                      child: MarqueeWidget(
                        child: Text(
                          mediaItem.title,
                          style: TextStyle(
                            fontSize: PlayerManager.size.width * 0.06,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        mediaItem.artist ?? mediaItem.album ?? "",
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(
                              fontSize: PlayerManager.size.width * 0.04,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .color!
                                  .withOpacity(0.55),
                            ),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Opacity(
                        opacity: opacity,
                        child: SeekBar(
                          duration: positionData.duration,
                          position: positionData.position,
                          bufferedPosition: positionData.bufferedPosition,
                          onChangeEnd: (newPosition) {
                            PlayerManager.audioHandler.seek(newPosition);
                          },
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Opacity(
                        opacity: opacity,
                        child: ControlButtons(
                          PlayerManager.audioHandler,
                        ),
                      ),
                    ),
                    const Flexible(child: SizedBox(height: 20)),
                    Flexible(
                      flex: 2,
                      child: Opacity(
                        opacity: opacity,
                        child: SizedBox(
                          height: PlayerManager.size.height * 0.2,
                          width: PlayerManager.size.width * 0.3,
                          child: Card(
                            elevation: 4.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () => showPlayList(context),
                                  color: Colors.grey,
                                  icon: const Icon(Icons.playlist_play),
                                ),
                                IconButton(
                                  onPressed: () => showLyrics(context),
                                  color: Colors.grey,
                                  icon: const Icon(Icons.lyrics),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Flexible(
                      child: SizedBox(height: 20),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showPlayList(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: PlayerManager.size.height,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              const Playlist(),
              Positioned(
                top: -PlayerManager.size.height * 0.08,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(
                      10.0,
                    ),
                    child: Text(
                      'Current Playlist',
                      style: TextStyle(
                        fontSize: PlayerManager.size.width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showLyrics(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      constraints: BoxConstraints.loose(
        Size(
          PlayerManager.size.width,
          PlayerManager.size.height * 0.75,
        ),
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      builder: (BuildContext context) {
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            FutureBuilder(
              future: YoutubeMusicApi.getLyrics(
                mediaItem.extras!['playlistId'],
                mediaItem.id,
              ),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  final String lyrics = snapshot.data;
                  if (lyrics.isEmpty) {
                    return SizedBox(
                      height: PlayerManager.size.height * 0.6,
                      child: const Text('No lyrics Available'),
                    );
                  } else {
                    return ListView(
                      padding: const EdgeInsets.all(10.0),
                      children: [
                        Text(
                          snapshot.data,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        )
                      ],
                    );
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
            Positioned(
              top: -PlayerManager.size.height * 0.08,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(
                    10.0,
                  ),
                  child: Text(
                    'Lyrics',
                    style: TextStyle(
                      fontSize: PlayerManager.size.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
