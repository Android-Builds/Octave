import 'package:beats/utils/player_manager.dart';
import 'package:beats/widgets/playlist_item.dart';
import 'package:flutter/material.dart';

import '../classes/trending_playlists.dart';
import '../pages/playlist_page.dart';

class TrendingPlaylistWidget extends StatelessWidget {
  final String title;
  final List<TrendingPlaylists> trendingPlaylists;

  const TrendingPlaylistWidget({
    Key? key,
    required this.trendingPlaylists,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 10.0,
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: PlayerManager.size.height * 0.31,
          child: NotificationListener<OverscrollNotification>(
            // Suppress OverscrollNotification events that escape from the inner scrollable
            onNotification: (notification) =>
                notification.metrics.axisDirection != AxisDirection.down,
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 10.0),
              scrollDirection: Axis.horizontal,
              itemCount: trendingPlaylists.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    if (title == 'Recommended music videos') {
                      List<String> id =
                          trendingPlaylists[index].playlistId.split(':');
                      PlayerManager.playMusic(id[1], id[0], title);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaylistPage(
                            playlistId: trendingPlaylists[index].playlistId,
                            thumbnail: trendingPlaylists[index].thumbnail,
                          ),
                        ),
                      );
                    }
                  },
                  child: PlaylistItem(
                    title: trendingPlaylists[index].title,
                    subtitle: trendingPlaylists[index].subtitle,
                    thumbnail: trendingPlaylists[index].thumbnail,
                    width: PlayerManager.size.width * 0.45,
                    titleMaxLine: 1,
                    subtitleMaxLine: 2,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
