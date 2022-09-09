import 'package:beats/pages/local_playlist_list.dart';
import 'package:beats/utils/db_helper.dart';
import 'package:flutter/material.dart';

class MyPlaylists extends StatelessWidget {
  const MyPlaylists({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Imported Playlists'),
        actions: const [
          IconButton(
            onPressed: deleteAllImportedPlaylists,
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: const LocalPlaylistList(),
    );
  }
}
