import 'package:beats/api/youtube_api.dart';
import 'package:beats/pages/moods_and_genre.dart';
import 'package:flutter/material.dart';

import '../utils/player_manager.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: YoutubeMusicApi.getMoodsAndGenres(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          List<dynamic> moodsAndGenres = snapshot.data;
          return ListView.builder(
            padding: const EdgeInsets.all(10.0),
            shrinkWrap: true,
            itemCount: moodsAndGenres.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => Column(
              children: [
                ListTile(
                  dense: true,
                  title: Text(
                    moodsAndGenres[index]['title'],
                    style: TextStyle(
                      fontSize: PlayerManager.size.width * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  itemCount: moodsAndGenres[index]['items'].length,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                  ),
                  itemBuilder: (context, internalIndex) => InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MoodsAndGenres(
                            moodsAndGenreMap: moodsAndGenres[index]['items']
                                [internalIndex],
                          ),
                        )),
                    child: Card(
                      color: Color(moodsAndGenres[index]['items'][internalIndex]
                              ['color'])
                          .withOpacity(0.1),
                      child: Center(
                        child: Text(
                          moodsAndGenres[index]['items'][internalIndex]
                              ['title'],
                          style: TextStyle(
                              fontSize: PlayerManager.size.width * 0.04),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return SizedBox(
            height: PlayerManager.size.height * 0.8,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
