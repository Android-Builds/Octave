import 'package:beats/api/youtube_api.dart';
import 'package:beats/classes/search_result.dart';
import 'package:collection/collection.dart';

class SpotifySong {
  final String title;
  final String artists;
  final String thumbnail;
  final String previewUrl;
  String youtubeId;

  SpotifySong(this.title, this.artists, this.thumbnail, this.previewUrl,
      this.youtubeId);

  Future<String> spotifyToYoutube(String title, String artists) async {
    String id = '';
    List<SearchResult> youtubeSongs =
        await YoutubeMusicApi.getSearchResults(title, SearchType.songs);
    for (var element in youtubeSongs) {
      if (const ListEquality().equals(
          artists.split(','),
          element.subtitle
              .split('•')[0]
              .split('&')
              .map((e) => e.trim())
              .toList())) {
        id = element.entityId;
        break;
      }
    }
    return id;
  }

  SpotifySong.fromJson(Map json)
      : title = json['track']['name'],
        artists =
            (json['track']['artists'] as List).map((e) => e['name']).join(','),
        thumbnail = json['track']['album']['images'][0]['url'],
        previewUrl = json['track']['preview_url'],
        youtubeId = '';

  static List<SpotifySong> getTopSpotifySongs(List<dynamic> songs) {
    List<SpotifySong> spotifySongs = [];
    for (var element in songs) {
      SpotifySong spotifySong = SpotifySong.fromJson(element);
      spotifySongs.add(spotifySong);
    }
    return spotifySongs;
  }
}
