import 'package:beats/api/youtube_api.dart';
import 'package:beats/utils/player_manager.dart';
import 'package:flutter/material.dart';
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
          future: YoutubeMusicApi.getPlaylist(widget.playlistId),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              Playlist playlist = snapshot.data[0];
              List<Video> playlistSongs = snapshot.data[1];
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  playlist.title,
                                  style: TextStyle(
                                    fontSize: PlayerManager.size.width * 0.05,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                    '${playlist.videoCount} Songs \u00B7 ${getDuration(playlistSongs)}')
                              ],
                            ),
                            TextButton(
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(20),
                              ),
                              onPressed: () {},
                              child: const Icon(Icons.shuffle),
                            ),
                          ],
                        ),
                        button: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(20),
                          ),
                          onPressed: () async {
                            PlayerManager.playFromPlaylist(
                                playlistSongs, playlist);
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
                  itemCount: playlistSongs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: Image.network(
                          playlistSongs[index].thumbnails.lowResUrl,
                          height: 50.0,
                          width: 60.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        formatSongTitle(playlistSongs[index].title),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                      subtitle: Text('${playlistSongs[index].author} \u00B7'
                          '${RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$').firstMatch("${playlistSongs[index].duration}")?.group(1)}'),
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
        .replaceAll('Video', '')
        .replaceAll('Full ', '')
        .replaceAll('Official ', '')
        .replaceAll('- |', '|')
        .replaceAll('\u2013 |', '|')
        .replaceAll(' |', ', ')
        .replaceAll('@', '')
        .replaceAll('()', '')
        .replaceAll('( )', '')
        .replaceAll('  ', ' ')
        .replaceAllMapped(RegExp(r'[a-z]{0}:.'), (match) => '');

    return title;
  }

  @override
  void dispose() {
    PlayerManager.homePage = true;
    Future.delayed(const Duration(milliseconds: 50),
        () => PlayerManager.navbarHeight.value = kBottomNavigationBarHeight);
    super.dispose();
  }
}
