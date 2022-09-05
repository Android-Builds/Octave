import 'package:beats/classes/local_playlist.dart';
import 'package:beats/utils/player_manager.dart';
import 'package:beats/utils/utility.dart';
import 'package:beats/widgets/collage.dart';
import 'package:beats/widgets/playlist_list.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class LocalPlaylistPage extends StatefulWidget {
  const LocalPlaylistPage({
    Key? key,
    required this.index,
    required this.playlist,
  }) : super(key: key);

  final int index;
  final LocalPlaylist playlist;

  @override
  State<LocalPlaylistPage> createState() => _LocalPlaylistPageState();
}

class _LocalPlaylistPageState extends State<LocalPlaylistPage> {
  @override
  Widget build(BuildContext context) {
    final List<int> indexes = getRandomIndex(widget.playlist.songs.length);
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        shrinkWrap: true,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                margin: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 10.0,
                ),
                height: PlayerManager.size.width * 0.5,
                width: PlayerManager.size.width * 0.5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Collage(
                    mediaItems: widget.playlist.songs,
                    indexes: indexes,
                  ),
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.playlist.title,
                      style: TextStyle(
                        fontSize: PlayerManager.size.width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: getSongCountText(widget.playlist.songs.length),
                        style: DefaultTextStyle.of(context).style.copyWith(
                              fontSize: PlayerManager.size.width * 0.035,
                              color: Colors.grey,
                            ),
                        children: <TextSpan>[
                          const TextSpan(
                            text: ' \u2022 ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: totalDuration(widget.playlist.songs),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Play All'),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                          ),
                          child: const Icon(
                            Ionicons.shuffle,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          PlaylistList(
            playlist: widget.playlist.songs,
            playlistIndex: widget.index,
          ),
        ],
      ),
    );
  }
}
