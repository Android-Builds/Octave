import 'package:beats/utils/utility.dart';

class TrendingSong {
  final String videoId;
  final String thumbnail;
  final String title;
  final String subtitle;
  final String playlistId;

  TrendingSong(
      this.videoId, this.thumbnail, this.title, this.subtitle, this.playlistId);

  TrendingSong.fromJson(Map<dynamic, dynamic> json)
      : videoId = json['musicResponsiveListItemRenderer']?['playlistItemData']
                ['videoId'] ??
            json['musicTwoRowItemRenderer']['navigationEndpoint']
                ['watchEndpoint']['videoId'],
        thumbnail = json['musicResponsiveListItemRenderer']?['thumbnail']
                    ['musicThumbnailRenderer']['thumbnail']['thumbnails']
                .last['url']
                .replaceAllMapped(
                    RegExp(r'w[0-9]{3,4}-h[0-9]{3,4}'), (match) => 'w300-h300')
                .replaceAll('hqdefault', 'maxresdefault') ??
            json['musicTwoRowItemRenderer']['thumbnailRenderer']
                    ['musicThumbnailRenderer']['thumbnail']['thumbnails']
                .last['url']
                .replaceAllMapped(
                    RegExp(r'w[0-9]{3,4}-h[0-9]{3,4}'), (match) => 'w300-h300')
                .replaceAll('hqdefault', 'maxresdefault'),
        title = mapToText(json['musicResponsiveListItemRenderer']
                    ?['flexColumns'][0]
                ['musicResponsiveListItemFlexColumnRenderer']['text'] ??
            json['musicTwoRowItemRenderer']['title']),
        subtitle = mapToText(json['musicResponsiveListItemRenderer']
                    ?['flexColumns'][1]
                ['musicResponsiveListItemFlexColumnRenderer']['text'] ??
            json['musicTwoRowItemRenderer']['subtitle']),
        playlistId = json['musicResponsiveListItemRenderer']?['flexColumns'][0]
                        ['musicResponsiveListItemFlexColumnRenderer']['text']
                    ['runs'][0]['navigationEndpoint']['watchEndpoint']
                ['playlistId'] ??
            json['musicTwoRowItemRenderer']['navigationEndpoint']
                ['watchEndpoint']['playlistId'];

  static List<TrendingSong> getTrendingSongsList(List<dynamic> contentsMap) {
    List<TrendingSong> trendingSongs = List<TrendingSong>.from(
        contentsMap.map((i) => TrendingSong.fromJson(i)));

    return trendingSongs;
  }
}
