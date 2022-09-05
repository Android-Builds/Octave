import 'package:beats/pages/discover_page.dart';
import 'package:beats/pages/trending_page.dart';
import 'package:beats/utils/constants.dart';
import 'package:beats/utils/player_manager.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../api/youtube_api.dart';
import 'trending_playlists_list.dart';
import 'trending_songs_list.dart';

class ForYouWidget extends StatelessWidget {
  const ForYouWidget({Key? key}) : super(key: key);

  getTimeSpecificGreetings() {
    int hour = DateTime.now().hour;
    if (hour >= 4 && hour < 12) {
      return "Good Morning";
    } else if (hour >= 12 && hour < 16) {
      return "Good Afternoon";
    } else if (hour >= 16 && hour < 20) {
      return "Good Evening";
    } else {
      return "Good Night";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: YtmApi.getHomePage(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          List data = snapshot.data;
          return ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  bottom: 5.0,
                ),
                child: Row(
                  children: [
                    Text(
                      '${getTimeSpecificGreetings()}, $userName',
                      style: TextStyle(
                        fontSize: PlayerManager.size.height * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  discoveryCards(
                    context,
                    'Discover',
                    Ionicons.compass,
                    const DiscoverPage(),
                  ),
                  discoveryCards(
                    context,
                    'Trending',
                    Ionicons.trending_up,
                    const TrendingPage(),
                  ),
                ],
              ),
              for (Map contentMap in data)
                contentMap['type'] == ContentType.songlist
                    ? TrendingSongsListWidget(
                        title: contentMap['title'],
                        trendingSongs: contentMap['list'],
                      )
                    : TrendingPlaylistWidget(
                        title: contentMap['title'],
                        trendingPlaylists: contentMap['list'],
                      )
            ],
          );
        } else {
          return SizedBox(
            height: PlayerManager.size.height * 0.8,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Widget discoveryCards(
    BuildContext context,
    String title,
    IconData icon,
    Widget targetPage,
  ) {
    return Flexible(
      child: TextButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const TrendingPage())),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon),
                const SizedBox(width: 10.0),
                Text(
                  title,
                  style: TextStyle(fontSize: PlayerManager.size.width * 0.05),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
