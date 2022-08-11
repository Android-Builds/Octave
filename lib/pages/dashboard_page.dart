import 'package:beats/pages/homepage.dart';
import 'package:beats/widgets/player/new_player/player.dart';
import 'package:flutter/material.dart';

import '../utils/player_manager.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    PlayerManager.homePage = true;
    PlayerManager.navbarHeight.value = kBottomNavigationBarHeight;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PlayerManager.size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        final NavigatorState navigator =
            PlayerManager.navigatorKey.currentState!;
        if (!navigator.canPop()) return true;
        navigator.pop();
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Navigator(
              key: PlayerManager.navigatorKey,
              onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
                settings: settings,
                builder: (BuildContext context) => const HomePage(),
              ),
            ),
            const Player(),
          ],
        ),
        bottomNavigationBar: ValueListenableBuilder(
          valueListenable: PlayerManager.playerExpandProgress,
          builder: (BuildContext context, double height, Widget? child) {
            final value = PlayerManager.percentageFromValueInRange(
              min: kBottomNavigationBarHeight,
              max: PlayerManager.size.height,
              value: height,
            );

            var opacity = 1 - value;
            if (opacity < 0) opacity = 0;
            if (opacity > 1) opacity = 1;

            return SizedBox(
              height: kBottomNavigationBarHeight -
                  kBottomNavigationBarHeight * value,
              child: Transform.translate(
                offset: Offset(0.0, kBottomNavigationBarHeight * value * 0.5),
                child: Opacity(
                  opacity: opacity,
                  child: OverflowBox(
                    maxHeight: kBottomNavigationBarHeight * 1.1,
                    child: child,
                  ),
                ),
              ),
            );
          },
          child: BottomNavigationBar(
            backgroundColor: ElevationOverlay.colorWithOverlay(
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.primary,
              3.0,
            ),
            currentIndex: PlayerManager.navbarIndex.value,
            onTap: (int index) => setState(() {
              PlayerManager.navbarIndex.value = index;
            }),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'For You',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore),
                label: 'Discover',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.trending_up),
                label: 'Trending',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
