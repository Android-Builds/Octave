import 'package:audio_service/audio_service.dart';
import 'package:beats/classes/local_playlist.dart';
import 'package:beats/pages/local_playlist_page.dart';
import 'package:beats/utils/constants.dart';
import 'package:beats/utils/db_helper.dart';
import 'package:beats/utils/player_manager.dart';
import 'package:beats/utils/utility.dart';
import 'package:beats/widgets/collage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LocalPlaylistList extends StatelessWidget {
  final MediaItem? mediaItem;
  const LocalPlaylistList({Key? key, this.mediaItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: importedPlaylistsListenable(),
      builder: (context, Box importedPlaylistBox, _) {
        return NotificationListener<OverscrollNotification>(
          onNotification: (notification) =>
              notification.metrics.axisDirection != AxisDirection.down,
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(10.0),
            itemCount: importedPlaylistBox.length,
            itemBuilder: (context, index) {
              LocalPlaylist localPlaylist =
                  LocalPlaylist.fromJson(importedPlaylistBox.getAt(index));
              final List<int> indexes =
                  getRandomIndex(localPlaylist.songs.length);
              return ListTile(
                onTap: mediaItem == null
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LocalPlaylistPage(
                              playlist: localPlaylist,
                              index: index,
                            ),
                          ),
                        )
                    : () {
                        if (localPlaylist.songs
                            .any((element) => element.id == mediaItem!.id)) {
                          Navigator.pop(context);
                          showSnackbar(context, 'Already in Playlist');
                        } else {
                          localPlaylist.songs.add(mediaItem!);
                          editPlaylist(index, localPlaylist).then((value) {
                            Navigator.pop(context);
                            showSnackbar(context, 'Added to Playlist');
                          });
                        }
                      },
                leading: SizedBox(
                  width: 50,
                  height: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3.0),
                    child: Collage(
                      mediaItems: localPlaylist.songs,
                      indexes: indexes,
                    ),
                  ),
                ),
                title: Text(localPlaylist.title),
                subtitle: Text(getSongCountText(localPlaylist.songs.length)),
              );
            },
          ),
        );
      },
    );
  }

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        padding: const EdgeInsets.all(10.0),
      ),
    );
  }
}
