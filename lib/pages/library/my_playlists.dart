import 'package:beats/pages/local_playlist_list.dart';
import 'package:flutter/material.dart';

class MyPlaylists extends StatelessWidget {
  const MyPlaylists({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourite Playlists'),
      ),
      body: const LocalPlaylistList(),
    );
  }
}
