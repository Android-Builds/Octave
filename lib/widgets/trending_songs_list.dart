import 'package:beats/utils/player_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: CachedNetworkImage(
                        imageUrl: trendingSongs[index].thumbnail,
                        height: PlayerManager.size.width * 0.3,
                        width: PlayerManager.size.width * 0.3,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    SizedBox(
                      width: PlayerManager.size.width * 0.3,
                      child: Text(
                        trendingSongs[index].title,
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: PlayerManager.size.width * 0.035,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: PlayerManager.size.width * 0.3,
                      child: Text(
                        trendingSongs[index].subtitle,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                );
                // return ListTile(
                //   onTap: () {
                //     PlayerManager.playMusic(
                //       context,
                //       trendingSongs[index].videoId,
                //       trendingSongs[index].playlistId,
                //       trendingSongs[index],
                //       title,
                //     );
                //   },
                //   minLeadingWidth: 60.0,
                //   leading: ClipRRect(
                //     borderRadius: BorderRadius.circular(3.0),
                //     child: CachedNetworkImage(
                //       imageUrl: trendingSongs[index].thumbnail,
                //       height: 60.0,
                //       width: 60.0,
                //       fit: BoxFit.cover,
                //     ),
                //   ),
                //   title: Text(
                //     trendingSongs[index].title,
                //     overflow: TextOverflow.ellipsis,
                //   ),
                //   subtitle: Text(trendingSongs[index].subtitle),
                //   trailing: IconButton(
                //     onPressed: () {},
                //     icon: const Icon(Icons.more_vert),
                //   ),
                // );
              },
            ),
          ),
        ),
      ],
    );
  }
}
