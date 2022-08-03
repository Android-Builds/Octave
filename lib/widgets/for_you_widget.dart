import 'package:beats/utils/constants.dart';
import 'package:beats/utils/player_manager.dart';
import 'package:flutter/material.dart';

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
      future: YoutubeMusicApi.getHomePage(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List data = snapshot.data as List;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    bottom: 5.0,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${getTimeSpecificGreetings()}, ${Constants.userName}',
                        style: TextStyle(
                          fontSize: PlayerManager.size.height * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (data[index - 1]['type'] == ContentType.songlist) {
                return TrendingSongsListWidget(
                  title: data[index - 1]['title'],
                  trendingSongs: data[index - 1]['list'],
                );
              } else {
                return TrendingPlaylistWidget(
                  title: data[index - 1]['title'],
                  trendingPlaylists: data[index - 1]['list'],
                );
              }
            },
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
}
