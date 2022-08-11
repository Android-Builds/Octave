import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../utils/player_manager.dart';

class PlayerCollapsed extends StatelessWidget {
  const PlayerCollapsed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ValueNotifier<double> pos = ValueNotifier<double>(0);
    double height;
    double width = PlayerManager.size.width * 0.85;
    return StreamBuilder<PlaybackState>(
      stream: PlayerManager.audioHandler.playbackState,
      builder: (context, snapshot) {
        final playbackState = snapshot.data;
        final stopped =
            playbackState?.processingState == AudioProcessingState.idle;
        return SlidingUpPanel(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(5.0),
            topRight: Radius.circular(5.0),
          ),
          onPanelSlide: (position) {
            pos.value = position;
            if (PlayerManager.homePage) {
              PlayerManager.navbarHeight.value =
                  kBottomNavigationBarHeight * (1 - position);
            }
          },
          boxShadow: const [],
          minHeight: !stopped ? kToolbarHeight * 1.5 : 0.0,
          controller: PlayerManager.panelController,
          maxHeight: PlayerManager.size.height,
          panelBuilder: (sc) {
            return StreamBuilder<MediaItem?>(
              stream: PlayerManager.audioHandler.mediaItem,
              builder: (context, snapshot) {
                final processingState = playbackState?.processingState;
                final playing = playbackState?.playing;
                final mediaItem = snapshot.data;
                if (mediaItem == null) {
                  return const SizedBox.shrink();
                }
                return Container(
                  color: Theme.of(context).colorScheme.background,
                  child: ValueListenableBuilder(
                    valueListenable: pos,
                    builder: (context, double value, child) {
                      height = value * (PlayerManager.size.height * 0.5);
                      width = max(60, PlayerManager.size.width * 0.85 * value);
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: kToolbarHeight * value,
                            child: AppBar(
                              centerTitle: true,
                              leading: IconButton(
                                onPressed: () =>
                                    PlayerManager.panelController.close(),
                                icon: const Icon(Icons.keyboard_arrow_down),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Playing From',
                                    style: TextStyle(
                                        fontSize:
                                            PlayerManager.size.width * 0.04),
                                  ),
                                  StreamBuilder<MediaItem?>(
                                    stream:
                                        PlayerManager.audioHandler.mediaItem,
                                    builder: (context, snapshot) {
                                      final mediaItem = snapshot.data;
                                      if (mediaItem == null) {
                                        return const Text("");
                                      }
                                      return Text(
                                        mediaItem.album ?? "",
                                        style: TextStyle(
                                          fontSize:
                                              PlayerManager.size.width * 0.03,
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
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: CachedNetworkImage(
                                  height: max(100, height),
                                  width: max(100, width),
                                  fit: BoxFit.cover,
                                  imageUrl: '${mediaItem.artUri!}',
                                ),
                              ),
                              SizedBox(
                                width: PlayerManager.size.width *
                                    0.7 *
                                    (1 - value),
                                child: Opacity(
                                  opacity: 1 - value,
                                  child: Row(
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            mediaItem.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.clip,
                                          ),
                                          Text(mediaItem.artist!),
                                        ],
                                      ),
                                      (processingState ==
                                                  AudioProcessingState
                                                      .loading ||
                                              processingState ==
                                                  AudioProcessingState
                                                      .buffering)
                                          ? Container(
                                              margin: const EdgeInsets.all(8.0),
                                              child:
                                                  const CircularProgressIndicator(),
                                            )
                                          : (playing != true
                                              ? IconButton(
                                                  icon: const Icon(
                                                      Icons.play_arrow),
                                                  onPressed: PlayerManager
                                                      .audioHandler.play,
                                                )
                                              : IconButton(
                                                  icon: const Icon(Icons.pause),
                                                  onPressed: PlayerManager
                                                      .audioHandler.pause,
                                                )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            );
          },
          // footer: StreamBuilder<MediaItem?>(
          //   stream: PlayerManager.audioHandler.mediaItem,
          //   builder: (context, snapshot) {
          //     final processingState = playbackState?.processingState;
          //     final playing = playbackState?.playing;
          //     final mediaItem = snapshot.data;
          //     if (mediaItem == null) {
          //       return const SizedBox.shrink();
          //     }
          //     return ValueListenableBuilder(
          //       valueListenable: val,
          //       builder: (context, double value, child) => Padding(
          //         padding: EdgeInsets.only(
          //           bottom: bottom,
          //           left: left,
          //         ),
          //         child: ClipRRect(
          //           borderRadius: BorderRadius.circular(10.0),
          //           child: CachedNetworkImage(
          //             height: max(60, value),
          //             width: width,
          //             fit: BoxFit.cover,
          //             imageUrl: '${mediaItem.artUri!}',
          //           ),
          //         ),
          //       ),
          //     );
          //   },
          // ),
          // collapsed: Container(
          //   decoration: BoxDecoration(
          //     color: ElevationOverlay.colorWithOverlay(
          //       Theme.of(context).colorScheme.surface,
          //       Theme.of(context).colorScheme.primary,
          //       3.0,
          //     ),
          //     borderRadius: const BorderRadius.only(
          //       topLeft: Radius.circular(5.0),
          //       topRight: Radius.circular(5.0),
          //     ),
          //   ),
          //   child: StreamBuilder<MediaItem?>(
          //     stream: PlayerManager.audioHandler.mediaItem,
          //     builder: (context, snapshot) {
          //       final processingState = playbackState?.processingState;
          //       final playing = playbackState?.playing;
          //       final mediaItem = snapshot.data;
          //       if (mediaItem == null) {
          //         return const SizedBox.shrink();
          //       }
          //       return Padding(
          //         padding: const EdgeInsets.all(10.0),
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             StreamBuilder<PositionData>(
          //               stream: PlayerManager.positionDataStream,
          //               builder: (context, snapshot) {
          //                 final positionData = snapshot.data ??
          //                     PositionData(
          //                       Duration.zero,
          //                       Duration.zero,
          //                       Duration.zero,
          //                     );
          //                 final double percentage = snapshot.data != null
          //                     ? positionData.position.inSeconds /
          //                         positionData.duration.inSeconds
          //                     : 0;
          //                 return Stack(
          //                   alignment: Alignment.center,
          //                   children: [
          //                     SizedBox(
          //                       height: 60,
          //                       width: 60,
          //                       child: CircularProgressIndicator(
          //                         value: percentage,
          //                         strokeWidth: 2.0,
          //                       ),
          //                     ),
          //                     CircleAvatar(
          //                       radius: 25,
          //                       backgroundImage: CachedNetworkImageProvider(
          //                         '${mediaItem.artUri!}',
          //                       ),
          //                     )
          //                   ],
          //                 );
          //               },
          //             ),
          //             const SizedBox(width: 10.0),
          //             Flexible(
          //               child: Column(
          //                 mainAxisAlignment: MainAxisAlignment.center,
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //                   Text(
          //                     mediaItem.title,
          //                     maxLines: 1,
          //                     overflow: TextOverflow.clip,
          //                   ),
          //                   Text(mediaItem.artist!),
          //                 ],
          //               ),
          //             ),
          //             StreamBuilder<QueueState>(
          //               stream: PlayerManager.audioHandler.queueState,
          //               builder: (context, snapshot) {
          //                 final queueState = snapshot.data ?? QueueState.empty;
          //                 return IconButton(
          //                   icon: const Icon(Icons.skip_previous),
          //                   onPressed: queueState.hasPrevious
          //                       ? PlayerManager.audioHandler.skipToPrevious
          //                       : null,
          //                 );
          //               },
          //             ),
          //             (processingState == AudioProcessingState.loading ||
          //                     processingState == AudioProcessingState.buffering)
          //                 ? Container(
          //                     margin: const EdgeInsets.all(8.0),
          //                     child: const CircularProgressIndicator(),
          //                   )
          //                 : (playing != true
          //                     ? IconButton(
          //                         icon: const Icon(Icons.play_arrow),
          //                         onPressed: PlayerManager.audioHandler.play,
          //                       )
          //                     : IconButton(
          //                         icon: const Icon(Icons.pause),
          //                         onPressed: PlayerManager.audioHandler.pause,
          //                       )),
          //             StreamBuilder<QueueState>(
          //               stream: PlayerManager.audioHandler.queueState,
          //               builder: (context, snapshot) {
          //                 final queueState = snapshot.data ?? QueueState.empty;
          //                 return IconButton(
          //                   icon: const Icon(Icons.skip_next),
          //                   onPressed: queueState.hasNext
          //                       ? PlayerManager.audioHandler.skipToNext
          //                       : null,
          //                 );
          //               },
          //             ),
          //           ],
          //         ),
          //       );
          //     },
          //   ),
          // ),
          // panelBuilder: (ScrollController panelScrollController) {
          //   return Overlay(
          //     initialEntries: [
          //       OverlayEntry(
          //         builder: (context) => Container(
          //           color: Theme.of(context).colorScheme.background,
          //           child: PlayerExpanded(
          //             scrollController: panelScrollController,
          //             panelController: PlayerManager.panelController,
          //           ),
          //         ),
          //       )
          //     ],
          //   );
          // },
        );
      },
    );
  }
}
