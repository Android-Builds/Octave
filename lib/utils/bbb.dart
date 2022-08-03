/*
getMusic() async {
  YoutubeExplode youtubeExplode = YoutubeExplode();

  final Uri link = Uri.https('music.youtube.com', '');

  final Response response = await get(link, headers: {
    'user-agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36'
  });

  print(response.body.length);

  final String searchResults =
      RegExp(r"(\\x22\\x7d'\), data: .*}\);ytcfg)", dotAll: true)
          .firstMatch(response.body)![1]!;

  final newString = searchResults
      .replaceAllMapped(RegExp(r'\\x\d\w'), (match) {
        return String.fromCharCode(
            int.parse(match.group(0)!.substring(2), radix: 16));
      })
      .substring(13)
      .replaceAll("'});ytcfg", "")
      .trim();

  final Map data = json.decode(newString) as Map;

  print(data);

  // You can provide either a video ID or URL as String or an instance of `VideoId`.
  // var video = await youtubeExplode.videos
  //     .get('https://music.youtube.com/watch?v=U0JYkRqU6eY');
  // var title = video.title;
  // var author = video.author;
  // var duration = video.duration;
  // debugPrint(title + author + duration.toString());
}
*/

/*
static var body2 = {
    "context": {
      "client": {
        "hl": "en",
        "gl": "IN",
        "remoteHost": "103.27.2.60",
        "deviceMake": "",
        "deviceModel": "",
        "visitorData": "CgtMSXYtb3hNQkdfayiVm8qVBg%3D%3D",
        "userAgent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36,gzip(gfe)",
        "clientName": "WEB_REMIX",
        "clientVersion": "1.20220613.01.00",
        "osName": "Windows",
        "osVersion": "10.0",
        "originalUrl": "https://music.youtube.com/",
        "platform": "DESKTOP",
        "clientFormFactor": "UNKNOWN_FORM_FACTOR",
        "configInfo": {
          "appInstallData":
              "CJWbypUGELfLrQUQ1IOuBRD9uP0SEJSPrgUQmIeuBRCY3v0SELiLrgUQgo6uBRDYvq0F"
        },
        "browserName": "Chrome",
        "browserVersion": "103.0.0.0",
        "screenWidthPoints": 1536,
        "screenHeightPoints": 714,
        "screenPixelDensity": 1,
        "screenDensityFloat": 1.25,
        "utcOffsetMinutes": 330,
        "userInterfaceTheme": "USER_INTERFACE_THEME_DARK",
        "timeZone": "Asia/Calcutta",
        "musicAppInfo": {
          "pwaInstallabilityStatus": "PWA_INSTALLABILITY_STATUS_UNKNOWN",
          "webDisplayMode": "WEB_DISPLAY_MODE_BROWSER",
          "storeDigitalGoodsApiSupportStatus": {
            "playStoreDigitalGoodsApiSupportStatus":
                "DIGITAL_GOODS_API_SUPPORT_STATUS_UNSUPPORTED"
          },
          "musicActivityMasterSwitch":
              "MUSIC_ACTIVITY_MASTER_SWITCH_INDETERMINATE",
          "musicLocationMasterSwitch":
              "MUSIC_LOCATION_MASTER_SWITCH_INDETERMINATE"
        }
      },
      "user": {"lockedSafetyMode": false},
      "request": {
        "useSsl": true,
        "internalExperimentFlags": [],
        "consistencyTokenJars": []
      },
    }
  };
  */


/*
  playSongs(List<Video> playlistSongs) async {
    List<MediaItem> items = [];
    Stopwatch stopwatch = Stopwatch()..start();
    int index = 0;
    while (stopwatch.elapsed.inSeconds <= 1) {
      items.add(
        MediaItem(
          id: await YoutubeMusicApi.getSongUrl(playlistSongs[index].id.value),
          title: playlistSongs[index].title,
          artist: playlistSongs[index].author,
          duration: playlistSongs[index].duration,
          artUri: Uri.parse(playlistSongs[index].thumbnails.highResUrl),
        ),
      );
      index++;
    }
    audioHandler.updateQueue(items);
    audioHandler.skipToQueueItem(0);
    panelController.open();
    audioHandler.play();
    stopwatch.stop();
    playlistSongs = playlistSongs.sublist(index);
    stopwatch.reset();
    stopwatch.start();
    index = 0;
    while (playlistSongs.isNotEmpty) {
      index = 0;
      while (stopwatch.elapsed.inSeconds <= 3) {
        items.add(
          MediaItem(
            id: await YoutubeMusicApi.getSongUrl(playlistSongs[index].id.value),
            title: playlistSongs[index].title,
            artist: playlistSongs[index].author,
            duration: playlistSongs[index].duration,
            artUri: Uri.parse(playlistSongs[index].thumbnails.highResUrl),
          ),
        );
        index++;
      }
      await audioHandler.addQueueItems(items);
      stopwatch.reset();
      playlistSongs = playlistSongs.sublist(index);
    }
    //await addRest(playlistSongs);
  }
  */

// TransitionAppBar(
//   // extent: 250,
//   extent: size.height * 0.5,
//   avatar: Container(
//     decoration: BoxDecoration(
//         image: DecorationImage(
//             image: CachedNetworkImageProvider(widget
//                 .thumbnail), // NetworkImage(user.imageUrl),
//             fit: BoxFit.cover)),
//   ),
//   title: "Emmanuel Olu-Flourish",
// ),

// SliverLayoutBuilder(
//   builder: (BuildContext context, constraints) {
//     print(constraints.scrollOffset);
//     final scrolled = constraints.scrollOffset > 200;
//     return SliverAppBar(
//       actions: [
//         IconButton(
//           onPressed: () {
//             showSearch(
//               context: context,
//               delegate: PlaylistSearchDelegate(
//                 playlistSongs: playlistSongs,
//               ),
//             );
//           },
//           icon: const Icon(Icons.search),
//         )
//       ],
//       stretch: true,
//       expandedHeight: size.height * 0.55,
//       floating: false,
//       pinned: true,
//       flexibleSpace: FlexibleSpaceBar(
//         title: AnimatedCrossFade(
//           duration: const Duration(milliseconds: 1000),
//           firstChild: Text(playlist.title),
//           secondChild: Container(),
//           crossFadeState: scrolled
//               ? CrossFadeState.showFirst
//               : CrossFadeState.showSecond,
//         ),
//         background: Column(
//           children: [
//             const SizedBox(height: kToolbarHeight),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(
//                 10,
//                 0,
//                 10,
//                 10,
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(5.0),
//                 child: CachedNetworkImage(
//                   imageUrl: widget.thumbnail,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(
//                   vertical: 10.0),
//               child: Text(
//                 playlist.title,
//                 style: TextStyle(
//                   fontSize: size.width * 0.06,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     shape: const CircleBorder(),
//                     padding: const EdgeInsets.all(20),
//                   ),
//                   onPressed: () async {
//                     playSongs(playlistSongs, playlist);
//                   },
//                   child: const Icon(Icons.play_arrow),
//                 ),
//                 const SizedBox(width: 10.0),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     shape: const CircleBorder(),
//                     padding: const EdgeInsets.all(20),
//                   ),
//                   onPressed: () {},
//                   child: const Icon(Icons.shuffle),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   },
// )

/*
 *    // onNotification: (details) {
      //   final maxHeight =
      //       (kBottomNavigationBarHeight * 1.43).roundToDouble();
      //   double pixelsScrolled =
      //       details.scrollDelta!.abs().clamp(0, maxHeight);
      //   double height = navbarHeight.value;
      //   if (details.scrollDelta! > 0.0 &&
      //       details.metrics.axis == Axis.vertical) {
      //     height -= pixelsScrolled;
      //   } else {
      //     height += pixelsScrolled;
      //   }
      //   navbarHeight.value = height.clamp(0, maxHeight);
      //   return false;
      // },
 */