import 'package:audio_service/audio_service.dart';
import 'package:beats/utils/player_manager.dart';
import 'package:beats/widgets/player/player_playlist.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'lyrics_container.dart';

class PlayerBottomSheet extends StatefulWidget {
  const PlayerBottomSheet({Key? key, required this.mediaItem})
      : super(key: key);

  final MediaItem mediaItem;

  @override
  State<PlayerBottomSheet> createState() => _PlayerBottomSheetState();
}

class _PlayerBottomSheetState extends State<PlayerBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PanelController panelController = PanelController();

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      controller: panelController,
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(10.0),
      minHeight: kBottomNavigationBarHeight,
      maxHeight: PlayerManager.size.height * 0.9,
      header: SizedBox(
        height: 50.0,
        width: 400.0,
        child: TabBar(
          onTap: (value) {
            panelController.open();
          },
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(
              text: 'Now Playing',
            ),
            Tab(
              text: 'Lyrics',
            )
          ],
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.label,
        ),
      ),
      panelBuilder: (ScrollController scrollController) {
        return TabBarView(
          controller: _tabController,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Playlist(
                scrollController: scrollController,
                panelController: panelController,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: LyricsContainer(
                  scrollController: scrollController,
                  mediaItem: widget.mediaItem,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
