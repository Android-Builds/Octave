import 'package:beats/api/youtube_api.dart';
import 'package:beats/classes/playlist.dart';
import 'package:beats/utils/player_manager.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../widgets/custom_delegate.dart';

class PlaylistPage extends StatefulWidget {
  final String playlistId;
  final String thumbnail;
  const PlaylistPage({
    Key? key,
    required this.playlistId,
    required this.thumbnail,
  }) : super(key: key);

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  YoutubeExplode youtubeExplode = YoutubeExplode();

  @override
  void initState() {
    PlayerManager.homePage = false;
    Future.delayed(const Duration(milliseconds: 100),
        () => PlayerManager.navbarHeight.value = 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder(
          future: YtmApi.getPlaylist(widget.playlistId),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              SongPlayList playlist = snapshot.data;
              return NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverPersistentHeader(
                      delegate: MyDelegate(
                        title: playlist.title,
                        imageUrl: widget.thumbnail,
                        leading: Row(
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    playlist.title,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: PlayerManager.size.width * 0.05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    playlist.subtitle,
                                    maxLines: 1,
                                  ),
                                  Text(playlist.secondarySubtitle),
                                ],
                              ),
                            ),
                            TextButton(
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(20),
                              ),
                              onPressed: () {},
                              child: const Icon(Ionicons.shuffle),
                            ),
                          ],
                        ),
                        button: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(20),
                          ),
                          onPressed: () async {
                            PlayerManager.addToPlaylistAndPlay(playlist.items);
                          },
                          child: const Icon(Icons.play_arrow),
                        ),
                      ),
                      floating: true,
                      pinned: true,
                    ),
                  ];
                },
                body: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: playlist.items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        if (PlayerManager
                            .audioHandler.playbackState.valueOrNull!.playing) {
                          PlayerManager.audioHandler.skipToQueueItem(index);
                        } else {
                          PlayerManager.addToPlaylistAndPlay(
                              playlist.items, index);
                        }
                      },
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: Image.network(
                          playlist.items[index].artUri.toString(),
                          height: PlayerManager.size.width * 0.15,
                          width: PlayerManager.size.width * 0.15,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        formatSongTitle(playlist.items[index].title),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                      subtitle: Text('${playlist.items[index].artist} \u2022 '
                          '${RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$').firstMatch("${playlist.items[index].duration}")?.group(1)}'),
                    );
                  },
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  getDuration(List<Video> playlistSongs) {
    List<String>? times = RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
        .firstMatch(
            "${Duration(seconds: playlistSongs.map((e) => e.duration!.inSeconds).fold(0, (previousValue, element) => int.parse(previousValue.toString()) + element))}")
        ?.group(1)!
        .split(':');

    return '${times!.first}h ${times[1]}m';
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
        .trim();
    // .replaceAll('- |', '|')
    // .replaceAll('\u2013 |', '|')
    // .replaceAll('@', '')
    // .replaceAll('()', '')
    // .replaceAll('( )', '')
    // .replaceAll('  ', ' ')
    // .replaceAll("#", '')
    // .replaceAll(' |', ', ')
    // .replaceAllMapped(RegExp(r'[a-z]{0}:.'), (match) => '')
    // .replaceAllMapped(RegExp(r',\s{0,1}[a-z]*'), (match) => '')
    // .trim();

    return '${title.substring(0, 1).toUpperCase()}${title.substring(1)}';
  }

  @override
  void dispose() {
    PlayerManager.homePage = true;
    Future.delayed(const Duration(milliseconds: 50),
        () => PlayerManager.navbarHeight.value = kBottomNavigationBarHeight);
    super.dispose();
  }
}
