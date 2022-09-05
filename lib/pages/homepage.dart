import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:beats/pages/library.dart';
import 'package:beats/widgets/for_you_widget.dart';
import 'package:flutter/material.dart';
import '../classes/universal_search_delegate.dart';
import '../utils/player_manager.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = 'Beats';
    Random random = Random();
    int highlightTextIndex = random.nextInt(title.length);
    String initialText =
        highlightTextIndex == 0 ? '' : title.substring(0, highlightTextIndex);
    String highlightedText = title[highlightTextIndex];
    String finalText = highlightTextIndex == title.length - 1
        ? ''
        : title.substring(highlightTextIndex + 1);

    bool color = random.nextBool();

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            title: RichText(
              text: TextSpan(
                text: initialText,
                style: DefaultTextStyle.of(context).style.copyWith(
                      fontSize: PlayerManager.size.width * 0.06,
                      fontWeight: FontWeight.bold,
                      color: color
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).textTheme.bodyText1!.color!,
                    ),
                children: <TextSpan>[
                  TextSpan(
                    text: highlightedText,
                    style: TextStyle(
                      color: color
                          ? Theme.of(context).textTheme.bodyText1!.color!
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  TextSpan(text: finalText),
                ],
              ),
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
              Library(),
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
