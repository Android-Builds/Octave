import 'package:audio_service/audio_service.dart';

class SongPlayList {
  final String title;
  final String subtitle;
  final String secondarySubtitle;
  final String thumbnail;
  final List<MediaItem> items;

  SongPlayList(
    this.title,
    this.subtitle,
    this.secondarySubtitle,
    this.thumbnail,
    this.items,
  );
}
