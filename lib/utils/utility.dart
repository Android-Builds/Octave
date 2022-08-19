library utility;

String mapToText(Map textMap) {
  if (textMap.isEmpty) return '';
  List textList = textMap['runs'];
  if (textList.first['text'] == 'Playlist') {
    textList = textList.sublist(2);
  }
  return textList.map((e) => e['text']).toList().join();
}
