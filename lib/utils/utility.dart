library utility;

import 'dart:math';

import 'package:audio_service/audio_service.dart';

final Random random = Random();

List<int> getRandomIndex(int length) {
  return List.generate(
    length > 4
        ? 4
        : length > 2
            ? 2
            : 1,
    (_) => random.nextInt(length),
  );
}

String getSongCountText(int count) {
  return '$count ${count == 1 ? 'song' : 'songs'}';
}

String mapToText(Map textMap) {
  if (textMap.isEmpty) return '';
  List textList = textMap['runs'];
  if (textList.first['text'] == 'Playlist') {
    textList = textList.sublist(2);
  }
  return textList.map((e) => e['text']).toList().join();
}

String durationTextFromDuration(Duration duration) {
  return '${RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$').firstMatch("$duration")?.group(1)}';
}

String totalDuration(List<MediaItem> songs) {
  return durationTextFromDuration(
    Duration(
      seconds: songs
          .map((e) => e.duration!.inSeconds)
          .toList()
          .reduce((a, b) => a + b),
    ),
  );
}

Duration parseTime(String durationText) {
  final parts = durationText.split(':');
  if (parts.length != 3) throw const FormatException('Invalid time format');
  int days;
  int hours;
  int minutes;
  int seconds;
  int milliseconds;
  int microseconds;
  {
    final p = parts[2].split('.');
    if (p.length != 2) throw const FormatException('Invalid time format');
    final p2 = int.parse(p[1]);
    microseconds = p2 % 1000;
    milliseconds = p2 ~/ 1000;

    seconds = int.parse(p[0]);
  }

  minutes = int.parse(parts[1]);
  {
    int p = int.parse(parts[0]);
    hours = p % 24;
    days = p ~/ 24;
  }

  return Duration(
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
      microseconds: microseconds);
}
