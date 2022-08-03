import 'package:beats/api/youtube_api.dart';
import 'package:beats/blocs/search_bloc/search_bloc.dart';
import 'package:beats/classes/search_result.dart';
import 'package:beats/pages/artists_page.dart';
import 'package:beats/pages/playlist_page.dart';
import 'package:beats/utils/player_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UniversalSearchDelegate extends SearchDelegate<String> {
  @override
  void close(BuildContext context, String result) {
    PlayerManager.homePage = true;
    Future.delayed(const Duration(milliseconds: 50),
        () => PlayerManager.navbarHeight.value = kBottomNavigationBarHeight);
    super.close(context, result);
  }

  @override
  void showResults(BuildContext context) {
    BlocProvider.of<SearchBloc>(context).add(GetSearchResults(null, query));
    super.showResults(context);
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (BuildContext context, state) {
        if (state is SearchInitial || state is SearchLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is SearchLoaded) {
          return resultList(state.searchResults);
        } else {
          return Center(
              child: Column(
            children: const [
              Icon(Icons.error),
              SizedBox(height: 10.0),
              Text("Error"),
            ],
          ));
        }
      },
    );
  }

  Widget resultList(List<dynamic> searchResults) {
    return searchResults.first is Map
        ? ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    dense: true,
                    onTap: () => BlocProvider.of<SearchBloc>(context).add(
                      GetSearchResults(
                        searchResults[index]['data'][0].searchType,
                        query,
                      ),
                    ),
                    title: Text(
                      searchResults[index]['type'],
                      style: TextStyle(
                        fontSize: PlayerManager.size.width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: index == 0 ? null : const Text('More'),
                  ),
                  entityList(searchResults[index]['data'], false),
                ],
              );
            },
          )
        : entityList(searchResults, true);
  }

  Widget entityList(List searchResults, bool individual) {
    return ListView.builder(
      shrinkWrap: true,
      physics: individual ? null : const NeverScrollableScrollPhysics(),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        SearchResult searchResult = searchResults[index];
        return ListTile(
          onTap: () {
            if (searchResult.searchType == SearchType.albums ||
                searchResult.searchType == SearchType.playlists) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaylistPage(
                    playlistId: searchResult.entityId,
                    thumbnail: searchResult.thumbnail,
                  ),
                ),
              );
            } else if (searchResult.searchType == SearchType.artists) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArtistsPage(
                    imageUrl: searchResult.thumbnail,
                    title: searchResult.title,
                    artistId: searchResult.entityId,
                  ),
                ),
              );
            }
          },
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(
              searchResult.searchType == SearchType.artists ? 100.0 : 5.0,
            ),
            child: CachedNetworkImage(
              imageUrl: searchResult.thumbnail,
              height: 50.0,
              width: 50.0,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            searchResult.title,
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
          subtitle: Text(
            searchResult.subtitle,
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return query.isEmpty
        ? const SizedBox.shrink()
        : FutureBuilder(
            future: YoutubeMusicApi.getSearchSuggestions(query),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                List<List<dynamic>> suggestions = snapshot.data;
                return ListView.builder(
                  padding: const EdgeInsets.all(10.0),
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        query = suggestions[index].join();
                        showResults(context);
                      },
                      title: RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style.copyWith(
                                fontSize: PlayerManager.size.width * 0.045,
                              ),
                          children: List.generate(
                            suggestions[index].length,
                            (childIndex) => TextSpan(
                              text: suggestions[index][childIndex],
                              style: TextStyle(
                                fontWeight: childIndex == 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.north_west,
                          size: PlayerManager.size.width * 0.045,
                        ),
                        onPressed: () {
                          query = suggestions[index].join();
                        },
                      ),
                    );
                  },
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          );
  }
}
