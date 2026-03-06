import 'package:equatable/equatable.dart';

class TrackDetail extends Equatable {
  final int id;
  final String title;
  final String artistName;
  final String artistPicture;
  final String albumTitle;
  final String albumCover;
  final int duration;
  final int rank;
  final bool explicitLyrics;
  final String? preview;
  final String link;

  const TrackDetail({
    required this.id,
    required this.title,
    required this.artistName,
    required this.artistPicture,
    required this.albumTitle,
    required this.albumCover,
    required this.duration,
    required this.rank,
    required this.explicitLyrics,
    this.preview,
    required this.link,
  });

  factory TrackDetail.fromJson(Map<String, dynamic> json) {
    final artist = json['artist'] as Map<String, dynamic>? ?? {};
    final album = json['album'] as Map<String, dynamic>? ?? {};
    return TrackDetail(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      artistName: artist['name'] as String? ?? '',
      artistPicture: artist['picture_medium'] as String? ??
          artist['picture'] as String? ?? '',
      albumTitle: album['title'] as String? ?? '',
      albumCover: album['cover_medium'] as String? ??
          album['cover'] as String? ?? '',
      duration: json['duration'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
      explicitLyrics: json['explicit_lyrics'] as bool? ?? false,
      preview: json['preview'] as String?,
      link: json['link'] as String? ?? '',
    );
  }

  String get durationFormatted {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [id, title, artistName];
}

class Lyrics extends Equatable {
  final int trackId;
  final String? lyricsText;
  final bool available;

  const Lyrics({
    required this.trackId,
    this.lyricsText,
    required this.available,
  });

  factory Lyrics.notAvailable(int trackId) => Lyrics(
        trackId: trackId,
        lyricsText: null,
        available: false,
      );

  factory Lyrics.fromJson(Map<String, dynamic> json, int trackId) {
    final text = json['lyrics_text'] as String?;
    return Lyrics(
      trackId: trackId,
      lyricsText: text,
      available: text != null && text.isNotEmpty,
    );
  }

  @override
  List<Object?> get props => [trackId, available];
}
