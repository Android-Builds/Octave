import 'package:beats/pages/playlist_page.dart';
import 'package:beats/utils/player_manager.dart';
import 'package:beats/widgets/playlist_item.dart';
import 'package:flutter/material.dart';

import '../api/youtube_api.dart';

class MoodsAndGenres extends StatefulWidget {
  const MoodsAndGenres({Key? key, required this.moodsAndGenreMap})
      : super(key: key);

  final Map moodsAndGenreMap;

  @override
  State<MoodsAndGenres> createState() => _MoodsAndGenresState();
}

class _MoodsAndGenresState extends State<MoodsAndGenres> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moodsAndGenreMap['title']),
      ),
      body: FutureBuilder(
        future: YoutubeMusicApi.getPlaylistFromMoodOrGenre(
          widget.moodsAndGenreMap['browseId'],
          widget.moodsAndGenreMap['params'],
        ),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            List items = snapshot.data;
            return ListView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.all(10.0),
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ListTile(
                      dense: true,
                      title: Text(
                        items[index]['title'],
                        style: TextStyle(
                          fontSize: PlayerManager.size.width * 0.055,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      itemCount: items[index]['playlists'].length,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.74,
                      ),
                      itemBuilder: (context, internalIndex) {
                        Map playlist = items[index]['playlists'][internalIndex];
                        return InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlaylistPage(
                                playlistId: playlist['browseId'],
                                thumbnail: playlist['thumbnail'],
                              ),
                            ),
                          ),
                          child: PlaylistItem(
                            title: playlist['title'],
                            subtitle: playlist['subtitle'],
                            thumbnail: playlist['thumbnail'],
                            width: PlayerManager.size.width * 0.46,
                            titleMaxLine: 1,
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
