import 'dart:convert';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:beats/classes/artist.dart';
import 'package:beats/classes/playlist.dart';
import 'package:beats/classes/search_result.dart';
import 'package:beats/classes/trending_artists.dart';
import 'package:beats/classes/trending_playlists.dart';
import 'package:beats/utils/player_manager.dart';
import 'package:beats/utils/utility.dart';
import 'package:http/http.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../classes/trending_songs.dart';

Future getLocation() async {
  final Response response = await post(
    Uri.http('ip-api.com', 'json'),
  );
  return jsonDecode(response.body)['countryCode'];
}

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
  static late Map responseMap;
  static late String tracking;
  static late Map contentsMap;
  static late String continuation;
  static String visitorData = '';

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

  static final Map _context = {
    'capabilities': {},
    'client': {
      'clientName': 'WEB_REMIX',
      'clientVersion': '1.20220613.01.00',
    },
  };

  static final YoutubeExplode _youtubeExplode = YoutubeExplode();
  /*
   * Playlist Section 
   */

  static Future<SongPlayList> getPlaylist(String playlistId) async {
    Map<dynamic, dynamic> responseMap = await browse(playlistId);
    String title =
        mapToText(responseMap['header']['musicDetailHeaderRenderer']['title']);

    String thumbnail = responseMap['header']['musicDetailHeaderRenderer']
                ['thumbnail']['croppedSquareThumbnailRenderer']['thumbnail']
            ['thumbnails']
        .last['url'];
    String subtitle = mapToText(
        responseMap['header']['musicDetailHeaderRenderer']['subtitle']);

    String secondarySubtitle = mapToText(
        responseMap['header']['musicDetailHeaderRenderer']['secondSubtitle']);

    responseMap = responseMap['contents']['singleColumnBrowseResultsRenderer']
        ['tabs'][0]['tabRenderer']['content']['sectionListRenderer'];

    List contents = responseMap['contents'][0]['musicPlaylistShelfRenderer']
            ?['contents'] ??
        responseMap['contents'][0]['musicShelfRenderer']['contents'];

    if (responseMap.containsKey('continuations')) {
      continuation = responseMap['continuations'][0]['nextContinuationData']
          ['continuation'];

      tracking = responseMap['continuations'][0]['nextContinuationData']
          ['clickTrackingParams'];

      Map continousMap = {};

      while ((continousMap = await getContinuationData(false))
          .containsKey('continuations')) {
        contents.addAll(continousMap['contents']);
        continuation = contentsMap['continuations'][0]['nextContinuationData']
            ['continuation'];
        tracking = contentsMap['continuations']['trackingParams'];
      }
    }

    List<MediaItem> items = [];

    for (var content in contents) {
      content = content['musicResponsiveListItemRenderer'];
      List<String> durationText = mapToText(content['fixedColumns'][0]
              ['musicResponsiveListItemFixedColumnRenderer']['text'])
          .split(':');

      if (content['playlistItemData'] == null) {
        continue;
      } else {
        items.add(
          MediaItem(
            id: content['playlistItemData']['videoId'],
            title: mapToText(content['flexColumns'][0]
                ['musicResponsiveListItemFlexColumnRenderer']['text']),
            artist: mapToText(content['flexColumns'][1]
                ['musicResponsiveListItemFlexColumnRenderer']['text']),
            duration: Duration(
              minutes: int.parse(durationText[0]),
              seconds: int.parse(durationText[1]),
            ),
            artUri: Uri.parse(content['thumbnail']?['musicThumbnailRenderer']
                        ['thumbnail']['thumbnails']
                    .last['url'] ??
                thumbnail),
            album: title,
            extras: {
              'playlistId': playlistId.replaceAll('VL', ''),
              'playlist': title,
            },
          ),
        );
      }
    }
    return SongPlayList(title, subtitle, secondarySubtitle, thumbnail, items);
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

  static List<Map<String, Object>> parseHomePageResponseData(Map contentsMap) {
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

  static Future<dynamic> getContinuationData([bool homepage = true]) async {
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

    Map responseMap = await getResponse(nextLink, _body);
    if (responseMap['continuationContents'] != null) {
      if (!homepage &&
          (responseMap['continuationContents'] as Map)
              .containsKey('musicPlaylistShelfContinuation')) {
        return responseMap['continuationContents']
            ['musicPlaylistShelfContinuation'];
      } else {
        Map contentsMap =
            responseMap['continuationContents']['sectionListContinuation'];
        tracking = contentsMap['trackingParams'];
        if (contentsMap.containsKey('continuations')) {
          continuation = contentsMap['continuations'][0]['nextContinuationData']
              ['continuation'];
          parsedData.addAll(parseHomePageResponseData(contentsMap));
        }
      }
    }

    return homepage ? parsedData : {};
  }

  static Future<List<Map<String, Object>>> getHomePage() async {
    final Uri link = Uri.https('music.youtube.com', '/youtubei/v1/browse', {
      'key': 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30',
      'prettyPrint': 'false',
    });

    _body['browseId'] = 'FEmusic_home';
    responseMap = await getResponse(link, _body);
    tracking = responseMap['trackingParams'];
    if ((responseMap['responseContext'] as Map).containsKey('visitorData')) {
      visitorData = responseMap['responseContext']['visitorData'];
      _context['client']['visitorData'] = visitorData;
    }
    contentsMap = responseMap['contents']['singleColumnBrowseResultsRenderer']
        ['tabs'][0]['tabRenderer']['content']['sectionListRenderer'];
    continuation =
        contentsMap['continuations'][0]['nextContinuationData']['continuation'];

    List<Map<String, Object>> data = parseHomePageResponseData(contentsMap);
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
          'title':
              mapToText(item['musicNavigationButtonRenderer']['buttonText']),
          'color': item['musicNavigationButtonRenderer']['solid']
              ['leftStripeColor'],
          'browseId': item['musicNavigationButtonRenderer']['clickCommand']
              ['browseEndpoint']['browseId'],
          'params': item['musicNavigationButtonRenderer']['clickCommand']
              ['browseEndpoint']['params'],
        });
      }
      moodsOrGenres.add({
        'title': mapToText(
            element['gridRenderer']['header']['gridHeaderRenderer']['title']),
        'items': items,
      });
    }
    return moodsOrGenres;
  }

  static Future<List<dynamic>> getPlaylistFromMoodOrGenre(
      String browseId, String params) async {
    List contents = (await browse(browseId, {'params': params}))['contents']
            ['singleColumnBrowseResultsRenderer']['tabs']
        .first['tabRenderer']['content']['sectionListRenderer']['contents'];
    List items = [];
    for (var content in contents) {
      List playlists = [];
      for (var item in (content['gridRenderer']['items'] as List)) {
        item = item['musicTwoRowItemRenderer'];
        playlists.add({
          'title': mapToText(item['title']),
          'subtitle': mapToText(item['subtitle']),
          'browseId': item['navigationEndpoint']['browseEndpoint']['browseId'],
          'thumbnail': item['thumbnailRenderer']['musicThumbnailRenderer']
                  ['thumbnail']['thumbnails']
              .last['url'],
        });
      }
      items.add({
        'title': mapToText(
            content['gridRenderer']['header']['gridHeaderRenderer']['title']),
        'playlists': playlists,
      });
    }
    return items;
  }

  static Future<List<Map<dynamic, dynamic>>> getTrendingCountries() async {
    Map responseMap =
        await browse('FEmusic_charts', {'params': 'sgYPRkVtdXNpY19leHBsb3Jl'});
    List countries = responseMap['contents']
                ['singleColumnBrowseResultsRenderer']['tabs']
            .first['tabRenderer']['content']['sectionListRenderer']['contents']
            .first['musicShelfRenderer']['subheaders']
            .first['musicSideAlignedItemRenderer']['startItems']
            .first['musicSortFilterButtonRenderer']['menu']
        ['musicMultiSelectMenuRenderer']['options'];
    countries.removeWhere((element) =>
        (element as Map).containsKey('musicMenuItemDividerRenderer'));
    countries = countries.sublist(1);
    List codes =
        responseMap['frameworkUpdates']['entityBatchUpdate']['mutations'];
    codes.removeWhere((code) =>
        !(code['payload'] as Map).containsKey('musicFormBooleanChoice'));

    List<Map<dynamic, dynamic>> countryCodes = [];
    for (var country in countries) {
      country = country['musicMultiSelectMenuItemRenderer'];
      var countryCode = (codes
          .where((code) => code['entityKey'] == country['formItemEntityKey'])
          .first)['payload']['musicFormBooleanChoice']['opaqueToken'];
      countryCodes.add({
        'country': mapToText(country['title']),
        'code': countryCode,
      });
    }

    return countryCodes;
  }

  static Future<List<Map<dynamic, dynamic>>> getTrending(
      String countryCode) async {
    String title = '';
    List<dynamic> items = [];
    List<Map<dynamic, dynamic>> trendingItems = [];

    Map extraParams = {
      'formData': {
        'selectedValues': [countryCode],
      },
      'navigationType': 'BROWSE_NAVIGATION_TYPE_LOAD_IN_PLACE',
      'params': 'sgYPRkVtdXNpY19leHBsb3Jl'
    };
    List trendingContents =
        (await browse('FEmusic_charts', extraParams))['contents']
                ['singleColumnBrowseResultsRenderer']['tabs']
            .first['tabRenderer']['content']['sectionListRenderer']['contents'];
    trendingContents.removeWhere((e) => e.containsKey('musicShelfRenderer'));

    for (var content in trendingContents) {
      items = [];
      title = mapToText(content['musicCarouselShelfRenderer']['header']
          ['musicCarouselShelfBasicHeaderRenderer']['title']);
      if (title.contains('artists')) {
        items = TrendingArtist.getTrendingArtistsList(
            content['musicCarouselShelfRenderer']['contents']);
      } else if (title.contains('songs') ||
          title.contains('videos') ||
          title.toLowerCase().contains('trending')) {
        items = TrendingSong.getTrendingSongsList(
            content['musicCarouselShelfRenderer']['contents']);
      }
      trendingItems.add({
        'title': title,
        'items': items,
      });
    }
    return trendingItems;
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
      'context': _context,
      'input': searchQuery,
    };

    Map responseMap = await getResponse(searchSuggestionLink, body);

    if (!responseMap.containsKey('contents')) return [];

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
          element['navigationEndpoint']['browseEndpoint']?['browseId'] ??
          element['overlay']?['musicItemThumbnailOverlayRenderer']['content']
                  ['musicPlayButtonRenderer']['playNavigationEndpoint']
              ?['watchPlaylistEndpoint']['playlistId'];
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

  static Future<List<dynamic>> getSearchResults(String searchQuery,
      [SearchType? searchType]) async {
    Uri searchLink = Uri.https('music.youtube.com', '/youtubei/v1/search', {
      'key': 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30',
      'prettyPrint': 'false',
    });

    Map body = {
      'context': _context,
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

  static Future getSearchResultFromLink(
      String url, SearchType searchType) async {
    String title = '';
    String subtitle = '';
    String thumbnail = '';
    String browseId = '';

    Map responseMap = await resolveUrl(url);

    //log(responseMap.toString());
    if (searchType == SearchType.songs) {
      browseId = responseMap['endpoint']['watchEndpoint']['videoId'];
      responseMap = await requestPlayerData(browseId);
      log(responseMap['videoDetails'].keys.toString());
      title = responseMap['videoDetails']['title'];
      subtitle = '${responseMap['videoDetails']['author']} '
          '${PlayerManager.parsedDuration(Duration(seconds: int.parse(responseMap['videoDetails']['lengthSeconds'])))}';
      thumbnail =
          responseMap['videoDetails']['thumbnail']['thumbnails'].last['url'];
    } else {
      browseId = responseMap['endpoint']['browseEndpoint']['browseId'];
      responseMap = await browse(browseId);
      //log(responseMap.toString());
      if (searchType == SearchType.playlists) {
        title = mapToText(
            responseMap['header']['musicDetailHeaderRenderer']['title']);
        thumbnail = responseMap['header']['musicDetailHeaderRenderer']
                    ['thumbnail']['croppedSquareThumbnailRenderer']['thumbnail']
                ['thumbnails']
            .last['url'];
        subtitle =
            '${mapToText(responseMap['header']['musicDetailHeaderRenderer']['subtitle'])}\n'
            '${mapToText(responseMap['header']['musicDetailHeaderRenderer']['secondSubtitle'])}';
      } else {
        responseMap = responseMap['header']['musicImmersiveHeaderRenderer'];
        title = mapToText(responseMap['title']);
        subtitle = 'Artist \u2022 '
            '${mapToText(responseMap['subscriptionButton']['subscribeButtonRenderer']['subscriberCountText'])}'
            ' Subscribers';
        thumbnail = responseMap['thumbnail']['musicThumbnailRenderer']
                ['thumbnail']['thumbnails']
            .first['url']
            .replaceAllMapped(
                RegExp(r'w[0-9]{3,4}-h[0-9]{3,4}'), (match) => 'w300-h300');
      }
    }

    return {
      'title': title,
      'subtitle': subtitle,
      'browseId': browseId,
      'thumbnail': thumbnail,
      'searchType': searchType,
    };
  }

  static Future<Map<dynamic, dynamic>> browse(String browseId,
      [Map? extraParams]) async {
    Uri browseLink = Uri.https('music.youtube.com', '/youtubei/v1/browse', {
      'key': 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30',
      'prettyPrint': 'false',
    });

    Map body = {
      'context': _context,
      'browseId': browseId,
    };

    if (extraParams != null) {
      body.addAll(extraParams);
    }

    return await getResponse(browseLink, body);
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
      Iterable menuItems = (song['menu']['menuRenderer']['items'] as List)
          .where((element) => element.containsKey('menuNavigationItemRenderer'))
          .toList()
          .where((element) =>
              mapToText(element['menuNavigationItemRenderer']['text']) ==
              'Go to album');
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
          extras: {
            'playlistId': playlistId,
            'albumId': menuItems.isEmpty
                ? ''
                : menuItems.first['menuNavigationItemRenderer']
                    ['navigationEndpoint']['browseEndpoint']['browseId'],
          },
        ),
      );
    }

    return songs;
  }

  static Future<Map<dynamic, dynamic>> requestPlayerData(
    String musicId,
  ) async {
    var body = {
      'context': _context,
      'videoId': musicId,
    };

    final Uri link = Uri.https('music.youtube.com', '/youtubei/v1/player', {
      'alt': 'json',
      'key': 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30',
      'prettyPrint': 'false',
    });

    return (await getResponse(link, body));
  }

  static Future<MediaItem> getPlayerDetails(
    String playlistId,
    String musicId,
    String playlistName,
  ) async {
    var body = {
      'context': _context,
      'videoId': musicId,
    };

    if (playlistId.isNotEmpty) {
      body['playlistId'] = playlistId;
    }

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
      artUri: Uri.parse(
        responseMap['thumbnail']['thumbnails']
            .last['url']
            .replaceAllMapped(
                RegExp(r'w[0-9]{3,4}-h[0-9]{3,4}'), (match) => 'w900-h900')
            .replaceAll('hqdefault', 'maxresdefault'),
      ),
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
            RegExp(r'w[0-9]{3,4}-h[0-9]{3,4}'), (match) => 'w900-h900');

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
      'context': _context,
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
    Map body = {
      'context': _context,
      'url': url,
    };

    final Uri link =
        Uri.https('music.youtube.com', '/youtubei/v1/navigation/resolve_url', {
      'alt': 'json',
      'key': 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30',
      'prettyPrint': 'false',
    });

    Map responseMap = await getResponse(link, body);

    return responseMap;
  }
}

/*
 * Java like Interface implementation, declutters the original 
 * class mess with some added benifits of a interface.
 */

class YtmApi {
  /// Browse
  static Future<Map<dynamic, dynamic>> browse(String browseId) =>
      YoutubeMusicApi.browse(browseId);

  /// HomePage and Discovery
  static Future<List<Map<String, Object>>> getHomePage() =>
      YoutubeMusicApi.getHomePage();

  static Future<List<dynamic>> getMoodsAndGenres() =>
      YoutubeMusicApi.getMoodsAndGenres();

  static Future<List<dynamic>> getPlaylistFromMoodOrGenre(
          String browseId, String params) =>
      YoutubeMusicApi.getPlaylistFromMoodOrGenre(browseId, params);

  /// Trending
  static Future<List<Map<dynamic, dynamic>>> getTrending(String countryCode) =>
      YoutubeMusicApi.getTrending(countryCode);

  static Future<List<Map<dynamic, dynamic>>> getTrendingCountries() =>
      YoutubeMusicApi.getTrendingCountries();

  /// Searh methods
  static Future<List<dynamic>> getSearchResults(String searchQuery,
          [SearchType? searchType]) =>
      YoutubeMusicApi.getSearchResults(searchQuery);

  static Future getSearchSuggestions(String searchQuery) =>
      YoutubeMusicApi.getSearchSuggestions(searchQuery);

  static Future getSearchResultFromLink(String id, SearchType searchType) =>
      YoutubeMusicApi.getSearchResultFromLink(id, searchType);

  /// Song play related methods
  static Future getArtist(String browseId) =>
      YoutubeMusicApi.getArtist(browseId);

  static Future<MediaItem> getPlayerDetails(
    String playlistId,
    String musicId,
    String playlistName,
  ) =>
      YoutubeMusicApi.getPlayerDetails(playlistId, musicId, playlistName);

  static Future<Stream<List<int>>> getSongStream(String musicId) =>
      YoutubeMusicApi.getSongStream(musicId);

  static Future<List<MediaItem>> getQueue(String playlistId) =>
      YoutubeMusicApi.getQueue(playlistId);

  static Future<SongPlayList> getPlaylist(String playlistId) =>
      YoutubeMusicApi.getPlaylist(playlistId);

  static Future<String> getLyrics(String playlistId, String musicId) =>
      YoutubeMusicApi.getLyrics(playlistId, musicId);
}
