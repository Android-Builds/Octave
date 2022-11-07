import 'package:octave/api/youtube_api.dart';
import 'package:octave/blocs/api_call_bloc/api_call_bloc.dart';
import 'package:octave/pages/moods_and_genre.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/player_manager.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  static final ApiCallBloc bloc = ApiCallBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: BlocBuilder<ApiCallBloc, ApiCallBlocState>(
        bloc: bloc,
        builder: (context, state) {
          if (state is ApiCallBlocInitial) {
            bloc.add(const FetchApiWithNoParams(YtmApi.getMoodsAndGenres));
            return SizedBox(
              height: PlayerManager.size.height * 0.8,
              child: const Center(child: CircularProgressIndicator()),
            );
          } else if (state is ApiCallBlocLaoding) {
            return SizedBox(
              height: PlayerManager.size.height * 0.8,
              child: const Center(child: CircularProgressIndicator()),
            );
          } else if (state is ApiCallBlocFinal) {
            List<dynamic> moodsAndGenres = state.data;
            return ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: moodsAndGenres.length,
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                        color: Color(moodsAndGenres[index]['items']
                                [internalIndex]['color'])
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
              child: const Center(child: Text('Error')),
            );
          }
        },
      ),
    );
  }
}
