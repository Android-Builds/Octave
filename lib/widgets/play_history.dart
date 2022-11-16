import 'package:octave/utils/db_helper.dart';
import 'package:octave/utils/player_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class PlayHistory extends StatelessWidget {
  const PlayHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: searchPlayHistoryListenable(),
      builder: (context, Box playHistoryBox, _) {
        List songHistory = playHistoryBox.values.toList().reversed.toList();
        return NotificationListener<OverscrollNotification>(
          onNotification: (notification) =>
              notification.metrics.axisDirection != AxisDirection.down,
          child: playHistoryBox.isNotEmpty
              ? SizedBox(
                  height: PlayerManager.size.height * 0.27,
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(5.0),
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        songHistory.length > 10 ? 10 : songHistory.length,
                    itemBuilder: (context, index) => TextButton(
                      onPressed: () => {},
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: CachedNetworkImage(
                              imageUrl: songHistory[index]['thumbnail']!,
                              width: PlayerManager.size.width * 0.35,
                              height: PlayerManager.size.width * 0.35,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          SizedBox(
                            width: PlayerManager.size.width * 0.35,
                            child: Text(
                              songHistory[index]['title'].toString(),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: PlayerManager.size.width * 0.04,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
        );
      },
    );
  }
}
