import 'package:audio_service/audio_service.dart';
import 'package:beats/pages/discover_page.dart';
import 'package:beats/pages/trending_page.dart';
import 'package:beats/widgets/for_you_widget.dart';
import 'package:flutter/material.dart';

import '../classes/universal_search_delegate.dart';
import '../utils/player_manager.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            title: const Text(
              'Beats',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  PlayerManager.homePage = false;
                  Future.delayed(const Duration(milliseconds: 50),
                      () => PlayerManager.navbarHeight.value = 0);
                  showSearch(
                    context: context,
                    delegate: UniversalSearchDelegate(),
                  );
                },
                icon: const Icon(Icons.search),
              )
            ],
            snap: true,
            pinned: false,
            floating: true,
          ),
        ];
      },
      body: ValueListenableBuilder(
        valueListenable: PlayerManager.navbarIndex,
        builder: (context, int value, child) => ListView(
          shrinkWrap: true,
          children: [
            const <Widget>[
              ForYouWidget(),
              DiscoverPage(),
              TrendingPage(),
            ][value],
            StreamBuilder<PlaybackState>(
              stream: PlayerManager.audioHandler.playbackState,
              builder: (context, snapshot) {
                final playbackState = snapshot.data;
                final stopped =
                    playbackState?.processingState == AudioProcessingState.idle;
                return SizedBox(
                  height: stopped ? 0 : kBottomNavigationBarHeight,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
