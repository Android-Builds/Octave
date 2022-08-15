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
              ? CircleAvatar(
                  radius: width / 2,
                  child: ClipOval(
                    child: thumbnailWidget(),
                  ),
                )
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: thumbnailWidget(),
                    ),
                    Icon(
                      Ionicons.play,
                      size: PlayerManager.size.width * 0.1,
                      color:
                          Theme.of(context).iconTheme.color!.withOpacity(0.8),
                    ),
                  ],
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
                //fontWeight: FontWeight.bold,
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget thumbnailWidget() => CachedNetworkImage(
        imageUrl: thumbnail,
        height: width,
        width: width,
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
