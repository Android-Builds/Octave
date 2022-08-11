import 'dart:convert';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:beats/classes/artist.dart';
import 'package:beats/classes/playlist.dart';
import 'package:beats/classes/search_result.dart';
import 'package:beats/classes/trending_playlists.dart';
import 'package:http/http.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../classes/trending_songs.dart';

enum ContentType {
  playlist,
  songlist,
}

enum SearchType {
  songs,
  videos,
  artists,
  albums,
  playlists,
}

class YoutubeMusicApi {
  static final Map _body = {
    'context': {
      'capabilities': {},
      'client': {
        'clientName': 'WEB_REMIX',
        'clientVersion': '1.20220613.01.00',
      },
    },
    'browseId': '',
  };

  static final Map context = {
    'capabilities': {},
    'client': {
      'clientName': 'WEB_REMIX',
      'clientVersion': '1.20220613.01.00',
    },
  };

  static late Map responseMap;
  static late String tracking;
  static late Map contentsMap;
  static late String continuation;
  static String visitorData = '';

  static final YoutubeExplode _youtubeExplode = YoutubeExplode();

  static String listToText(List<dynamic> textList) {
    return textList.map((e) => e['text']).toList().join();
  }

  /*
   * Playlist Section 
   */

  static Future<Playlist> getPlaylistInfo(String playlistId) async {
    return await _youtubeExplode.playlists.get(playlistId.replaceAll('VL', ''));
  }

  static Stream<Video> getPlayListSongs(String playlistId) {
    return _youtubeExplode.playlists.getVideos(playlistId.replaceAll('VL', ''));
  }

  static Future<SongPlayList> getPlaylist(String playlistId) async {
    Map<dynamic, dynamic> responseMap = await browse(playlistId);
    String title = (responseMap['header']['musicDetailHeaderRenderer']['title']
            ['runs'] as List)
        .map((e) => e['text'])
        .toList()
        .join();
    String thumbnail = responseMap['header']['musicDetailHeaderRenderer']
                ['thumbnail']['croppedSquareThumbnailRenderer']['thumbnail']
            ['thumbnails']
        .last['url'];
    String subtitle =
        '${listToText(responseMap['header']['musicDetailHeaderRenderer']['subtitle']['runs'])}\n${listToText(responseMap['header']['musicDetailHeaderRenderer']['secondSubtitle']['runs'])}';

    List contents = responseMap['contents']['singleColumnBrowseResultsRenderer']
            ['tabs'][0]['tabRenderer']['content']['sectionListRenderer']
        ['contents'][0]['musicPlaylistShelfRenderer']['contents'];

    List<MediaItem> items = [];

    for (var content in contents) {
      content = content['musicResponsiveListItemRenderer'];
      List<String> durationText = listToText(content['fixedColumns'][0]
              ['musicResponsiveListItemFixedColumnRenderer']['text']['runs'])
          .split(':');
      items.add(
        MediaItem(
          id: content['playlistItemData']['videoId'],
          title: listToText(content['flexColumns'][0]
              ['musicResponsiveListItemFlexColumnRenderer']['text']['runs']),
          artist: listToText(content['flexColumns'][1]
              ['musicResponsiveListItemFlexColumnRenderer']['text']['runs']),
          duration: Duration(
            minutes: int.parse(durationText[0]),
            seconds: int.parse(durationText[1]),
          ),
          artUri: Uri.parse(content['thumbnail']['musicThumbnailRenderer']
                  ['thumbnail']['thumbnails']
              .last['url']),
          album: title,
          extras: {
            'playlistId': playlistId.replaceAll('VL', ''),
            'playlist': title,
          },
        ),
      );
    }

    return SongPlayList(title, subtitle, thumbnail, items);
  }

  /*
   * Songs Section 
   */

  static Future<Stream<List<int>>> getSongStream(String musicId) async {
    StreamInfo streamInfo =
        (await _youtubeExplode.videos.streamsClient.getManifest(musicId))
            .audioOnly
            .withHighestBitrate();

    Stream<List<int>> stream =
        _youtubeExplode.videos.streamsClient.get(streamInfo);

    return stream;
  }

  static Future getChannelDetails(String channelId) async {
    getArtist(channelId);
    ChannelAbout about = await _youtubeExplode.channels.getAboutPage(channelId);
    Channel channel = await _youtubeExplode.channels.get(channelId);
    Stream<Video> vids = _youtubeExplode.channels.getUploads(channelId);
    return [channel, about, vids];
  }

  static List<Map<String, Object>> parsePlaylistData(Map contentsMap) {
    List<TrendingPlaylists> trendingPlaylists = [];
    List<TrendingSong> trendingSongs = [];
    String header = '';
    Map<String, Object> playlistMap = {};
    Map<String, Object> songlistMap = {};

    for (var content in (contentsMap['contents'] as List)) {
      if ((content.values.first as Map).containsKey('contents')) {
        header = content.values.first['header']
                ['musicCarouselShelfBasicHeaderRenderer']['title']['runs'][0]
            ['text'];
        switch (content.values.first['contents'][0].keys.first) {
          case 'musicTwoRowItemRenderer': //playlist
            //print();
            trendingPlaylists = TrendingPlaylists.getTrendingPlaylists(
                content.values.first['contents']);
            playlistMap = {
              'title': header,
              'list': trendingPlaylists,
              'type': ContentType.playlist
            };
            break;
          case 'musicResponsiveListItemRenderer': //songlist
            // print(content.values.first['header']['']);
            trendingSongs = TrendingSong.getTrendingSongsList(
                content.values.first['contents']);
            songlistMap = {
              'title': header,
              'list': trendingSongs,
              'type': ContentType.songlist
            };
            break;
          default:
            log('Can\'t parse the item');
        }
      }
    }
    return [songlistMap, playlistMap];
  }

  static Future<Map> getResponse(Uri link, Object body) async {
    final Response response = await post(
      link,
      headers: {
        'user-agent':
            'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)',
        'origin': 'https://music.youtube.com',
      },
      body: json.encode(body),
    );
    return jsonDecode(response.body);
  }

  static Future<List<Map<String, Object>>> getContinuationData() async {
    Uri nextLink = Uri.https('music.youtube.com', 'youtubei/v1/browse', {
      'ctoken': continuation,
      'continuation': continuation,
      'type': 'next',
      'itct': tracking,
      'key': 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30',
      'prettyPrint': 'false'
    });

    if (!_body.containsKey('visitorData')) {
      _body['context']!['client']['visitorData'] = visitorData;
    }

    List<Map<String, Object>> parsedData = [];

    responseMap = await getResponse(nextLink, _body);
    if (responseMap['continuationContents'] != null &&
        (responseMap['continuationContents'] as Map)
            .containsKey('sectionListContinuation')) {
      contentsMap =
          responseMap['continuationContents']['sectionListContinuation'];
      tracking = contentsMap['trackingParams'];
      if (contentsMap.containsKey('continuations')) {
        continuation = contentsMap['continuations'][0]['nextContinuationData']
            ['continuation'];
        parsedData.addAll(parsePlaylistData(contentsMap));
      }
    }

    return parsedData;
  }

  static Future getHomePage() async {
    final Uri link = Uri.https('music.youtube.com', '/youtubei/v1/browse', {
      'key': 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30',
      'prettyPrint': 'false',
    });

    _body['browseId'] = 'FEmusic_home';
    responseMap = await getResponse(link, _body);
    tracking = responseMap['trackingParams'];
    if ((responseMap['responseContext'] as Map).containsKey('visitorData')) {
      visitorData = responseMap['responseContext']['visitorData'];
      context['client']['visitorData'] = visitorData;
    }
    contentsMap = responseMap['contents']['singleColumnBrowseResultsRenderer']
        ['tabs'][0]['tabRenderer']['content']['sectionListRenderer'];
    continuation =
        contentsMap['continuations'][0]['nextContinuationData']['continuation'];

    List<Map<String, Object>> data = parsePlaylistData(contentsMap);
    List<Map<String, Object>> parsedData = [];
    parsedData.addAll(data);

    while ((data = await getContinuationData()).isNotEmpty) {
      parsedData.addAll(data);
    }

    parsedData.removeWhere((element) => element.isEmpty);
    parsedData.insert(1, parsedData.removeAt(0));
    return parsedData;
  }

  static Future<List<dynamic>> getMoodsAndGenres() async {
    Map responseMap = await browse('FEmusic_moods_and_genres');
    List contents = responseMap['contents']['singleColumnBrowseResultsRenderer']
            ['tabs'][0]['tabRenderer']['content']['sectionListRenderer']
        ['contents'];
    List moodsOrGenres = [];
    for (var element in contents) {
      List items = [];
      for (var item in (element['gridRenderer']['items'] as List)) {
        items.add({
          'title': listToText(
              item['musicNavigationButtonRenderer']['buttonText']['runs']),
          'color': item['musicNavigationButtonRenderer']['solid']
              ['leftStripeColor'],
          'browswId': item['musicNavigationButtonRenderer']['clickCommand']
              ['browseEndpoint']['browseId'],
          'params': item['musicNavigationButtonRenderer']['clickCommand']
              ['browseEndpoint']['params'],
        });
      }
      moodsOrGenres.add({
        'title': listToText(element['gridRenderer']['header']
            ['gridHeaderRenderer']['title']['runs']),
        'items': items,
      });
    }
    return moodsOrGenres;
  }

  /*
  Search API
  */
  static Future getSearchSuggestions(String searchQuery) async {
    Uri searchSuggestionLink = Uri.https(
        'music.youtube.com', '/youtubei/v1/music/get_search_suggestions', {
      'key': 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30',
      'prettyPrint': 'false',
    });

    Map body = {
      'context': context,
      'input': searchQuery,
    };

    Map responseMap = await getResponse(searchSuggestionLink, body);

    List contents = responseMap['contents'][0]
        ['searchSuggestionsSectionRenderer']['contents'];

    contents = contents
        .map((e) =>
            (e['searchSuggestionRenderer']['suggestion']['runs'] as List)
                .map((e) => e['text'])
                .toList())
        .toList();
    return contents;
  }

  static List<SearchResult> getSearchedContents(
    Map songContents,
    SearchType? searchType,
  ) {
    songContents = songContents['musicShelfRenderer'];

    List<SearchResult> searchContents = [];

    for (var element in (songContents['contents'] as List)) {
      element = element['musicResponsiveListItemRenderer'];
      Map flexColumnOneMap = element['flexColumns'][0]
              ['musicResponsiveListItemFlexColumnRenderer']['text']['runs']
          .first;
      String title = flexColumnOneMap['text'];
      List subtitleTexts = element['flexColumns'][1]
          ['musicResponsiveListItemFlexColumnRenderer']['text']['runs'];
      String entityType = element['flexColumns'][1]
              ['musicResponsiveListItemFlexColumnRenderer']['text']['runs'][0]
          ['text'];
      String subtitle = subtitleTexts
          .map((e) => e['text'])
          .join()
          .replaceAllMapped(
              RegExp(r'([1.0-9.0]*[A-Z]\sviews\s.\s)'), (match) => '');
      String imageUrl = element['thumbnail']['musicThumbnailRenderer']
              ['thumbnail']['thumbnails']
          .last['url'];
      String entityId = element['playlistItemData']?['videoId'] ??
          element['overlay']?['musicItemThumbnailOverlayRenderer']['content']
                  ['musicPlayButtonRenderer']['playNavigationEndpoint']
              ?['watchPlaylistEndpoint']['playlistId'] ??
          element['navigationEndpoint']['browseEndpoint']?['browseId'];
      String playlistId = flexColumnOneMap['navigationEndpoint']
              ?['watchEndpoint']['playlistId'] ??
          "";

      searchContents.add(SearchResult(
        title,
        subtitle,
        imageUrl,
        entityId,
        playlistId,
        searchType ??
            SearchType.values
                .where((element) =>
                    element.name.contains(entityType.toLowerCase()))
                .first,
      ));
    }

    return searchContents;
  }

  static Future<List> getDataFromMap(
    Uri searchLink,
    Map body,
    SearchType? searchType,
  ) async {
    Map searchReasultMap = (await getResponse(searchLink, body))['contents']
            ['tabbedSearchResultsRenderer']['tabs'][0]['tabRenderer']['content']
        ['sectionListRenderer'];

    List contents = searchReasultMap['contents'];

    if ((contents[0] as Map).containsKey('itemSectionRenderer')) {
      contents.removeAt(0);
    }

    if (contents.length == 1) {
      return getSearchedContents(
        contents[0],
        searchType!,
      );
    } else {
      return contents;
    }
  }

  static Future getSearchResults(String searchQuery,
      [SearchType? searchType]) async {
    Uri searchLink = Uri.https('music.youtube.com', '/youtubei/v1/search', {
      'key': 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30',
      'prettyPrint': 'false',
    });

    Map body = {
      'context': context,
      'query': searchQuery,
    };

    switch (searchType) {
      case SearchType.songs:
        body['params'] = 'EgWKAQIIAWoKEAMQBBAFEAkQCg%3D%3D';
        break;
      case SearchType.videos:
        body['params'] = 'EgWKAQIQAWoKEAMQBBAFEAkQCg%3D%3D';
        break;
      case SearchType.artists:
        body['params'] = 'EgWKAQIgAWoKEAMQBBAFEAkQCg%3D%3D';
        break;
      case SearchType.albums:
        body['params'] = 'EgWKAQIYAWoKEAMQBBAFEAkQCg%3D%3D';
        break;
      case SearchType.playlists:
        body['params'] = 'EgeKAQQoAEABagoQAxAEEAUQCRAK';
        break;
      default:
    }

    List searchResults = [];
    List contents = await getDataFromMap(searchLink, body, searchType);

    if (searchType == null) {
      for (var element in contents) {
        List searchContents = [];
        String category =
            element['musicShelfRenderer']['title']['runs'].first['text'];
        searchContents = getSearchedContents(
            element,
            category == 'Top result'
                ? null
                : SearchType.values
                    .where((SearchType element) =>
                        element.name == category.toLowerCase().split(' ').last)
                    .first);
        searchResults.add({'type': category, 'data': searchContents});
      }
    } else {
      searchResults = await getDataFromMap(
        searchLink,
        body,
        searchType,
      );
    }

    return searchResults;
  }

  static Future<Map<dynamic, dynamic>> browse(String browseId,
      [String? params]) async {
    Uri browseLink = Uri.https('music.youtube.com', '/youtubei/v1/browse', {
      'key': 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30',
      'prettyPrint': 'false',
    });

    Map body = {
      'context': context,
      'browseId': browseId,
    };

    if (params != null) {
      body['params'] = params;
    }

    Map<dynamic, dynamic> responseMap = await getResponse(browseLink, body);

    return responseMap;
  }

  static Future getPlaylistSongs(String playlistId) async {
    var body = {
      'context': {
        'capabilities': {},
        'client': {
          'clientName': 'WEB_REMIX',
          'clientVersion': '1.20220613.01.00',
        },
      },
      'browseId': 'VL$playlistId',
    };

    final Uri link = Uri.https('music.youtube.com', '/youtubei/v1/playlist', {
      'alt': 'json',
      'key': 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30',
    });

    final Response response = await post(
      link,
      headers: {
        'user-agent':
            'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)',
        'origin': 'https://music.youtube.com',
      },
      body: json.encode(body),
    );

    log(response.body);

    return 1;
  }

  static Future getSongDetails2(String playlistId, String songId) async {
    var body = {
      'context': {
        'capabilities': {},
        'client': {
          'clientName': 'WEB_REMIX',
          'clientVersion': '1.20220613.01.00',
        },
      },
      'playlistId': playlistId,
      'videoId': songId
    };

    final Uri link = Uri.https('music.youtube.com', '/youtubei/v1/browse', {
      'alt': 'json',
      'key': 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30',
    });

    final Response response = await post(
      link,
      headers: {
        'user-agent':
            'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)',
        'origin': 'https://music.youtube.com',
      },
      body: json.encode(body),
    );

    //log(response.body);

    return response;
  }

  ///Get queue from playlist id and song id
  static Future<List<MediaItem>> getQueue(String playlistId) async {
    var body = {
      'context': {
        'capabilities': {},
        'client': {
          'clientName': 'WEB_REMIX',
          'clientVersion': '1.20220613.01.00',
        },
      },
      'playlistId': playlistId,
    };

    final Uri link =
        Uri.https('music.youtube.com', '/youtubei/v1/music/get_queue', {
      'alt': 'json',
      'key': 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30',
      'prettyPrint': 'false',
    });

    List songQueue = (await getResponse(link, body))['queueDatas'];

    List<MediaItem> songs = [];

    for (var song in songQueue) {
      song = song['content']['playlistPanelVideoRenderer'];
      List<String> time = song['lengthText']['runs'][0]['text'].split(':');
      songs.add(
        MediaItem(
          id: song['videoId'],
          title: song['title']['runs'][0]['text'],
          artist: (song['shortBylineText']['runs'] as List)
              .map((e) => e['text'])
              .toList()
              .join(),
          album: (song['longBylineText']['runs'] as List)
              .map((e) => e['text'])
              .toList()
              .join()
              .split('•')[1]
              .trim(),
          duration: Duration(
            minutes: int.parse(time[0]),
            seconds: int.parse(time[1]),
          ),
          artUri: Uri.parse(song['thumbnail']['thumbnails'].last['url']),
        ),
      );
    }

    return songs;
  }

  static Future<MediaItem> getPlayerDetails(
    String playlistId,
    String musicId,
    String playlistName,
  ) async {
    var body = {
      'context': context,
      'playlistId': playlistId,
      'videoId': musicId,
    };

    final Uri link = Uri.https('music.youtube.com', '/youtubei/v1/player', {
      'alt': 'json',
      'key': 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30',
      'prettyPrint': 'false',
    });

    Map responseMap = (await getResponse(link, body))['videoDetails'];

    return MediaItem(
      id: musicId,
      title: responseMap['title'],
      artist: responseMap['author'],
      album: playlistName,
      duration: Duration(
        seconds: int.parse(responseMap['lengthSeconds']),
      ),
      artUri: Uri.parse(responseMap['thumbnail']['thumbnails'].last['url']),
      extras: {
        'playlistId': playlistId,
      },
    );
  }

  static Future getArtist(String browseId) async {
    Map responseMap = await browse(browseId);

    List<SearchResult> songs = [];
    List<dynamic> albums = [];
    String songsBrowseId = "";
    String playlistBrowseId = "";
    String title = responseMap['header']['musicImmersiveHeaderRenderer']
        ['title']['runs'][0]['text'];
    String about = responseMap['header']['musicImmersiveHeaderRenderer']
            ['description']?['runs'][0]['text'] ??
        "";
    String thumbnail = responseMap['header']['musicImmersiveHeaderRenderer']
            ['thumbnail']['musicThumbnailRenderer']['thumbnail']['thumbnails']
        .last['url']
        .replaceAllMapped(
            RegExp(r'w[0-9]{3,4}-h[0-9]{3}'), (match) => 'w900-h900');

    List contents = responseMap['contents']['singleColumnBrowseResultsRenderer']
            ['tabs'][0]['tabRenderer']['content']['sectionListRenderer']
        ['contents'];

    for (var content in contents) {
      if ((content as Map).containsKey('musicShelfRenderer')) {
        songs = getSearchedContents(content, SearchType.songs);
        songsBrowseId = content['musicShelfRenderer']['bottomEndpoint']
                ?['browseEndpoint']['browseId'] ??
            "";
      } else if ((content).containsKey('musicCarouselShelfRenderer')) {
        if (content['musicCarouselShelfRenderer']['header']
                    ['musicCarouselShelfBasicHeaderRenderer']['title']['runs']
                [0]['text'] ==
            "Albums") {
          for (var album
              in (content['musicCarouselShelfRenderer']['contents'] as List)) {
            album = album['musicTwoRowItemRenderer'];
            albums.add({
              'title': album['title']['runs'][0]['text'],
              'subtitle': (album['subtitle']['runs'] as List)
                  .map((e) => e['text'])
                  .toList()
                  .join(),
              'browseId': album['navigationEndpoint']['browseEndpoint']
                  ['browseId'],
              'thumbnail': album['thumbnailRenderer']['musicThumbnailRenderer']
                      ['thumbnail']['thumbnails']
                  .last['url'],
            });
          }
          playlistBrowseId = content['musicCarouselShelfRenderer']['header']
                          ['musicCarouselShelfBasicHeaderRenderer']
                      ['moreContentButton']?['buttonRenderer']
                  ['navigationEndpoint']['browseEndpoint']['browseId'] ??
              "";
        }
      }
    }

    return Artist(title, thumbnail, songs, albums, songsBrowseId,
        playlistBrowseId, about);
  }

  static Future getNext(String playlistId, String musicId) async {
    /*
     * watchEndpointMusicSupportedConfigs: {watchEndpointMusicConfig: {musicVideoType: "MUSIC_VIDEO_TYPE_UGC"}}
     */
    var body = {
      'context': context,
      'playlistId': playlistId,
      'videoId': musicId,
      'isAudioOnly': true,
    };

    final Uri link = Uri.https('music.youtube.com', '/youtubei/v1/next', {
      'alt': 'json',
      'key': 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30',
      'prettyPrint': 'false',
    });

    return (await getResponse(link, body));
  }

  /// Get Lyrics from the song with playlist id and video id
  static Future<String> getLyrics(String playlistId, String musicId) async {
    Map<dynamic, dynamic> responseMap =
        (await getNext(playlistId, musicId))['contents']
                ['singleColumnMusicWatchNextResultsRenderer']['tabbedRenderer']
            ['watchNextTabbedResultsRenderer'];

    String browseId = responseMap['tabs'][1]['tabRenderer']['endpoint']
        ['browseEndpoint']['browseId'];

    String lyrics = (await browse(browseId))['contents']['sectionListRenderer']
                ?['contents']?[0]?['musicDescriptionShelfRenderer']
            ?['description']?['runs']?[0]?['text'] ??
        "";

    return lyrics;
  }

  static Future resolveUrl(String url) async {
    var body = {
      'context': {
        'capabilities': {},
        'client': {
          'clientName': 'WEB_REMIX',
          'clientVersion': '1.20220613.01.00',
        },
      },
      'url': url,
    };

    final Uri link =
        Uri.https('music.youtube.com', '/youtubei/v1/navigation/resolve_url', {
      'alt': 'json',
      'key': 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30',
      'prettyPrint': 'false',
    });

    final Response response = await post(
      link,
      headers: {
        'user-agent':
            'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)',
        'origin': 'https://music.youtube.com',
      },
      body: json.encode(body),
    );

    log(response.body);

    return 1;
  }
}
