library utility;

String mapToText(Map textMap) {
  List textList = textMap['runs'];
  if (textList.first['text'] == 'Playlist') {
    textList = textList.sublist(2);
  }
  return textList.map((e) => e['text']).toList().join();
}
