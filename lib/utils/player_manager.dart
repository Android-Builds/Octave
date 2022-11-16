// ignore_for_file: depend_on_referenced_packages

import 'package:audio_service/audio_service.dart';
import 'package:octave/api/youtube_api.dart';
import 'package:flutter/material.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../widgets/player/common.dart';
import '../services/audio_service.dart';
import 'package:rxdart/rxdart.dart';

import 'package:miniplayer/miniplayer.dart' as mp;

import 'db_helper.dart';

class PlayerManager {
  static late Size size;
  static bool homePage = true;
  static final MiniplayerController _miniplayerController =
      MiniplayerController();

  static String countryCode = 'ZZ';

  static final PanelController _panelController = PanelController();

  static ValueNotifier<int> navbarIndex = ValueNotifier(0);

  static final ValueNotifier<bool> _lyricsAvailable = ValueNotifier(true);

  static final ValueNotifier<double> _playerExpandProgress =
      ValueNotifier(kBottomNavigationBarHeight * 1.2);

  static ValueNotifier<double> navbarHeight =
      ValueNotifier(kBottomNavigationBarHeight);

  static late AudioPlayerHandler _audioHandler;

  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  static MiniplayerController get miniplayerController => _miniplayerController;

  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  static ValueNotifier<double> get playerExpandProgress =>
      _playerExpandProgress;

  static AudioPlayerHandler get audioHandler => _audioHandler;

  static PanelController get panelController => _panelController;

  static ValueNotifier<bool> get lyricsAvailable => _lyricsAvailable;

  static Stream<Duration> get _bufferedPositionStream =>
      PlayerManager.audioHandler.playbackState
          .map((state) => state.bufferedPosition)
          .distinct();

  static Stream<Duration?> get _durationStream =>
      PlayerManager.audioHandler.mediaItem
          .map((item) => item?.duration)
          .distinct();

  static Stream<PositionData> get positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        AudioService.position,
        _bufferedPositionStream,
        _durationStream,
        (position, bufferedPosition, duration) => PositionData(
          position,
          bufferedPosition,
          duration ?? Duration.zero,
        ),
      );

  static Stream get multiStream =>
      Rx.combineLatest3<PlaybackState, MediaItem?, PositionData, List>(
        _audioHandler.playbackState,
        _audioHandler.mediaItem,
        positionDataStream,
        (playbackState, mediaItem, positionData) =>
            [playbackState, mediaItem, positionData],
      );

  static double valueFromPercentageInRange(
      {required final double min, max, percentage}) {
    return percentage * (max - min) + min;
  }

  static double percentageFromValueInRange(
      {required final double min, max, value}) {
    return (value - min) / (max - min);
  }

  static Future<void> initPlayer() async {
    _audioHandler = await AudioService.init(
      builder: () => AudioPlayerHandlerImpl(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'sudo.dev.octave.channel.audio',
        androidNotificationChannelName: 'Audio playback',
        androidNotificationOngoing: true,
      ),
    );
  }

  static Future<void> playMusic(
    String musicId,
    String playlistId,
    String playlistName,
  ) async {
    int index = 0;
    if (_audioHandler.queue.value.isNotEmpty &&
        _audioHandler.mediaItem.value!.id == musicId) {
      _miniplayerController.animateToHeight(state: mp.PanelState.MAX);
    } else {
      MediaItem song =
          await YtmApi.getPlayerDetails(playlistId, musicId, playlistName);
      List<MediaItem> items = [];
      if (playlistId.isNotEmpty) {
        items = await YtmApi.getQueue(playlistId);
        index = items.indexWhere((element) => element.id == song.id);
        if (index == -1) {
          items.insert(0, song);
          index = 0;
        }
      } else {
        items.add(song);
      }
      await addToPlaylistAndPlay(items, index);
      //panelController.open();
    }
  }

  static _addToHistory(MediaItem item) {
    Map songHistoryMap = {};
    songHistoryMap['id'] = item.id;
    songHistoryMap['title'] = item.title;
    songHistoryMap['album'] = item.album;
    songHistoryMap['thumbnail'] = item.artUri.toString();
    songHistoryMap['time'] = DateTime.now();
    checkAndAddPlayHistory(songHistoryMap);
  }

  static Future<void> addToPlaylistAndPlay(List<MediaItem> items,
      [int? index]) async {
    _addToHistory(items[index ?? 0]);
    await _audioHandler.updateQueue(items);
    await _audioHandler.skipToQueueItem(index ?? 0);
    await _audioHandler.play();
    //_miniplayerController.animateToHeight(state: mp.PanelState.MAX);
  }

  static String parsedDuration(Duration duration) {
    return RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
            .firstMatch("$duration")
            ?.group(1) ??
        '$duration';
  }

  static Future getSearchSuggestions(String searchQuery) async {
    if (searchQuery.contains('youtube')) {
      RegExp typeExp = RegExp(r'.com\/\w*');
      String type = typeExp
          .allMatches(searchQuery)
          .map((e) => e.group(0))
          .toList()
          .first!
          .replaceAll('.com/', '');

      SearchType searchType = SearchType.songs;

      switch (type) {
        case 'watch':
          searchType = SearchType.songs;
          break;
        case 'playlist':
          searchType = SearchType.playlists;
          break;
        case 'channel':
          searchType = SearchType.artists;
          break;
        default:
      }
      return YtmApi.getSearchResultFromLink(searchQuery, searchType);

      // switch (type) {
      //   case 'playlist':
      //     RegExp idExp = RegExp(r'list=\w*');
      //     String id = idExp
      //         .allMatches(searchQuery)
      //         .map((e) => e.group(0))
      //         .toList()
      //         .first!
      //         .replaceAll('list=', '');
      //     print(id);
      //     YoutubeMusicApi.resolveUrl(searchQuery);
      //     return YtmApi.getSearchResultFromLink(id);
      // }
    } else {
      return YtmApi.getSearchSuggestions(searchQuery);
    }
  }
}
