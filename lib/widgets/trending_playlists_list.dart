import 'package:beats/utils/player_manager.dart';
import 'package:beats/widgets/playlist_item.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../classes/trending_playlists.dart';
import '../pages/playlist_page.dart';

class TrendingPlaylistWidget extends StatefulWidget {
  final String title;
  final List<TrendingPlaylists> trendingPlaylists;

  const TrendingPlaylistWidget({
    Key? key,
    required this.trendingPlaylists,
    required this.title,
  }) : super(key: key);

  @override
  State<TrendingPlaylistWidget> createState() => _TrendingPlaylistWidgetState();
}

class _TrendingPlaylistWidgetState extends State<TrendingPlaylistWidget> {
  final CarouselController _controller = CarouselController();
  final ValueNotifier<int> _index = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 10.0,
        ),
        child: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
              right: 10.0,
              left: 10.0,
            ),
            child: SizedBox(
              height: PlayerManager.size.height * 0.18,
              child: CarouselSlider(
                carouselController: _controller,
                items: List.generate(
                  widget.trendingPlaylists.length,
                  (index) => GestureDetector(
                    onTap: () async {
                      if (widget.title == 'Recommended music videos') {
                        List<String> id = widget
                            .trendingPlaylists[index].playlistId
                            .split(':');
                        PlayerManager.playMusic(id[1], id[0], widget.title);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaylistPage(
                              playlistId:
                                  widget.trendingPlaylists[index].playlistId,
                              thumbnail:
                                  widget.trendingPlaylists[index].thumbnail,
                            ),
                          ),
                        );
                      }
                    },
                    child: PlaylistItem(
                      title: widget.trendingPlaylists[index].title,
                      subtitle: widget.trendingPlaylists[index].subtitle,
                      thumbnail: widget.trendingPlaylists[index].thumbnail,
                    ),
                  ),
                ),
                options: CarouselOptions(
                  height: PlayerManager.size.height * 0.3,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.8,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: false,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: false,
                  onPageChanged: (index, reason) {
                    _index.value = index;
                  },
                  scrollDirection: Axis.horizontal,
                ),
              ),
            ),
          ),
          ValueListenableBuilder(
              valueListenable: _index,
              builder: (context, index, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      widget.trendingPlaylists.asMap().entries.map((entry) {
                    return Container(
                      width: 5.0,
                      height: 5.0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(index == entry.key ? 0.9 : 0.4),
                      ),
                    );
                  }).toList(),
                );
              }),
        ],
      )
    ]);
  }
}
