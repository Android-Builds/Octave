import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:beats/utils/utility.dart';

class LocalPlaylist {
  final String title;
  final List<MediaItem> songs;

  LocalPlaylist({required this.title, required this.songs});

  Map<String, dynamic> toJson() => {
        'title': title,
        'items': mediaItemToMapList(songs),
      };

  LocalPlaylist.fromJson(Map<dynamic, dynamic> json)
      : title = json['title'],
        songs = (json['items'] as List).map((song) {
          return MediaItem(
            id: song['id'],
            title: song['title'],
            album: song['album'],
            artist: song['artist'],
            artUri: Uri.parse(song['artUri']),
            duration: parseTime(song['duration']),
            extras: jsonDecode(jsonEncode(song['extras'])),
          );
        }).toList();

  List<Map<String, dynamic>> mediaItemToMapList(List<MediaItem> songs) {
    List<Map<String, dynamic>> mediaItems = [];
    for (var element in songs) {
      mediaItems.add({
        'id': element.id,
        'title': element.title,
        'album': element.album,
        'artist': element.artist,
        'artUri': element.artUri.toString(),
        'duration': element.duration.toString(),
        'extras': element.extras,
      });
    }
    return mediaItems;
  }

  List<MediaItem> stringToMediaItemList(List<dynamic> songs) {
    List<MediaItem> mediaItems = [];
    for (var song in songs) {
      MediaItem(
        id: song['id'],
        title: song['title'],
        album: song['album'],
        artist: song['artist'],
        artUri: song['artUri'],
        duration: parseTime(song['duration']),
        extras: song['extras'],
      );
    }
    return mediaItems;
  }
}
