import 'package:octave/utils/utility.dart';

class TrendingPlaylists {
  final String thumbnail;
  final String title;
  final String subtitle;
  final String playlistId;

  TrendingPlaylists(
    this.thumbnail,
    this.title,
    this.subtitle,
    this.playlistId,
  );

  TrendingPlaylists.fromJson(Map<dynamic, dynamic> json)
      : thumbnail = json['musicTwoRowItemRenderer']['thumbnailRenderer']
                ['musicThumbnailRenderer']['thumbnail']['thumbnails']
            .last['url']
            .replaceAllMapped(
                RegExp(r'w[0-9]{3,4}-h[0-9]{3,4}'), (match) => 'w300-h300')
            .replaceAll('hqdefault', 'maxresdefault'),
        title = mapToText(json['musicTwoRowItemRenderer']['title']),
        subtitle = mapToText(json['musicTwoRowItemRenderer']['subtitle']),
        playlistId = json['musicTwoRowItemRenderer']['navigationEndpoint']
                ['browseEndpoint']?['browseId'] ??
            json['musicTwoRowItemRenderer']['navigationEndpoint']
                    ['watchEndpoint']['playlistId']
                ?.toString()
                .substring(2) ??
            json['musicTwoRowItemRenderer']['menu']['menuRenderer']['items']
                        .first['menuNavigationItemRenderer']
                    ['navigationEndpoint']['watchEndpoint']['playlistId'] +
                ':' +
                json['musicTwoRowItemRenderer']['menu']['menuRenderer']['items']
                        .first['menuNavigationItemRenderer']
                    ['navigationEndpoint']['watchEndpoint']['videoId'];

  static List<TrendingPlaylists> getTrendingPlaylists(
      List<dynamic> contentsMap) {
    List<TrendingPlaylists> trendingPlaylists = List<TrendingPlaylists>.from(
        contentsMap.map((json) => TrendingPlaylists.fromJson(json)));

    return trendingPlaylists;
  }
}
