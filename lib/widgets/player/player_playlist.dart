import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../services/audio_service.dart';
import '../../utils/player_manager.dart';

class Playlist extends StatelessWidget {
  const Playlist({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QueueState>(
      stream: PlayerManager.audioHandler.queueState,
      builder: (context, snapshot) {
        final queueState = snapshot.data ?? QueueState.empty;
        final queue = queueState.queue;
        return ReorderableListView(
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
                  color: Colors.redAccent,
                  alignment: Alignment.centerRight,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                ),
                onDismissed: (dismissDirection) {
                  PlayerManager.audioHandler.removeQueueItemAt(i);
                },
                child: Material(
                  color: i == queueState.queueIndex
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : Colors.transparent,
                  child: ListTile(
                    leading: CachedNetworkImage(
                      imageUrl: queue[i].artUri.toString(),
                      height: 50.0,
                      width: 50.0,
                    ),
                    title: Text(
                      queue[i].title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: PlayerManager.size.width * 0.03,
                      ),
                    ),
                    subtitle: Text(queue[i].artist!),
                    trailing: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert),
                    ),
                    onTap: () {
                      PlayerManager.audioHandler.skipToQueueItem(i);
                      if (!PlayerManager
                          .audioHandler.playbackState.valueOrNull!.playing) {
                        PlayerManager.audioHandler.play();
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
