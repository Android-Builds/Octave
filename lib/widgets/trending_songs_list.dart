import 'package:beats/utils/player_manager.dart';
import 'package:beats/widgets/song_and_artist_item.dart';
import 'package:flutter/material.dart';
import '../classes/trending_songs.dart';

class TrendingSongsListWidget extends StatelessWidget {
  final String title;
  final List<TrendingSong> trendingSongs;
  const TrendingSongsListWidget({
    Key? key,
    required this.trendingSongs,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 20.0,
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
          height: PlayerManager.size.height * 0.5,
          child: NotificationListener<OverscrollNotification>(
            // Suppress OverscrollNotification events that escape from the inner scrollable
            onNotification: (notification) =>
                notification.metrics.axisDirection != AxisDirection.down,
            child: GridView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(10.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
              ),
              itemCount: trendingSongs.length,
              itemBuilder: (BuildContext context, int index) {
                return SongAndArtistItem(
                  title: trendingSongs[index].title,
                  subtitle: trendingSongs[index].subtitle,
                  browseId: trendingSongs[index].videoId,
                  playlistId: trendingSongs[index].playlistId,
                  thumbnail: trendingSongs[index].thumbnail,
                  width: PlayerManager.size.width * 0.3,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
