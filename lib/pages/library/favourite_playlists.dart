import 'package:octave/pages/playlist_page.dart';
import 'package:octave/utils/db_helper.dart';
import 'package:octave/utils/player_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class FavouritePlaylists extends StatelessWidget {
  const FavouritePlaylists({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = PlayerManager.size.width * 0.05;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourite Playlists'),
        actions: const [
          IconButton(
            onPressed: deleteAllFavouritePlaylists,
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: favouritePlaylistsListenable(),
        builder: (context, Box favouritePlaylistBox, _) {
          return NotificationListener<OverscrollNotification>(
            onNotification: (notification) =>
                notification.metrics.axisDirection != AxisDirection.down,
            child: favouritePlaylistBox.isNotEmpty
                ? GridView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(10.0),
                    scrollDirection: Axis.vertical,
                    itemCount: favouritePlaylistBox.length,
                    itemBuilder: (context, index) => TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaylistPage(
                            playlistId: favouritePlaylistBox
                                .getAt(index)['playlistId']!,
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
                              imageUrl: favouritePlaylistBox
                                  .getAt(index)['thumbnail']!,
                              width: PlayerManager.size.width * 0.43,
                              height: PlayerManager.size.width * 0.43,
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
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: double.parse(
                        (PlayerManager.size.height *
                                0.42 /
                                PlayerManager.size.width)
                            .toStringAsFixed(2),
                      ),
                    ),
                  )
                : Center(
                    child: Transform.scale(
                      scale: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.queue_music, size: size * 1.5),
                          const SizedBox(height: 20.0),
                          Text(
                            'No favourites yet',
                            style: TextStyle(fontSize: size),
                          )
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
