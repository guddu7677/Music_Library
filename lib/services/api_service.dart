import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:music_library/models/track.dart';
import 'package:music_library/models/track_detail.dart';

class NoInternetException implements Exception {
  const NoInternetException();

  @override
  String toString() => 'NO INTERNET CONNECTION';
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const String _baseUrl = 'http://5.78.43.182:5050';
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> _get(String path,
      {Map<String, String>? params}) async {
    try {
      final uri = Uri.parse('$_baseUrl$path')
          .replace(queryParameters: params);
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException('Server error: ${response.statusCode}');
      }
    } on SocketException {
      throw  NoInternetException();
    } on HttpException {
      throw  NoInternetException();
    } on HandshakeException {
      throw  NoInternetException();
    } catch (e) {
      if (e is NoInternetException || e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  Future<TracksPage> fetchTracks({
    String query = 'a',
    int index = 0,
    int limit = 50,
  }) async {
    final data = await _get('/tracks', params: {
      'q': query,
      'index': index.toString(),
      'limit': limit.toString(),
    });
    final trackList = (data['tracks'] as List<dynamic>? ?? [])
        .map((e) => Track.fromJson(e as Map<String, dynamic>))
        .toList();
    return TracksPage(
      tracks: trackList,
      query: data['query'] as String? ?? query,
      index: data['index'] as int? ?? index,
      limit: data['limit'] as int? ?? limit,
    );
  }

  Future<TrackDetail> fetchTrackDetail(int trackId) async {
    try {
      final uri = Uri.parse('https://api.deezer.com/track/$trackId');
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data.containsKey('error')) {
          throw ApiException('Track not found');
        }
        return TrackDetail.fromJson(data);
      }
      throw ApiException('Failed to load track details');
    } on SocketException {
      throw const NoInternetException();
    } on HttpException {
      throw const NoInternetException();
    } catch (e) {
      if (e is NoInternetException || e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  Future<Lyrics> fetchLyrics(int trackId) async {
    return Lyrics.notAvailable(trackId);
  }
}

class TracksPage {
  final List<Track> tracks;
  final String query;
  final int index;
  final int limit;

  const TracksPage({
    required this.tracks,
    required this.query,
    required this.index,
    required this.limit,
  });

  bool get hasMore => tracks.length >= limit;
}
