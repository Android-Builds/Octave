import 'package:audio_service/audio_service.dart';
import 'package:octave/utils/player_manager.dart';
import 'package:octave/widgets/player/player_playlist.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'lyrics_container.dart';

class PlayerBottomSheet extends StatefulWidget {
  const PlayerBottomSheet({
    Key? key,
    required this.mediaItem,
    required this.isOpen,
  }) : super(key: key);

  final MediaItem mediaItem;
  final ValueSetter<bool> isOpen;

  @override
  State<PlayerBottomSheet> createState() => _PlayerBottomSheetState();
}

class _PlayerBottomSheetState extends State<PlayerBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PanelController panelController = PanelController();
  static int tabNumber = 0;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      isDraggable: true,
      backdropTapClosesPanel: false,
      controller: panelController,
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(10.0),
        topRight: Radius.circular(10.0),
      ),
      onPanelOpened: () => widget.isOpen(true),
      onPanelClosed: () => widget.isOpen(false),
      minHeight: kBottomNavigationBarHeight,
      maxHeight: PlayerManager.size.height * 0.9,
      header: ValueListenableBuilder(
        valueListenable: PlayerManager.lyricsAvailable,
        builder: (context, bool isAvailable, child) {
          return SizedBox(
            height: 50.0,
            width: 400.0,
            child: TabBar(
              isScrollable: false,
              onTap: (value) {
                if (value == 1 && !isAvailable) {
                  _tabController.index = 0;
                  return;
                }
                if (panelController.isPanelOpen && tabNumber == value) {
                  panelController.close();
                } else {
                  panelController.open();
                }
                tabNumber = value;
              },
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              tabs: [
                const Text('Now Playing'),
                Text(
                  'Lyrics',
                  style: TextStyle(color: !isAvailable ? Colors.grey : null),
                )
              ],
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.label,
              physics: const NeverScrollableScrollPhysics(),
            ),
          );
        },
      ),
      panel: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: PlayerPlaylist(
              panelController: panelController,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: LyricsContainer(
                mediaItem: widget.mediaItem,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
