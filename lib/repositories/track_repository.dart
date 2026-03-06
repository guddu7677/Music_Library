
import 'package:music_library/models/track.dart';
import 'package:music_library/models/track_detail.dart';
import 'package:music_library/services/api_service.dart';

const List<String> kQueryAlphabet = [
  'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j',
  'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
  'u', 'v', 'w', 'x', 'y', 'z',
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
];

class PageCursor {
  final int queryIndex;     
  final int pageIndex;      
  const PageCursor({required this.queryIndex, required this.pageIndex});

  static const PageCursor start = PageCursor(queryIndex: 0, pageIndex: 0);

  PageCursor next({required bool hasMore}) {
    if (hasMore) {
      return PageCursor(queryIndex: queryIndex, pageIndex: pageIndex + 50);
    }
    return PageCursor(queryIndex: queryIndex + 1, pageIndex: 0);
  }

  bool get isExhausted => queryIndex >= kQueryAlphabet.length;
  String get query => isExhausted ? '' : kQueryAlphabet[queryIndex];
}

class TrackRepository {
  final ApiService _api;

  TrackRepository({ApiService? apiService})
      : _api = apiService ?? ApiService();

  Future<({List<Track> tracks, PageCursor nextCursor})> loadNextPage(
      PageCursor cursor) async {
    if (cursor.isExhausted) {
      return (tracks: <Track>[], nextCursor: cursor);
    }
    final page = await _api.fetchTracks(
      query: cursor.query,
      index: cursor.pageIndex,
      limit: 50,
    );
    final next = cursor.next(hasMore: page.hasMore);
    return (tracks: page.tracks, nextCursor: next);
  }

  Future<List<Track>> searchTracks(String query) async {
    if (query.trim().isEmpty) return [];
    final page = await _api.fetchTracks(query: query, index: 0, limit: 50);
    return page.tracks;
  }

  Future<TrackDetail> getTrackDetail(int trackId) =>
      _api.fetchTrackDetail(trackId);

  Future<Lyrics> getLyrics(int trackId) => _api.fetchLyrics(trackId);
}
