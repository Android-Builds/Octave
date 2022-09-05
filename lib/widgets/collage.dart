import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Collage extends StatelessWidget {
  final List<MediaItem> mediaItems;
  final List<int> indexes;
  const Collage({
    Key? key,
    required this.mediaItems,
    required this.indexes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: indexes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemBuilder: (context, index) {
        return CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: mediaItems[indexes[index]].artUri.toString(),
        );
      },
    );
  }
}
