// ignore_for_file: depend_on_referenced_packages

import 'package:audio_service/audio_service.dart';
import 'package:beats/api/youtube_api.dart';
import 'package:beats/classes/trending_songs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:miniplayer/miniplayer.dart' as mp;

import '../blocs/task_execution_bloc/task_execution_bloc.dart';
import '../widgets/player/common.dart';
import '../services/audio_service.dart';
import 'package:rxdart/rxdart.dart';

class PlayerManager {
  static late Size size;
  static bool homePage = true;
  static final MiniplayerController _miniplayerController =
      MiniplayerController();

  static final PanelController _panelController = PanelController();

  static ValueNotifier<int> navbarIndex = ValueNotifier(0);

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
        androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
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
    if (_audioHandler.queue.value.isNotEmpty &&
        _audioHandler.mediaItem.value!.id == musicId) {
      _miniplayerController.animateToHeight(state: mp.PanelState.MAX);
    } else {
      MediaItem song = await YoutubeMusicApi.getPlayerDetails(
          playlistId, musicId, playlistName);
      List<MediaItem> items = await YoutubeMusicApi.getQueue(playlistId);
      items.insert(0, song);
      await addToPlaylistAndPlay(items);
      //panelController.open();
    }
  }

  static Future<void> addToPlaylistAndPlay(List<MediaItem> items,
      [int? index]) async {
    await _audioHandler.updateQueue(items);
    await _audioHandler.skipToQueueItem(index ?? 0);
    await _audioHandler.play().then(
          (value) =>
              _miniplayerController.animateToHeight(state: mp.PanelState.MAX),
        );
  }
}
