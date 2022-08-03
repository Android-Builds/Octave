import 'dart:convert';

import 'package:beats/classes/spotify_song.dart';
import 'package:http/http.dart';

class SpotifyApi {
  static final Map _countryCodes = {
    'Global': '37i9dQZEVXbMDoHDwVN2tF',
    'India': '37i9dQZEVXbLZ52XmnySJg'
  };

  static addToMap(String country, String code) => _countryCodes[country] = code;

  static Map getCountryCodes() => _countryCodes;

  static getTopSongs(String country) async {
    /* Method 1 to get Access Token

    Uri home = Uri.https('open.spotify.com', '');
    Response homepageResponse = await get(home);
    String authorization = json.decode(RegExp(
            r'("accessToken":".*","accessTokenExpirationTimestampMs")',
            dotAll: true)
        .firstMatch(homepageResponse.body)![1]!
        .replaceAll(',"accessTokenExpirationTimestampMs"', '')
        .replaceAll('"accessToken":', ''));
    */

    //Method 2 for access token

    Uri authUrl = Uri.https('open.spotify.com', 'get_access_token', {
      'reason': 'transport',
      'productType': 'web_player',
    });

    Response authResp = await get(authUrl, headers: {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36',
    });

    String authorization = jsonDecode(authResp.body)['accessToken'];

    Uri link = Uri.https(
        'api.spotify.com', '/v1/playlists/${_countryCodes[country]}/tracks', {
      'offset': '0',
      'limit': '100',
      'additional_types': 'track,episode',
    });

    Response response = await get(link, headers: {
      'authorization': 'Bearer $authorization',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36'
    });

    Map responseMap = json.decode(response.body);

    List items = responseMap['items'];

    return SpotifySong.getTopSpotifySongs(items);
  }
}
