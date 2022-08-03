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
            ['musicThumbnailRenderer']['thumbnail']['thumbnails'][0]['url'],
        title = json['musicTwoRowItemRenderer']['title']['runs'][0]['text'],
        subtitle = (json['musicTwoRowItemRenderer']['subtitle']['runs'] as List)
            .map((e) => e['text'])
            .join(),
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
