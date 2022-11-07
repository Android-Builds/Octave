import 'package:octave/utils/db_helper.dart';
import 'package:octave/utils/player_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: ValueListenableBuilder(
        valueListenable: searchPlayHistoryListenable(),
        builder: (context, Box playHistoryBox, _) {
          List today = playHistoryBox.values
              .toList()
              .reversed
              .toList()
              .where((element) =>
                  DateTime.now()
                      .difference(playHistoryBox.values.first['time'])
                      .inDays ==
                  0)
              .toList();
          List yesterday = playHistoryBox.values
              .toList()
              .reversed
              .toList()
              .where((element) =>
                  DateTime.now()
                      .difference(playHistoryBox.values.first['time'])
                      .inDays ==
                  1)
              .toList();
          List others = playHistoryBox.values
              .toList()
              .reversed
              .toList()
              .where((element) =>
                  DateTime.now()
                      .difference(playHistoryBox.values.first['time'])
                      .inDays >
                  1)
              .toList();
          List history = [today, yesterday, others];
          return history.isNotEmpty
              ? ListView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return history[index].isNotEmpty
                        ? Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.only(
                                  left: 40.0,
                                  bottom: 10.0,
                                ),
                                dense: true,
                                title: Text(
                                  ['Today', 'Yesterday', 'Others'][index],
                                  style: TextStyle(
                                    fontSize: PlayerManager.size.width * 0.06,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: history[index].length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, innerIndex) => ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(5.0),
                                    child: CachedNetworkImage(
                                      imageUrl: history[index][innerIndex]
                                          ['thumbnail']!,
                                    ),
                                  ),
                                  title: Text(
                                    history[index][innerIndex]['title'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          PlayerManager.size.width * 0.042,
                                    ),
                                  ),
                                  subtitle: Text(
                                    history[index][innerIndex]['album'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          PlayerManager.size.width * 0.035,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox();
                  },
                )
              : Center(
                  child: Transform.scale(
                    scale: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: PlayerManager.size.width * 0.09,
                        ),
                        const SizedBox(height: 20.0),
                        Text(
                          'Nothing to show',
                          style: TextStyle(
                            fontSize: PlayerManager.size.width * 0.06,
                          ),
                        )
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }
}
