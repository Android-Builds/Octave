import 'dart:math';

import 'package:beats/utils/player_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MyDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final String imageUrl;
  final Widget leading;
  final Widget button;

  const MyDelegate({
    required this.title,
    required this.imageUrl,
    required this.leading,
    required this.button,
  });

  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    double shrinkPercentage =
        min(1, shrinkOffset / (maxExtent - minExtent)).toDouble();

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      // fit: StackFit.expand,
      children: [
        Positioned(
          top: kToolbarHeight,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Opacity(
                opacity: 1 - shrinkPercentage,
                child: Container(
                  height: PlayerManager.size.height * 0.4,
                  width: PlayerManager.size.height * 0.4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      alignment: FractionalOffset.topCenter,
                      image: CachedNetworkImageProvider(
                        imageUrl
                            .replaceAll('w226', 'w500')
                            .replaceAll('h226', 'h500'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Theme.of(context)
                    .colorScheme
                    .background
                    .withOpacity(shrinkPercentage),
                height: kToolbarHeight * 1.3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Flexible(
                        child: Opacity(
                          opacity: shrinkPercentage,
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.more_vert,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: (-kToolbarHeight * 0.7) * shrinkPercentage,
              left: 0,
              right: 10 * shrinkPercentage,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: PlayerManager.size.width * 0.7,
                      child: Opacity(
                        opacity: max(1 - shrinkPercentage * 10, 0),
                        child: leading,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    button,
                  ],
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  @override
  double get maxExtent => PlayerManager.size.height * 0.6;

  @override
  double get minExtent => kToolbarHeight * 1.5;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
