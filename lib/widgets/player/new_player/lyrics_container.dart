import 'package:audio_service/audio_service.dart';
import 'package:beats/api/youtube_api.dart';
import 'package:beats/blocs/api_call_bloc/api_call_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LyricsContainer extends StatelessWidget {
  const LyricsContainer({
    Key? key,
    required this.mediaItem,
  }) : super(key: key);

  final MediaItem mediaItem;
  static final ApiCallBloc bloc = ApiCallBloc();
  static String mediaItemId = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApiCallBloc, ApiCallBlocState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is ApiCallBlocInitial) {
          bloc.add(
            FetchApiWithTwoParams(
              YtmApi.getLyrics,
              mediaItem.extras!['playlistId'],
              mediaItem.id,
            ),
          );
          return const Center(child: CircularProgressIndicator());
        } else if (state is ApiCallBlocLaoding) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ApiCallBlocFinal) {
          if (mediaItem.id != mediaItemId) {
            bloc.add(
              FetchApiWithTwoParams(
                YtmApi.getLyrics,
                mediaItem.extras!['playlistId'],
                mediaItem.id,
              ),
            );
          }
          final String lyrics = state.data;
          mediaItemId = mediaItem.id;
          if (lyrics.isEmpty) {
            return const Text('No lyrics Available');
          } else {
            return ListView(
              padding: const EdgeInsets.all(10.0),
              children: [
                Text(
                  lyrics,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                )
              ],
            );
          }
        } else {
          return const Text('Error');
        }
      },
    );
  }
}
