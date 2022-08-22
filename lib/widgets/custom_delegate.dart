import 'dart:math';

import 'package:beats/utils/player_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MyDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final String imageUrl;
  final Widget leading;
  final List<Widget> actions;
  final Widget button;

  const MyDelegate({
    required this.title,
    required this.imageUrl,
    required this.leading,
    required this.actions,
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
                  height: PlayerManager.size.height * 0.34,
                  width: PlayerManager.size.height * 0.34,
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
                      const Spacer(),
                      Opacity(
                        opacity: shrinkPercentage,
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: (-kToolbarHeight * 0.7) * shrinkPercentage,
              left: 0,
              right: 10,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: PlayerManager.size.width * 0.8,
                      child: Opacity(
                        opacity: max(1 - shrinkPercentage * 10, 0),
                        child: leading,
                      ),
                    ),
                    Row(children: [
                      for (Widget w in actions)
                        Opacity(
                          opacity: max(1 - shrinkPercentage * 10, 0),
                          child: w,
                        ),
                      const Spacer(),
                      button,
                    ]),
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
