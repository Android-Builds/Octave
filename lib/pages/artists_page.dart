import 'package:octave/api/youtube_api.dart';
import 'package:octave/blocs/api_call_bloc/api_call_bloc.dart';
import 'package:octave/classes/artist.dart';
import 'package:octave/classes/search_result.dart';
import 'package:octave/utils/player_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArtistsPage extends StatefulWidget {
  const ArtistsPage({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.artistId,
  }) : super(key: key);

  final String imageUrl;
  final String title;
  final String artistId;

  @override
  State<ArtistsPage> createState() => _ArtistsPageState();
}

class _ArtistsPageState extends State<ArtistsPage> {
  bool isExpanded = false;

  final ApiCallBloc bloc = ApiCallBloc();

  @override
  Widget build(BuildContext context) {
    final size = PlayerManager.size.width * 0.05;
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.launch))],
      ),
      body: BlocBuilder<ApiCallBloc, ApiCallBlocState>(
        bloc: bloc,
        builder: (context, state) {
          if (state is ApiCallBlocInitial) {
            bloc.add(FetchApiWithOneParams(
              YtmApi.getArtist,
              widget.artistId,
            ));
            return const Center(child: CircularProgressIndicator());
          } else if (state is ApiCallBlocLaoding) {
            return SizedBox(
              height: PlayerManager.size.height * 0.8,
              child: const Center(child: CircularProgressIndicator()),
            );
          } else if (state is ApiCallBlocFinal) {
            Artist artist = state.data;
            return ListView(
              padding: const EdgeInsets.all(10.0),
              children: [
                Container(
                  height: PlayerManager.size.width * 0.4,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: CachedNetworkImageProvider(
                        artist.thumbnail,
                      ))),
                ),
                const SizedBox(height: 10.0),
                Text(
                  artist.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: PlayerManager.size.width * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  child: InkWell(
                    onTap: artist.about.isNotEmpty
                        ? () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          }
                        : null,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: !isExpanded
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Description'),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: artist.about.isNotEmpty
                                        ? null
                                        : Colors.grey,
                                  ),
                                ],
                              )
                            : Text(
                                artist.about,
                                textAlign: TextAlign.justify,
                              ),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  title: Text(
                    'Songs',
                    style: TextStyle(
                      fontSize: PlayerManager.size.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: artist.songsBrowseId.isNotEmpty
                      ? TextButton(
                          child: const Text('More'),
                          onPressed: () {},
                        )
                      : null,
                ),
                videoList(artist.songs),
                artist.albums.isNotEmpty
                    ? ListTile(
                        title: Text(
                          'Albums',
                          style: TextStyle(
                            fontSize: PlayerManager.size.width * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: artist.playlistBrowseId.isNotEmpty
                            ? TextButton(
                                child: const Text('More'),
                                onPressed: () {},
                              )
                            : null,
                      )
                    : const SizedBox.shrink(),
                artist.albums.isNotEmpty
                    ? albumList(artist.albums)
                    : const SizedBox.shrink(),
              ],
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
    );
  }

  Widget videoList(List<SearchResult> songs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: songs.length,
      itemBuilder: (context, index) => ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(5.0),
          child: CachedNetworkImage(
            imageUrl: songs[index].thumbnail,
            height: PlayerManager.size.width * 0.12,
            width: PlayerManager.size.width * 0.12,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(songs[index].title),
        subtitle: Text(songs[index].subtitle),
      ),
    );
  }

  Widget albumList(List<dynamic> albums) {
    return SizedBox(
      height: PlayerManager.size.height * 0.28,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: albums.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            width: PlayerManager.size.width * 0.35,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: CachedNetworkImage(
                    height: PlayerManager.size.width * 0.35,
                    width: PlayerManager.size.width * 0.35,
                    imageUrl: albums[index]['thumbnail'],
                  ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  albums[index]['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: PlayerManager.size.width * 0.035,
                  ),
                ),
                Text(
                  albums[index]['subtitle'],
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
