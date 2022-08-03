import 'dart:developer';

class TrendingSong {
  final String videoId;
  final String thumbnail;
  final String title;
  final String subtitle;
  final String playlistId;

  TrendingSong(
      this.videoId, this.thumbnail, this.title, this.subtitle, this.playlistId);

  TrendingSong.fromJson(Map<dynamic, dynamic> json)
      : videoId = json['musicResponsiveListItemRenderer']['playlistItemData']
            ['videoId'],
        thumbnail = json['musicResponsiveListItemRenderer']['thumbnail']
            ['musicThumbnailRenderer']['thumbnail']['thumbnails'][0]['url'],
        title = json['musicResponsiveListItemRenderer']['flexColumns'][0]
                ['musicResponsiveListItemFlexColumnRenderer']['text']['runs'][0]
            ['text'],
        subtitle = json['musicResponsiveListItemRenderer']['flexColumns'][1]
                ['musicResponsiveListItemFlexColumnRenderer']['text']['runs'][0]
            ['text'],
        playlistId = json['musicResponsiveListItemRenderer']['flexColumns'][0]
                ['musicResponsiveListItemFlexColumnRenderer']['text']['runs'][0]
            ['navigationEndpoint']['watchEndpoint']['playlistId'];

  static List<TrendingSong> getTrendingSongsList(List<dynamic> contentsMap) {
    //log(contentsMap.toString());
    List<TrendingSong> trendingSongs = List<TrendingSong>.from(
        contentsMap.map((i) => TrendingSong.fromJson(i)));

    return trendingSongs;
  }
}
