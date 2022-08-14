import '../api/youtube_api.dart';

class TrendingArtist {
  final String browseId;
  final String thumbnail;
  final String title;
  final String subtitle;

  TrendingArtist(this.browseId, this.thumbnail, this.title, this.subtitle);

  TrendingArtist.fromJson(Map<dynamic, dynamic> json)
      : browseId = json['musicResponsiveListItemRenderer']['navigationEndpoint']
            ['browseEndpoint']['browseId'],
        thumbnail = json['musicResponsiveListItemRenderer']['thumbnail']
                ['musicThumbnailRenderer']['thumbnail']['thumbnails']
            .last['url']
            .replaceAllMapped(
                RegExp(r'w[0-9]{3,4}-h[0-9]{3,4}'), (match) => 'w300-h300')
            .replaceAll('hqdefault', 'maxresdefault'),
        title = YoutubeMusicApi.mapToText(
            json['musicResponsiveListItemRenderer']['flexColumns'][0]
                ['musicResponsiveListItemFlexColumnRenderer']['text']),
        subtitle = YoutubeMusicApi.mapToText(
            json['musicResponsiveListItemRenderer']['flexColumns'][1]
                ['musicResponsiveListItemFlexColumnRenderer']['text']);

  static List<TrendingArtist> getTrendingArtistsList(
      List<dynamic> contentsMap) {
    List<TrendingArtist> trendingSongs = List<TrendingArtist>.from(
        contentsMap.map((i) => TrendingArtist.fromJson(i)));

    return trendingSongs;
  }
}
