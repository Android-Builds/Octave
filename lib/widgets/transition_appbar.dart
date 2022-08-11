import 'package:flutter/material.dart';

import '../utils/player_manager.dart';

class TransitionAppBar extends StatelessWidget {
  final Widget avatar;
  final String title;
  final double extent;

  const TransitionAppBar(
      {required this.avatar, required this.title, this.extent = 250, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TransitionAppBarDelegate(
          avatar: avatar, title: title, extent: extent > 200 ? extent : 200),
    );
  }
}

class _TransitionAppBarDelegate extends SliverPersistentHeaderDelegate {
  final _avatarAlignTween = AlignmentTween(begin: Alignment.bottomCenter);

  final Widget avatar;
  final String title;
  final double extent;

  _TransitionAppBarDelegate(
      {required this.avatar, required this.title, this.extent = 250})
      : assert(extent >= 200);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    double tempVal = 72 * maxExtent / 100;
    final progress = shrinkOffset > tempVal ? 1.0 : shrinkOffset / tempVal;

    final avatarAlign = _avatarAlignTween.lerp(progress);

    final avatarSize = (1 - progress) * PlayerManager.size.height * 0.35;

    return Stack(
      children: <Widget>[
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: kToolbarHeight,
          constraints: BoxConstraints(maxHeight: minExtent),
          color: Theme.of(context).colorScheme.background,
        ),
        Align(
          alignment: avatarAlign,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: avatarSize,
                width: avatarSize,
                child: avatar,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18 + (5 * (1 - progress)),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.arrow_back),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
            )
          ],
        ),
      ],
    );
  }

  @override
  double get maxExtent => extent;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(_TransitionAppBarDelegate oldDelegate) {
    return avatar != oldDelegate.avatar || title != oldDelegate.title;
  }
}
