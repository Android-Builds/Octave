import 'package:octave/api/youtube_api.dart';
import 'package:octave/blocs/api_call_bloc/api_call_bloc.dart';
import 'package:octave/classes/trending_artists.dart';
import 'package:octave/widgets/song_and_artist_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/player_manager.dart';

class TrendingPage extends StatefulWidget {
  const TrendingPage({Key? key}) : super(key: key);

  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  int _value = 1;
  static bool first = false;
  static final ApiCallBloc countryBloc = ApiCallBloc();
  static final ApiCallBloc trendingByCountryBloc = ApiCallBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trending')),
      body: ListView(
        children: [
          BlocBuilder<ApiCallBloc, ApiCallBlocState>(
            bloc: countryBloc,
            builder: (context, state) {
              if (state is ApiCallBlocInitial) {
                countryBloc.add(
                    const FetchApiWithNoParams(YtmApi.getTrendingCountries));
                return const SizedBox.shrink();
              } else if (state is ApiCallBlocLaoding) {
                return const SizedBox.shrink();
              } else if (state is ApiCallBlocFinal) {
                List<Map<dynamic, dynamic>> countryCodes = state.data;
                for (int i = 0; i < countryCodes.length; i++) {
                  if (countryCodes[i]['code'] == PlayerManager.countryCode) {
                    _value = i;
                    break;
                  }
                }
                if (!first) {
                  countryCodes.insert(1, countryCodes.removeAt(_value));
                  _value = 1;
                  first = true;
                }
                return SizedBox(
                  height: PlayerManager.size.height * 0.08,
                  child: NotificationListener<OverscrollNotification>(
                    onNotification: (notification) =>
                        notification.metrics.axisDirection !=
                        AxisDirection.down,
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
                              PlayerManager.countryCode =
                                  countryCodes[index]['code'];
                              trendingByCountryBloc.add(FetchApiWithOneParams(
                                  YtmApi.getTrending,
                                  PlayerManager.countryCode));
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          BlocBuilder<ApiCallBloc, ApiCallBlocState>(
            bloc: trendingByCountryBloc,
            builder: (context, state) {
              if (state is ApiCallBlocInitial) {
                trendingByCountryBloc.add(FetchApiWithOneParams(
                    YtmApi.getTrending, PlayerManager.countryCode));
                return SizedBox(
                  height: PlayerManager.size.height * 0.8,
                  child: const Center(child: CircularProgressIndicator()),
                );
              } else if (state is ApiCallBlocLaoding) {
                return SizedBox(
                  height: PlayerManager.size.height * 0.7,
                  child: const Center(child: CircularProgressIndicator()),
                );
              } else if (state is ApiCallBlocFinal) {
                List<Map<dynamic, dynamic>> trendingMap = state.data;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: trendingMap.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 20.0,
                          ),
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
                                padding: const EdgeInsets.all(10.0),
                                itemCount: trendingMap[index]['items'].length,
                                scrollDirection: Axis.horizontal,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: double.parse(
                                    (PlayerManager.size.height *
                                            0.72 /
                                            PlayerManager.size.width)
                                        .toStringAsFixed(2),
                                  ),
                                ),
                                itemBuilder: (context, internalIndex) {
                                  bool artist = trendingMap[index]['items']
                                              [internalIndex]
                                          .runtimeType ==
                                      TrendingArtist;
                                  return SongAndArtistItem(
                                    title: trendingMap[index]['items']
                                            [internalIndex]
                                        .title,
                                    subtitle: trendingMap[index]['items']
                                            [internalIndex]
                                        .subtitle,
                                    browseId: artist
                                        ? trendingMap[index]['items']
                                                [internalIndex]
                                            .browseId
                                        : trendingMap[index]['items']
                                                [internalIndex]
                                            .videoId,
                                    playlistId: artist
                                        ? ''
                                        : trendingMap[index]['items']
                                                [internalIndex]
                                            .playlistId,
                                    thumbnail: trendingMap[index]['items']
                                            [internalIndex]
                                        .thumbnail,
                                    width: PlayerManager.size.width * 0.3,
                                    artist: artist,
                                  );
                                }),
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
      ),
    );
  }
}
