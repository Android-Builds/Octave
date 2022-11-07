import 'package:audio_service/audio_service.dart';
import 'package:octave/classes/local_playlist.dart';
import 'package:octave/pages/local_playlist_page.dart';
import 'package:octave/utils/db_helper.dart';
import 'package:octave/utils/player_manager.dart';
import 'package:octave/utils/utility.dart';
import 'package:octave/widgets/collage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LocalPlaylistList extends StatelessWidget {
  final MediaItem? mediaItem;
  const LocalPlaylistList({Key? key, this.mediaItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = PlayerManager.size.width * 0.05;
    return ValueListenableBuilder(
      valueListenable: importedPlaylistsListenable(),
      builder: (context, Box importedPlaylistBox, _) {
        return importedPlaylistBox.isNotEmpty
            ? NotificationListener<OverscrollNotification>(
                onNotification: (notification) =>
                    notification.metrics.axisDirection != AxisDirection.down,
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(10.0),
                  itemCount: importedPlaylistBox.length,
                  itemBuilder: (context, index) {
                    LocalPlaylist localPlaylist = LocalPlaylist.fromJson(
                        importedPlaylistBox.getAt(index));
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
                              if (localPlaylist.songs.any(
                                  (element) => element.id == mediaItem!.id)) {
                                Navigator.pop(context);
                                showSnackbar(context, 'Already in Playlist');
                              } else {
                                localPlaylist.songs.add(mediaItem!);
                                editPlaylist(index, localPlaylist)
                                    .then((value) {
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
                      subtitle:
                          Text(getSongCountText(localPlaylist.songs.length)),
                    );
                  },
                ),
              )
            : Center(
                child: Transform.scale(
                  scale: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.queue_music, size: size * 1.5),
                      const SizedBox(height: 20.0),
                      Text(
                        'Add playlists to show',
                        style: TextStyle(fontSize: size),
                      )
                    ],
                  ),
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
