import 'package:beats/blocs/api_call_bloc/api_call_bloc.dart';
import 'package:beats/pages/playlist_page.dart';
import 'package:beats/utils/player_manager.dart';
import 'package:beats/widgets/playlist_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../api/youtube_api.dart';

class MoodsAndGenres extends StatefulWidget {
  const MoodsAndGenres({Key? key, required this.moodsAndGenreMap})
      : super(key: key);

  final Map moodsAndGenreMap;

  @override
  State<MoodsAndGenres> createState() => _MoodsAndGenresState();
}

class _MoodsAndGenresState extends State<MoodsAndGenres> {
  final ApiCallBloc bloc = ApiCallBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moodsAndGenreMap['title']),
      ),
      body: BlocBuilder<ApiCallBloc, ApiCallBlocState>(
        bloc: bloc,
        builder: (context, state) {
          if (state is ApiCallBlocInitial) {
            bloc.add(
              FetchApiWithTwoParams(
                YtmApi.getPlaylistFromMoodOrGenre,
                widget.moodsAndGenreMap['browseId'],
                widget.moodsAndGenreMap['params'],
              ),
            );
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
            List<dynamic> items = state.data;
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
                          fontSize: PlayerManager.size.width * 0.06,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    items[index]['playlists'].length == 2
                        ? SizedBox(
                            height: PlayerManager.size.height * 0.35,
                            child: ListView.builder(
                              itemCount: items[index]['playlists'].length,
                              scrollDirection: Axis.horizontal,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, internalIndex) {
                                Map playlist =
                                    items[index]['playlists'][internalIndex];
                                return GestureDetector(
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
                                    width: PlayerManager.size.width * 0.45,
                                    titleMaxLine: 1,
                                    subtitleMaxLine: 2,
                                  ),
                                );
                              },
                            ))
                        : SizedBox(
                            height: PlayerManager.size.height * 0.7,
                            child: GridView.builder(
                              shrinkWrap: true,
                              itemCount: items[index]['playlists'].length,
                              scrollDirection: Axis.horizontal,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.6,
                              ),
                              itemBuilder: (context, internalIndex) {
                                Map playlist =
                                    items[index]['playlists'][internalIndex];
                                return GestureDetector(
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
                                    titleMaxLine: 1,
                                    subtitleMaxLine: 2,
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                );
              },
            );
          } else {
            return SizedBox(
              height: PlayerManager.size.height * 0.8,
              child: const Center(child: Text('Error')),
            );
          }
        },
      ),
    );
  }
}
