import 'package:octave/api/spotify_api.dart';
import 'package:octave/classes/spotify_song.dart';
import 'package:octave/utils/player_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SpotifyTopCharts extends StatefulWidget {
  const SpotifyTopCharts({Key? key}) : super(key: key);

  @override
  State<SpotifyTopCharts> createState() => _SpotifyTopChartsState();
}

class _SpotifyTopChartsState extends State<SpotifyTopCharts> {
  int _value = 1;
  final TextEditingController _country = TextEditingController();
  final TextEditingController _url = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Map countryCodes = SpotifyApi.getCountryCodes();
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: PlayerManager.size.height * 0.08,
          child: NotificationListener<OverscrollNotification>(
            // Suppress OverscrollNotification events that escape from the inner scrollable
            onNotification: (notification) =>
                notification.metrics.axisDirection != AxisDirection.down,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: countryCodes.length + 1,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: index < countryCodes.length
                    ? ChoiceChip(
                        padding: const EdgeInsets.all(5.0),
                        label: Text(countryCodes.keys.elementAt(index)),
                        selected: _value == index,
                        onSelected: (bool selected) {
                          setState(() {
                            _value = selected ? index : 1;
                          });
                        },
                      )
                    : ActionChip(
                        padding: const EdgeInsets.all(5.0),
                        avatar: const Icon(Icons.add),
                        label: const Text('Add'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Add Country'),
                                content: Wrap(
                                  children: [
                                    TextField(
                                      controller: _country,
                                      decoration: const InputDecoration(
                                        hintText: 'Country',
                                      ),
                                    ),
                                    TextField(
                                      controller: _url,
                                      decoration: const InputDecoration(
                                        hintText: 'Link to Top Songs Playlist',
                                      ),
                                    ),
                                  ],
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      _url.clear();
                                      _country.clear();
                                      Navigator.pop(context);
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Add'),
                                    onPressed: () {
                                      SpotifyApi.addToMap(_country.text,
                                          _url.text.split('/').last);
                                      _url.clear();
                                      _country.clear();
                                      Navigator.pop(context);
                                      setState(() {});
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }),
              ),
            ),
          ),
        ),
        FutureBuilder(
          future: SpotifyApi.getTopSongs(countryCodes.keys.elementAt(_value)),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              List<SpotifySong> songs = snapshot.data;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: CachedNetworkImage(
                        imageUrl: songs[index].thumbnail,
                        height: 50,
                        width: 50,
                      ),
                    ),
                    title: Text(
                      songs[index].title,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      songs[index].artists.replaceAll(",", ", "),
                      style:
                          TextStyle(fontSize: PlayerManager.size.width * 0.03),
                    ),
                  );
                },
              );
            } else {
              return SizedBox(
                height: PlayerManager.size.height * 0.8,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
