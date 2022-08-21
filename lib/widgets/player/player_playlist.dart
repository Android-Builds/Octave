import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../services/audio_service.dart';
import '../../utils/player_manager.dart';

class Playlist extends StatelessWidget {
  const Playlist({
    Key? key,
    required this.scrollController,
    required this.panelController,
  }) : super(key: key);

  final ScrollController scrollController;
  final PanelController panelController;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QueueState>(
      stream: PlayerManager.audioHandler.queueState,
      builder: (context, snapshot) {
        final queueState = snapshot.data ?? QueueState.empty;
        final queue = queueState.queue;
        return ReorderableListView(
          scrollController: scrollController,
          shrinkWrap: true,
          onReorder: (int oldIndex, int newIndex) {
            if (oldIndex < newIndex) newIndex--;
            PlayerManager.audioHandler.moveQueueItem(oldIndex, newIndex);
          },
          children: [
            for (var i = 0; i < queue.length; i++)
              Dismissible(
                direction: DismissDirection.endToStart,
                key: ValueKey(queue[i].id),
                background: Container(
                  alignment: Alignment.centerRight,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.delete),
                  ),
                ),
                onDismissed: (dismissDirection) {
                  PlayerManager.audioHandler.removeQueueItemAt(i);
                },
                child: Material(
                  color: i == queueState.queueIndex
                      ? Theme.of(context).colorScheme.background
                      : Colors.transparent,
                  child: ListTile(
                    leading: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: CachedNetworkImage(
                            imageUrl: queue[i].artUri.toString(),
                            height: 55.0,
                            width: 55.0,
                          ),
                        ),
                        i == queueState.queueIndex
                            ? PlayerManager
                                    .audioHandler.playbackState.value.playing
                                ? const Icon(Ionicons.pause)
                                : const Icon(Ionicons.play)
                            : const SizedBox.shrink(),
                      ],
                    ),
                    title: Text(
                      queue[i].title,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Row(
                      children: [
                        Flexible(
                          child: Text(
                            queue[i].artist!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                            ' \u2022 ${PlayerManager.parsedDuration(queue[i].duration!)}'),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert),
                    ),
                    onTap: () {
                      if (i == queueState.queueIndex) {
                        if (PlayerManager
                            .audioHandler.playbackState.valueOrNull!.playing) {
                          PlayerManager.audioHandler.pause();
                        } else {
                          PlayerManager.audioHandler.play();
                        }
                      } else {
                        PlayerManager.audioHandler.skipToQueueItem(i);
                        if (!PlayerManager
                            .audioHandler.playbackState.valueOrNull!.playing) {
                          PlayerManager.audioHandler.play();
                        }
                        panelController.close();
                      }
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  String getArtistText(String name) {
    if (name.length > 40) {
      List<String> splitList = name.split(',');
      return splitList
          .sublist(splitList.length > 3 ? 2 : splitList.length)
          .join(', ')
          .trim();
    }
    return name;
  }
}
