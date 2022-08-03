import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../utils/player_manager.dart';

class PosterWidget extends StatelessWidget {
  const PosterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MediaItem?>(
      stream: PlayerManager.audioHandler.mediaItem,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;
        if (mediaItem == null) return const SizedBox();
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mediaItem.artUri != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Hero(
                      tag: mediaItem.artUri!,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          height: PlayerManager.size.height * 0.5,
                          width: PlayerManager.size.width,
                          imageUrl: '${mediaItem.artUri!}',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Text(
              mediaItem.title,
              maxLines: 1,
              style: TextStyle(
                fontSize: PlayerManager.size.width * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              mediaItem.artist ?? '',
              style: TextStyle(
                fontSize: PlayerManager.size.width * 0.04,
                color: Colors.grey,
              ),
            ),
          ],
        );
      },
    );
  }
}
