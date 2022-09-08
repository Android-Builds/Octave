library dbhelper;

import 'package:beats/classes/local_playlist.dart';
import 'package:beats/classes/playlist.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

final _favouritePlaylists = Hive.box('favouritePlaylists');
final _importedPlaylists = Hive.box('importedPlaylists');

getFavouritePlaylists() {}

ValueListenable<Box<dynamic>> favouritePlaylistsListenable() {
  return _favouritePlaylists.listenable();
}

void addFavouritePlaylist(Map<String, String> playlist) {
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

void checkAndAdd(Map<String, String> playlist) {
  if (!checkifPlaylistExists(playlist['playlistId']!)) {
    addFavouritePlaylist(playlist);
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
