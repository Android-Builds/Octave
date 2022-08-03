import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlaylistSearchDelegate extends SearchDelegate<String> {
  final List<Video> playlistSongs;

  PlaylistSearchDelegate({required this.playlistSongs});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Video> songs = playlistSongs
        .where((element) =>
            element.title.toLowerCase().startsWith(query.toLowerCase()))
        .toList();
    return getSongs(songs);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Video> songs = playlistSongs
        .where((element) =>
            element.title.toLowerCase().startsWith(query.toLowerCase()))
        .toList();
    return getSongs(songs);
  }

  getSongs(songs) {
    return query.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: Image.network(
                    songs[index].thumbnails.lowResUrl,
                    height: 50.0,
                    width: 60.0,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  formatSongTitle(songs[index].title),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
                subtitle: Text(
                    '${songs[index].author} \u00B7 ${RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$').firstMatch("${songs[index].duration}")?.group(1)}'),
              );
            },
          )
        : const SizedBox.shrink();
  }

  formatSongTitle(String text) {
    String title = text
        .replaceAll('Video', '')
        .replaceAll('Full ', '')
        .replaceAll('Official ', '')
        .replaceAll('- |', '|')
        .replaceAll('\u2013 |', '|')
        .replaceAll(' |', ', ')
        .replaceAll('@', '')
        .replaceAll('()', '')
        .replaceAll('( )', '')
        .replaceAll('  ', ' ')
        .replaceAllMapped(RegExp(r'[a-z]{0}:.'), (match) => '');

    return title;
  }
}
