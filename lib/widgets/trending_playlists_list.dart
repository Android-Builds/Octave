import 'package:beats/utils/player_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
          height: 300.0,
          child: NotificationListener<OverscrollNotification>(
            // Suppress OverscrollNotification events that escape from the inner scrollable
            onNotification: (notification) =>
                notification.metrics.axisDirection != AxisDirection.down,
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 10.0),
              scrollDirection: Axis.horizontal,
              itemCount: trendingPlaylists.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaylistPage(
                          playlistId: trendingPlaylists[index].playlistId,
                          thumbnail: trendingPlaylists[index].thumbnail,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    width: 200.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: CachedNetworkImage(
                            imageUrl: trendingPlaylists[index].thumbnail,
                            height: 180,
                            width: 180,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          trendingPlaylists[index].title,
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 15.0,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          trendingPlaylists[index].subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: PlayerManager.size.width * 0.033,
                          ),
                        ),
                      ],
                    ),
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
