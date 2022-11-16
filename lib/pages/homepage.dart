import 'package:octave/pages/library.dart';
import 'package:octave/widgets/for_you_widget.dart';
import 'package:octave/widgets/miniplayer_bottom_padder.dart';
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
            title: Text(
              'Octave',
              style: TextStyle(
                fontSize: PlayerManager.size.width * 0.06,
                fontWeight: FontWeight.bold,
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
        builder: (context, int value, child) => Column(
          children: [
            Flexible(
                child: const <Widget>[
              ForYouWidget(),
              Library(),
            ][value]),
            const MiniPlayerBottomPadder(),
          ],
        ),
      ),
    );
  }
}
