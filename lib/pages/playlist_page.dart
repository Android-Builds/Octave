import 'package:akar_icons_flutter/akar_icons_flutter.dart';
import 'package:beats/api/youtube_api.dart';
import 'package:beats/blocs/api_call_bloc/api_call_bloc.dart';
import 'package:beats/classes/playlist.dart';
import 'package:beats/utils/constants.dart';
import 'package:beats/utils/db_helper.dart';
import 'package:beats/utils/player_manager.dart';
import 'package:beats/widgets/playlist_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:share_plus/share_plus.dart';

import '../widgets/custom_delegate.dart';

class PlaylistPage extends StatefulWidget {
  final String playlistId;
  final String thumbnail;
  const PlaylistPage({
    Key? key,
    required this.playlistId,
    required this.thumbnail,
  }) : super(key: key);

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  bool isFavourite = false;
  final ApiCallBloc bloc = ApiCallBloc();

  @override
  void initState() {
    PlayerManager.homePage = false;
    Future.delayed(const Duration(milliseconds: 100),
        () => PlayerManager.navbarHeight.value = 0);
    super.initState();
  }

  Future<void> showMenu(SongPlayList playlist) async {
    TextStyle menuStyle = TextStyle(
      fontSize: PlayerManager.size.width * 0.035,
    );
    showModalBottomSheet<void>(
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(
            top: 10.0,
            right: 5.0,
            left: 5.0,
          ),
          child: Wrap(
            children: [
              ListTile(
                dense: true,
                leading: const Icon(Icons.playlist_add),
                onTap: () {},
                title: Text(
                  'Add to queue',
                  style: menuStyle,
                ),
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.import_export),
                onTap: () async {
                  await importPlaylist(playlist).then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Playlist Imported'),
                      ),
                    );
                    Navigator.of(context).pop();
                  });
                },
                title: Text(
                  'Import',
                  style: menuStyle,
                ),
              ),
              ListTile(
                dense: true,
                leading: const Icon(AkarIcons.arrow_forward_thick),
                onTap: () {
                  Share.share(
                    '$playlistPrefix${widget.playlistId.replaceAll('VL', '')}&feature=share',
                  );
                },
                title: Text(
                  'Share',
                  style: menuStyle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = PlayerManager.size.width * 0.05;
    return SafeArea(
      child: Scaffold(
        body: BlocBuilder<ApiCallBloc, ApiCallBlocState>(
          bloc: bloc,
          builder: (context, state) {
            if (state is ApiCallBlocInitial) {
              bloc.add(FetchApiWithOneParams(
                YtmApi.getPlaylist,
                widget.playlistId,
              ));
              return const Center(child: CircularProgressIndicator());
            } else if (state is ApiCallBlocLaoding) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ApiCallBlocFinal) {
              SongPlayList playlist = state.data;
              if (checkifPlaylistExists(widget.playlistId)) {
                isFavourite = true;
              }
              return NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverPersistentHeader(
                      delegate: MyDelegate(
                        title: playlist.title,
                        imageUrl: widget.thumbnail,
                        leading: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              playlist.title,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: PlayerManager.size.width * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              playlist.subtitle,
                              maxLines: 1,
                            ),
                            Text(playlist.secondarySubtitle),
                          ],
                        ),
                        actions: [
                          TextButton(
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(20),
                            ),
                            onPressed: () {
                              Map<String, String> playlistMap = {
                                'playlistId': widget.playlistId,
                                'title': playlist.title,
                                'thumbnail': playlist.thumbnail,
                              };
                              isFavourite = !isFavourite;
                              if (isFavourite) {
                                checkAndAddFavourite(playlistMap);
                              } else {
                                checkAndDelete(playlistMap);
                              }
                              setState(() {});
                            },
                            child: isFavourite
                                ? const Icon(
                                    Ionicons.heart,
                                    color: Colors.red,
                                  )
                                : const Icon(Ionicons.heart_outline),
                          ),
                          TextButton(
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(20),
                            ),
                            onPressed: () => showMenu(playlist),
                            child: const Icon(Icons.more_vert),
                          ),
                          TextButton(
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(20),
                            ),
                            onPressed: () {},
                            child: const Icon(Ionicons.shuffle),
                          ),
                        ],
                        button: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(20),
                          ),
                          onPressed: () async {
                            PlayerManager.addToPlaylistAndPlay(playlist.items);
                          },
                          child: const Icon(Icons.play_arrow),
                        ),
                      ),
                      floating: true,
                      pinned: true,
                    ),
                  ];
                },
                body: PlaylistList(playlist: playlist.items),
              );
            } else {
              return Column(
                children: [
                  Icon(Icons.error, size: size * 1.5),
                  const SizedBox(height: 20.0),
                  Text(
                    'Error Loading Playlist',
                    style: TextStyle(fontSize: size),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    PlayerManager.homePage = true;
    Future.delayed(const Duration(milliseconds: 50),
        () => PlayerManager.navbarHeight.value = kBottomNavigationBarHeight);
    super.dispose();
  }
}
