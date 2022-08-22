import 'package:beats/pages/playlist_page.dart';
import 'package:beats/utils/db_helper.dart';
import 'package:beats/utils/player_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class Library extends StatefulWidget {
  const Library({Key? key}) : super(key: key);

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        ListTile(
          dense: true,
          title: Text(
            'Favourites',
            style: TextStyle(
              fontSize: PlayerManager.size.width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: PlayerManager.size.height * 0.28,
          child: ValueListenableBuilder(
            valueListenable: favouritePlaylistsListenable(),
            builder: (context, Box favouritePlaylistBox, _) {
              return NotificationListener<OverscrollNotification>(
                // Suppress OverscrollNotification events that escape from the inner scrollable
                onNotification: (notification) =>
                    notification.metrics.axisDirection != AxisDirection.down,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: favouritePlaylistBox.isNotEmpty
                      ? favouritePlaylistBox.length
                      : 0,
                  itemBuilder: (context, index) => TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaylistPage(
                          playlistId:
                              favouritePlaylistBox.getAt(index)['playlistId']!,
                          thumbnail:
                              favouritePlaylistBox.getAt(index)['thumbnail']!,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: CachedNetworkImage(
                            imageUrl:
                                favouritePlaylistBox.getAt(index)['thumbnail']!,
                            width: PlayerManager.size.width * 0.4,
                            height: PlayerManager.size.width * 0.4,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        SizedBox(
                          width: PlayerManager.size.width * 0.4,
                          child: Text(
                            favouritePlaylistBox
                                .getAt(index)['title']
                                .toString(),
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
              );
            },
          ),
        ),
      ],
    );
  }
}
