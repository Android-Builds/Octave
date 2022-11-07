import 'package:beats/utils/player_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../pages/artists_page.dart';

class SongAndArtistItem extends StatelessWidget {
  const SongAndArtistItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.browseId,
    required this.playlistId,
    required this.thumbnail,
    required this.width,
    this.artist = false,
  }) : super(key: key);

  final String title;

  final String subtitle;
  final String browseId;
  final String playlistId;
  final String thumbnail;
  final double width;
  final bool artist;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
        if (artist) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArtistsPage(
                imageUrl: thumbnail,
                title: title,
                artistId: browseId,
              ),
            ),
          );
        } else {
          PlayerManager.playMusic(
            browseId,
            playlistId,
            'Trending',
          );
        }
      },
      child: Column(
        children: [
          artist
              ? Container(
                  height: width,
                  width: width,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: CircleAvatar(
                    radius: width / 2,
                    child: ClipOval(
                      child: thumbnailWidget(),
                    ),
                  ),
                )
              : Container(
                  height: width,
                  width: width,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  padding: const EdgeInsets.all(15.0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: thumbnailWidget(),
                      ),
                      Positioned(
                        right: -10,
                        bottom: -25,
                        child: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.inversePrimary,
                          radius: width * 0.1,
                          child: Icon(
                            Ionicons.play,
                            size: width * 0.08,
                            color: Theme.of(context)
                                .iconTheme
                                .color!
                                .withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          const SizedBox(height: 10.0),
          SizedBox(
            width: width,
            child: Text(
              title,
              overflow: TextOverflow.clip,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: width * 0.13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: width,
            child: Text(
              subtitle,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontSize: width * 0.11,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget thumbnailWidget() => CachedNetworkImage(
        height: width,
        width: width,
        imageUrl: thumbnail,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) {
          return CachedNetworkImage(
            imageUrl: url.replaceAll('maxresdefault', 'hqdefault'),
            height: width,
            width: width,
            fit: BoxFit.cover,
          );
        },
      );
}
