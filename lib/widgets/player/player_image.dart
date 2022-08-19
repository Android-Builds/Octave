import 'package:akar_icons_flutter/akar_icons_flutter.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class PlayerImage extends StatefulWidget {
  const PlayerImage({
    Key? key,
    required this.imageSize,
    required this.mediaItem,
  }) : super(key: key);

  final double imageSize;
  final MediaItem mediaItem;

  @override
  State<PlayerImage> createState() => _PlayerImageState();
}

class _PlayerImageState extends State<PlayerImage> {
  bool isToggled = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isToggled = !isToggled;
        });
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: CachedNetworkImage(
              height: widget.imageSize,
              width: widget.imageSize,
              fit: BoxFit.cover,
              imageUrl: widget.mediaItem.artUri.toString(),
              errorWidget: (context, url, error) => CachedNetworkImage(
                height: widget.imageSize,
                width: widget.imageSize,
                fit: BoxFit.cover,
                imageUrl: url
                    .replaceAllMapped(RegExp(r'w[0-9]{3,4}-h[0-9]{3,4}'),
                        (match) => 'w120-h120')
                    .replaceAll('maxresdefault', 'hqdefault'),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isToggled
                ? Container(
                    width: widget.imageSize,
                    height: widget.imageSize,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FloatingActionButton(
                          mini: true,
                          onPressed: () {
                            final url =
                                'https://music.youtube.com/watch?v=${widget.mediaItem.id}&feature=share';
                            Share.share(url);
                          },
                          shape: const CircleBorder(),
                          child: const Icon(AkarIcons.arrow_forward_thick),
                        ),
                        FloatingActionButton(
                          mini: true,
                          onPressed: () {},
                          shape: const CircleBorder(),
                          child: const Icon(Icons.playlist_add_outlined),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          )
        ],
      ),
    );
  }
}
