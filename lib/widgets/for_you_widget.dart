import 'package:octave/blocs/api_call_bloc/api_call_bloc.dart';
import 'package:octave/pages/discover_page.dart';
import 'package:octave/pages/trending_page.dart';
import 'package:octave/utils/player_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  static final ApiCallBloc bloc = ApiCallBloc();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApiCallBloc, ApiCallBlocState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is ApiCallBlocInitial) {
          bloc.add(const FetchApiWithNoParams(YtmApi.getHomePage));
          return SizedBox(
            height: PlayerManager.size.height * 0.8,
            child: const Center(child: CircularProgressIndicator()),
          );
        } else if (state is ApiCallBlocLaoding) {
          return SizedBox(
            height: PlayerManager.size.height * 0.8,
            child: const Center(child: CircularProgressIndicator()),
          );
        } else if (state is ApiCallBlocFinal) {
          return RefreshIndicator(
            triggerMode: RefreshIndicatorTriggerMode.anywhere,
            onRefresh: () async {
              bloc.add(const FetchApiWithNoParams(YtmApi.getHomePage));
            },
            child: ListView(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // Padding(
                //   padding: const EdgeInsets.only(
                //     left: 20.0,
                //     bottom: 5.0,
                //   ),
                //   child: Row(
                //     children: [
                //       Text(
                //         '${getTimeSpecificGreetings()}, $userName',
                //         style: TextStyle(
                //           fontSize: PlayerManager.size.height * 0.04,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
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
                for (Map contentMap in state.data)
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
            ),
          );
        }
        return Container();
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
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => targetPage)),
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
