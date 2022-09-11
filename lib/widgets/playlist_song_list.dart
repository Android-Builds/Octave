import 'package:akar_icons_flutter/akar_icons_flutter.dart';
import 'package:audio_service/audio_service.dart';
import 'package:beats/pages/local_playlist_list.dart';
import 'package:beats/pages/playlist_page.dart';
import 'package:beats/utils/constants.dart';
import 'package:beats/utils/db_helper.dart';
import 'package:beats/utils/player_manager.dart';
import 'package:beats/utils/utility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class PlaylistSongList extends StatefulWidget {
  final List<MediaItem> playlist;
  final int? playlistIndex;
  const PlaylistSongList({
    Key? key,
    required this.playlist,
    this.playlistIndex,
  }) : super(key: key);

  @override
  State<PlaylistSongList> createState() => _PlaylistSongListState();
}

class _PlaylistSongListState extends State<PlaylistSongList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.playlist.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            if (PlayerManager.audioHandler.playbackState.valueOrNull!.playing) {
              PlayerManager.audioHandler.skipToQueueItem(index);
            } else {
              PlayerManager.addToPlaylistAndPlay(widget.playlist, index);
            }
          },
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            child: Image.network(
              widget.playlist[index].artUri.toString(),
              height: PlayerManager.size.width * 0.15,
              width: PlayerManager.size.width * 0.15,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            formatSongTitle(widget.playlist[index].title),
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
          subtitle: Text(
            '${widget.playlist[index].artist} \u2022 '
            '${durationTextFromDuration(widget.playlist[index].duration!)}',
            maxLines: 2,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            // onPressed: () => Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => PlaylistMenuPage(),
            //     )),
            onPressed: () => showMenu(index, context, widget.playlist[index]),
          ),
        );
      },
    );
  }

  formatSongTitle(String text) {
    String title = text
        .replaceAll("#", '')
        .replaceAll(' |', ', ')
        .replaceAll(' ,', ',')
        .replaceAll('   ', ' ')
        .replaceAll('Video', '')
        .replaceAll('VIDEO', '')
        .replaceAll('Full ', '')
        .replaceAll('Official ', '')
        .replaceAll(' -  - ', ' - ')
        .replaceAllMapped(RegExp(r',\s{0,1}[a-z]*'), (match) => '')
        .replaceAll('()', '')
        .replaceAll('  ', ' ')
        .trim();

    return '${title.substring(0, 1).toUpperCase()}${title.substring(1)}';
  }

  Future<void> showMenu(
    int index,
    BuildContext context,
    MediaItem mediaItem,
  ) async {
    TextStyle menuStyle = TextStyle(
      fontSize: PlayerManager.size.width * 0.04,
      fontWeight: FontWeight.bold,
    );
    showModalBottomSheet<void>(
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      useRootNavigator: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 5.0,
          ),
          child: Wrap(
            //shrinkWrap: true,
            alignment: WrapAlignment.center,
            children: [
              Container(
                height: PlayerManager.size.width * 0.5,
                width: PlayerManager.size.width * 0.5,
                margin: const EdgeInsets.symmetric(vertical: 20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      mediaItem.artUri.toString(),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                width: PlayerManager.size.width,
                child: Text(
                  mediaItem.title,
                  style: TextStyle(
                    fontSize: PlayerManager.size.width * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: PlayerManager.size.width * 0.7,
                child: Text(
                  '${mediaItem.artist} \u2022 '
                  '${mediaItem.album!}',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 50.0),
              ListTile(
                dense: true,
                leading: const Icon(Icons.playlist_play),
                onTap: () async {
                  int mediaIndex = PlayerManager.audioHandler.queue.value
                      .indexOf(PlayerManager.audioHandler.mediaItem.value!);
                  PlayerManager.audioHandler
                      .insertQueueItem(mediaIndex + 1, mediaItem);
                },
                title: Text(
                  'Play Next',
                  style: menuStyle,
                ),
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.queue_music),
                onTap: () {},
                title: Text(
                  'Add to queue',
                  style: menuStyle,
                ),
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.playlist_add),
                onTap: () => showPlaylists(
                  context,
                  mediaItem,
                ),
                title: Text(
                  'Add to playlist',
                  style: menuStyle,
                ),
              ),
              ListTile(
                dense: true,
                enabled: widget.playlistIndex != null,
                leading: const Icon(Icons.playlist_remove),
                onTap: widget.playlistIndex != null
                    ? () {
                        widget.playlist.removeAt(index);
                        removeSongFromPlaylist(widget.playlistIndex!, index)
                            .then((value) => Navigator.pop(context));
                        setState(() {});
                      }
                    : null,
                title: Text(
                  'Remove from playlist',
                  style: menuStyle,
                ),
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.person),
                onTap: () {},
                title: Text(
                  'Go to artist',
                  style: menuStyle,
                ),
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.album),
                enabled: mediaItem.extras!.containsKey('albumId'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaylistPage(
                        playlistId: mediaItem.extras!['albumId'],
                        thumbnail: mediaItem.artUri.toString(),
                      ),
                    ),
                  );
                },
                title: Text(
                  'Go to Album',
                  style: menuStyle,
                ),
              ),
              ListTile(
                dense: true,
                leading: const Icon(AkarIcons.arrow_forward_thick),
                onTap: () {
                  Share.share(
                    '$playlistPrefix${''.replaceAll('VL', '')}&feature=share',
                  );
                },
                title: Text(
                  'Share',
                  style: menuStyle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> showPlaylists(
    BuildContext context,
    MediaItem mediaItem,
  ) async {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      useRootNavigator: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              LocalPlaylistList(
                mediaItem: mediaItem,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('+ New Playlist'),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
