import 'package:audio_service/audio_service.dart';
import 'package:beats/pages/local_playlist_list.dart';
import 'package:beats/pages/playlist_page.dart';
import 'package:beats/utils/constants.dart';
import 'package:beats/widgets/marquee_widget.dart';
import 'package:beats/widgets/player/player_image.dart';
import 'package:flutter/material.dart';
import 'package:miniplayer/miniplayer.dart' as mp;

import '../common.dart';
import '../../../utils/player_manager.dart';
import '../control_buttons.dart';
import 'bottom_sheet.dart';

class ExpandedPlayer extends StatelessWidget {
  const ExpandedPlayer({
    Key? key,
    required this.height,
    required this.mediaItem,
    required this.positionData,
  }) : super(key: key);

  final double height;
  final MediaItem mediaItem;
  final PositionData positionData;

  @override
  Widget build(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    var percentageExpandedPlayer = PlayerManager.percentageFromValueInRange(
      min: maxHeight * 0.2 + minHeight,
      max: maxHeight,
      value: height,
    );

    var opacity = PlayerManager.percentageFromValueInRange(
      min: maxHeight * 0.5 + minHeight,
      max: maxHeight,
      value: height,
    );

    var sheetOpacity = PlayerManager.percentageFromValueInRange(
      min: maxHeight * 0.7,
      max: maxHeight,
      value: height,
    );

    if (percentageExpandedPlayer < 0) percentageExpandedPlayer = 0;
    if (opacity < 0) opacity = 0;
    if (sheetOpacity < 0) sheetOpacity = 0;

    final paddingVertical = PlayerManager.valueFromPercentageInRange(
      min: 0,
      max: 10,
      percentage: percentageExpandedPlayer,
    );
    final double heightWithoutPadding = height - paddingVertical * 2;
    final double imageSize =
        heightWithoutPadding > maxImgSize ? maxImgSize : heightWithoutPadding;
    final paddingLeft = PlayerManager.valueFromPercentageInRange(
          min: 0,
          max: PlayerManager.size.width - imageSize,
          percentage: percentageExpandedPlayer,
        ) /
        2;

    bool isOpen = false;

    return StatefulBuilder(builder: (context, setState) {
      return GestureDetector(
        onVerticalDragDown: isOpen ? (details) {} : null,
        child: Container(
          color: Theme.of(context).colorScheme.background,
          child: Stack(
            children: [
              Column(
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: SizedBox(
                      height: kToolbarHeight * 1.5,
                      child: AppBar(
                        centerTitle: true,
                        leading: IconButton(
                          onPressed: () {
                            PlayerManager.miniplayerController.animateToHeight(
                              state: mp.PanelState.MIN,
                            );
                          },
                          icon: const Icon(Icons.keyboard_arrow_down),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Playing From',
                              style: TextStyle(
                                  fontSize: PlayerManager.size.width * 0.04),
                            ),
                            Text(
                              mediaItem.album!.isNotEmpty
                                  ? mediaItem.album
                                  : mediaItem.extras!['playlist'] ?? "",
                              style: TextStyle(
                                fontSize: PlayerManager.size.width * 0.03,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          IconButton(
                            onPressed: () => showMenu(context),
                            icon: const Icon(Icons.more_vert),
                          )
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: paddingLeft,
                        top: paddingVertical,
                        bottom: paddingVertical,
                      ),
                      child: PlayerImage(
                        imageSize: imageSize,
                        mediaItem: mediaItem,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Opacity(
                        opacity: opacity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(child: SizedBox(height: 20)),
                            Flexible(
                              child: MarqueeWidget(
                                child: Text(
                                  mediaItem.title,
                                  style: TextStyle(
                                    fontSize: PlayerManager.size.width * 0.06,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                mediaItem.artist ?? mediaItem.album ?? "",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .copyWith(
                                      fontSize: PlayerManager.size.width * 0.04,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyText2!
                                          .color!
                                          .withOpacity(0.55),
                                    ),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Opacity(
                                opacity: opacity,
                                child: SeekBar(
                                  duration: positionData.duration,
                                  position: positionData.position,
                                  bufferedPosition:
                                      positionData.bufferedPosition,
                                  onChangeEnd: (newPosition) {
                                    PlayerManager.audioHandler
                                        .seek(newPosition);
                                  },
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Opacity(
                                opacity: opacity,
                                child: ControlButtons(
                                  PlayerManager.audioHandler,
                                ),
                              ),
                            ),
                            const Flexible(
                              flex: 2,
                              child: SizedBox.expand(),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Opacity(
                opacity: sheetOpacity,
                child: PlayerBottomSheet(
                  isOpen: (value) {
                    setState(() => isOpen = value);
                  },
                  mediaItem: mediaItem,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> showMenu(BuildContext context) async {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(
            top: 10.0,
            right: 5.0,
            left: 5.0,
          ),
          child: Wrap(
            children: [
              ListTile(
                dense: true,
                leading: const Icon(Icons.playlist_add),
                onTap: () => addToPlaylist(
                  context,
                  mediaItem,
                ),
                title: const Text('Add to Playlist'),
              ),
              ListTile(
                dense: true,
                enabled: mediaItem.extras!.containsKey('albumId'),
                leading: const Icon(Icons.album),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaylistPage(
                        playlistId: mediaItem.extras!['albumId'],
                        thumbnail: mediaItem.artUri.toString(),
                      ),
                    ),
                  );
                },
                title: const Text('Go to Album'),
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.person),
                onTap: () {},
                title: const Text('Go to Artist'),
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.save),
                onTap: () {},
                title: const Text('Save Song'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> addToPlaylist(
    BuildContext context,
    MediaItem mediaItem,
  ) async {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              LocalPlaylistList(
                mediaItem: mediaItem,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('+ New Playlist'),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
