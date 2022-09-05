import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:beats/widgets/player/common.dart';
import 'package:beats/widgets/marquee_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../../utils/player_manager.dart';

class CollapsedPlayer extends StatelessWidget {
  const CollapsedPlayer({
    Key? key,
    required this.height,
    required this.mediaItem,
    required this.positionData,
    required this.playbackState,
  }) : super(key: key);

  final double height;
  final MediaItem mediaItem;
  final PositionData positionData;
  final PlaybackState playbackState;

  @override
  Widget build(BuildContext context) {
    final percentageMiniplayer = PlayerManager.percentageFromValueInRange(
      min: minHeight,
      max: maxHeight * 0.2 + minHeight,
      value: height,
    );

    final elementOpacity =
        (1 - 1 * percentageMiniplayer).clamp(0, 1).toDouble();
    final progressIndicatorHeight = 4 - 4 * percentageMiniplayer;

    final processingState = playbackState.processingState;
    final playing = playbackState.playing;
    final double percentPlayed =
        positionData.position.inSeconds / positionData.duration.inSeconds;

    return Container(
      color: ElevationOverlay.colorWithOverlay(
        Theme.of(context).colorScheme.surface,
        Theme.of(context).colorScheme.primary,
        3.0,
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 5.0,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: maxImgSize,
                      maxWidth: maxImgSize,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: CachedNetworkImage(
                        height: height,
                        width: height,
                        fit: BoxFit.cover,
                        imageUrl: mediaItem.artUri.toString(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Opacity(
                      opacity: elementOpacity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MarqueeWidget(
                            child: Text(
                              mediaItem.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(fontSize: 16),
                            ),
                          ),
                          MarqueeWidget(
                            child: Text(
                              mediaItem.artist ?? mediaItem.album ?? "",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText2!
                                        .color!
                                        .withOpacity(0.55),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Opacity(
                    opacity: elementOpacity,
                    child: (processingState == AudioProcessingState.loading ||
                            processingState == AudioProcessingState.buffering)
                        ? Container(
                            margin: const EdgeInsets.all(8.0),
                            child: const CircularProgressIndicator(),
                          )
                        : (playing != true
                            ? IconButton(
                                icon: const Icon(Icons.play_arrow),
                                onPressed: PlayerManager.audioHandler.play,
                              )
                            : IconButton(
                                icon: const Icon(Icons.pause),
                                onPressed: PlayerManager.audioHandler.pause,
                              )),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: max(0, progressIndicatorHeight),
            child: Opacity(
              opacity: elementOpacity,
              child: LinearProgressIndicator(
                value: percentPlayed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
