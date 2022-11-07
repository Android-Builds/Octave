import 'package:octave/classes/search_result.dart';

class Artist {
  final String title;
  final String thumbnail;
  final List<SearchResult> songs;
  final List<dynamic> albums;
  final String songsBrowseId;
  final String playlistBrowseId;
  final String about;

  Artist(
    this.title,
    this.thumbnail,
    this.songs,
    this.albums,
    this.songsBrowseId,
    this.playlistBrowseId,
    this.about,
  );
}
