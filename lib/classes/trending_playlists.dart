import 'package:beats/api/youtube_api.dart';

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
        title =
            YoutubeMusicApi.mapToText(json['musicTwoRowItemRenderer']['title']),
        subtitle = YoutubeMusicApi.mapToText(
            json['musicTwoRowItemRenderer']['subtitle']),
        playlistId = json['musicTwoRowItemRenderer']['navigationEndpoint']
                ['browseEndpoint']?['browseId'] ??
            json['musicTwoRowItemRenderer']['navigationEndpoint']
                    ['watchEndpoint']['playlistId']
                .toString()
                .substring(2);

  static List<TrendingPlaylists> getTrendingPlaylists(
      List<dynamic> contentsMap) {
    List<TrendingPlaylists> trendingPlaylists = List<TrendingPlaylists>.from(
        contentsMap.map((i) => TrendingPlaylists.fromJson(i)));

    return trendingPlaylists;
  }
}
