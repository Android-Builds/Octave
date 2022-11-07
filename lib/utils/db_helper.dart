library dbhelper;

import 'package:octave/classes/local_playlist.dart';
import 'package:octave/classes/playlist.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

final _favouritePlaylists = Hive.box('favouritePlaylists');
final _importedPlaylists = Hive.box('importedPlaylists');
final _searchHistory = Hive.box<String>('searchHistory');
final _playHistory = Hive.box('playHistory');

///Favourite Playlists

getFavouritePlaylists() {}

ValueListenable<Box<dynamic>> favouritePlaylistsListenable() {
  return _favouritePlaylists.listenable();
}

void _addFavouritePlaylist(Map<String, String> playlist) {
  _favouritePlaylists.add(playlist);
}

Map<dynamic, dynamic> getExistingPlaylist(String playlistId) {
  return _favouritePlaylists.values.firstWhere(
      (element) => element['playlistId'] == playlistId,
      orElse: () => {});
}

bool checkifPlaylistExists(String playlistId) {
  return getExistingPlaylist(playlistId).isNotEmpty;
}

void checkAndAddFavourite(Map<String, String> playlist) {
  if (!checkifPlaylistExists(playlist['playlistId']!)) {
    _addFavouritePlaylist(playlist);
  }
}

void removeFavouritePlaylist(int index) {
  _favouritePlaylists.deleteAt(index);
}

void checkAndDelete(Map<String, String> playlist) {
  Map existingPlaylist = {};
  if ((existingPlaylist = getExistingPlaylist(playlist['playlistId']!))
      .isNotEmpty) {
    int index = _favouritePlaylists.values.toList().indexOf(existingPlaylist);
    removeFavouritePlaylist(index);
  }
}

void deleteAllFavouritePlaylists() {
  _favouritePlaylists.clear();
}

///Imported Playlist Section

Future<void> importPlaylist(SongPlayList playlist) async {
  LocalPlaylist localPlaylist =
      LocalPlaylist(title: playlist.title, songs: playlist.items);
  await _importedPlaylists.add(localPlaylist.toJson());
  return;
}

Future<void> removeSongFromPlaylist(int playlistIndex, int songIndex) async {
  LocalPlaylist localPlaylist =
      LocalPlaylist.fromJson(_importedPlaylists.getAt(playlistIndex));
  localPlaylist.songs.removeAt(songIndex);
  await _importedPlaylists.putAt(playlistIndex, localPlaylist.toJson());
}

Future<void> editPlaylist(int index, LocalPlaylist localPlaylist) async {
  await _importedPlaylists.putAt(index, localPlaylist.toJson());
}

ValueListenable<Box<dynamic>> importedPlaylistsListenable() {
  return _importedPlaylists.listenable();
}

void deleteAllImportedPlaylists() {
  _importedPlaylists.clear();
}

///Search history

ValueListenable<Box<dynamic>> searchHistoryListenable() {
  return _searchHistory.listenable();
}

void _addSearchHistory(String query) {
  _searchHistory.add(query);
}

bool _checkifSearchExists(String query) {
  return _searchHistory.values.any((element) => element == query);
}

void checkAndAddSearch(String query) {
  if (!_checkifSearchExists(query)) {
    _addSearchHistory(query);
  }
}

///Play History

ValueListenable<Box<dynamic>> searchPlayHistoryListenable() {
  return _playHistory.listenable();
}

void _addPlayHistory(Map historyMap) {
  _playHistory.add(historyMap);
}

int _checkAndReturnHistoryIndex(Map historyMap) {
  int index = -1;
  for (int i = 0; i < _playHistory.length; i++) {
    if (_playHistory.getAt(i)['id'] == historyMap['id']) {
      index = i;
      //break;
    }
  }
  return index;
}

void checkAndAddPlayHistory(Map historyMap) async {
  int index = _checkAndReturnHistoryIndex(historyMap);
  if (index == -1) {
    _addPlayHistory(historyMap);
  } else {
    await _playHistory.deleteAt(index);
    await _playHistory.add(historyMap);
  }
}
