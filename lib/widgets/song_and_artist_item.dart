import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SongAndArtistItem extends StatelessWidget {
  const SongAndArtistItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.thumbnail,
    required this.width,
    this.artist = false,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final String thumbnail;
  final double width;
  final bool artist;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        artist
            ? CircleAvatar(
                radius: width / 2,
                child: ClipOval(
                  child: thumbnailWidget(),
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: thumbnailWidget(),
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
