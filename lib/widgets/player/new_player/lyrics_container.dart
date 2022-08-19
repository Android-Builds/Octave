import 'package:audio_service/audio_service.dart';
import 'package:beats/api/youtube_api.dart';
import 'package:flutter/material.dart';

class LyricsContainer extends StatelessWidget {
  const LyricsContainer({
    Key? key,
    required this.mediaItem,
    required this.scrollController,
  }) : super(key: key);

  final MediaItem mediaItem;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: YtmApi.getLyrics(
        mediaItem.extras!['playlistId'],
        mediaItem.id,
      ),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          final String lyrics = snapshot.data;
          if (lyrics.isEmpty) {
            return const Text('No lyrics Available');
          } else {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(10.0),
              children: [
                Text(
                  snapshot.data,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                )
              ],
            );
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
