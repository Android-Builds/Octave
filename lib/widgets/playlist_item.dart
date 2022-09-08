import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/player_manager.dart';

class PlaylistItem extends StatelessWidget {
  const PlaylistItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.thumbnail,
    this.width,
    this.titleMaxLine = 2,
    this.subtitleMaxLine = 2,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final String thumbnail;
  final double? width;
  final int? titleMaxLine;
  final int? subtitleMaxLine;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            child: CachedNetworkImage(
              imageUrl: thumbnail,
              height: width == null ? null : width! - 20.0,
              width: width == null ? null : width! - 20.0,
            ),
          ),
          const SizedBox(height: 5.0),
          SizedBox(
            width: width == null ? null : width! - 20.0,
            child: Text(
              title,
              maxLines: titleMaxLine,
              style: const TextStyle(
                fontSize: 15.0,
              ),
            ),
          ),
          SizedBox(
            width: width == null ? null : width! - 20.0,
            child: Text(
              subtitle,
              maxLines: subtitleMaxLine,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey,
                fontSize: PlayerManager.size.width * 0.033,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
