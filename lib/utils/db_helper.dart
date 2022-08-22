library dbhelper;

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

final _favouritePlaylists = Hive.box('favouritePlaylists');

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
