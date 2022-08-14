import 'package:beats/api/youtube_api.dart';
import 'package:beats/classes/trending_artists.dart';
import 'package:beats/pages/artists_page.dart';
import 'package:beats/widgets/song_and_artist_item.dart';
import 'package:flutter/material.dart';

import '../utils/player_manager.dart';

class TrendingPage extends StatefulWidget {
  const TrendingPage({Key? key}) : super(key: key);

  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  int _value = 0;
  String selectedCode = 'ZZ';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: PlayerManager.size.height * 0.08,
          child: FutureBuilder(
            future: YoutubeMusicApi.getTrendingCountries(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                List<Map<dynamic, dynamic>> countryCodes = snapshot.data;
                return NotificationListener<OverscrollNotification>(
                  onNotification: (notification) =>
                      notification.metrics.axisDirection != AxisDirection.down,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: countryCodes.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: ChoiceChip(
                        padding: const EdgeInsets.all(5.0),
                        label: Text(countryCodes[index]['country']),
                        selected: _value == index,
                        onSelected: (bool selected) {
                          setState(() {
                            _value = selected ? index : 1;
                            selectedCode = countryCodes[index]['code'];
                          });
                        },
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
        FutureBuilder(
          future: YoutubeMusicApi.getTrending(selectedCode),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              List<Map<dynamic, dynamic>> trendingMap = snapshot.data;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: trendingMap.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        dense: true,
                        title: Text(
                          trendingMap[index]['title'],
                          style: TextStyle(
                            fontSize: PlayerManager.size.width * 0.06,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: PlayerManager.size.height * 0.5,
                        child: NotificationListener<OverscrollNotification>(
                          onNotification: (notification) =>
                              notification.metrics.axisDirection !=
                              AxisDirection.down,
                          child: GridView.builder(
                            shrinkWrap: true,
                            itemCount: trendingMap[index]['items'].length,
                            scrollDirection: Axis.horizontal,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.1,
                            ),
                            itemBuilder: (context, internalIndex) => InkWell(
                              onTap: () {
                                if (trendingMap[index]['items'][internalIndex]
                                        .runtimeType ==
                                    TrendingArtist) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ArtistsPage(
                                        imageUrl: trendingMap[index]['items']
                                                [internalIndex]
                                            .thumbnail,
                                        title: trendingMap[index]['items']
                                                [internalIndex]
                                            .title,
                                        artistId: trendingMap[index]['items']
                                                [internalIndex]
                                            .browseId,
                                      ),
                                    ),
                                  );
                                } else {
                                  PlayerManager.playMusic(
                                    trendingMap[index]['items'][internalIndex]
                                        .videoId,
                                    trendingMap[index]['items'][internalIndex]
                                        .playlistId,
                                    'Trending',
                                  );
                                }
                              },
                              child: SongAndArtistItem(
                                title: trendingMap[index]['items']
                                        [internalIndex]
                                    .title,
                                subtitle: trendingMap[index]['items']
                                        [internalIndex]
                                    .subtitle,
                                thumbnail: trendingMap[index]['items']
                                        [internalIndex]
                                    .thumbnail,
                                width: PlayerManager.size.width * 0.3,
                                artist: trendingMap[index]['items']
                                            [internalIndex]
                                        .runtimeType ==
                                    TrendingArtist,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            } else {
              return SizedBox(
                height: PlayerManager.size.height * 0.7,
                child: const Center(child: CircularProgressIndicator()),
              );
            }
          },
        ),
      ],
    );
  }
}
