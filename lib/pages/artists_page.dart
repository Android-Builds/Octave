import 'package:beats/api/youtube_api.dart';
import 'package:beats/classes/artist.dart';
import 'package:beats/classes/search_result.dart';
import 'package:beats/utils/player_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.launch))],
      ),
      body: FutureBuilder(
        future: YoutubeMusicApi.getArtist(widget.artistId),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            Artist artist = snapshot.data;
            return ListView(
              padding: const EdgeInsets.all(10.0),
              children: [
                Container(
                  height: 200.0,
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
                ListTile(
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
                ),
                albumList(artist.albums),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
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
