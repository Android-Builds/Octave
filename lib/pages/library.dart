import 'package:octave/pages/history_page.dart';
import 'package:octave/utils/player_manager.dart';
import 'package:octave/widgets/play_history.dart';
import 'package:flutter/material.dart';

import 'library/favourite_playlists.dart';
import 'library/my_playlists.dart';

class Library extends StatefulWidget {
  const Library({Key? key}) : super(key: key);

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        ListTile(
          dense: true,
          trailing: IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HistoryPage(),
              ),
            ),
            icon: const Icon(Icons.keyboard_arrow_right),
          ),
          leading: const Icon(Icons.history),
          title: Text(
            'History',
            style: TextStyle(
              fontSize: PlayerManager.size.width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const PlayHistory(),
        ListTile(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FavouritePlaylists(),
            ),
          ),
          leading: const Icon(Icons.playlist_play),
          title: Text(
            'Favourite Playlists',
            style: TextStyle(
              fontSize: PlayerManager.size.width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MyPlaylists(),
            ),
          ),
          leading: const Icon(Icons.playlist_play),
          title: Text(
            'My Playlists',
            style: TextStyle(
              fontSize: PlayerManager.size.width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
