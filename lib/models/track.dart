import 'package:equatable/equatable.dart';

class TrackArtist extends Equatable {
  final int id;
  final String name;
  final String? pictureSmall;
  final String? pictureMedium;
  final String? pictureBig;

  const TrackArtist({
    required this.id,
    required this.name,
    this.pictureSmall,
    this.pictureMedium,
    this.pictureBig,
  });

  factory TrackArtist.fromJson(Map<String, dynamic> json) => TrackArtist(
        id: json['id'] as int,
        name: json['name'] as String,
        pictureSmall: json['picture_small'] as String?,
        pictureMedium: json['picture_medium'] as String?,
        pictureBig: json['picture_big'] as String?,
      );

  @override
  List<Object?> get props => [id, name];
}

class TrackAlbum extends Equatable {
  final int id;
  final String title;
  final String? coverSmall;
  final String? coverMedium;
  final String? coverBig;

  const TrackAlbum({
    required this.id,
    required this.title,
    this.coverSmall,
    this.coverMedium,
    this.coverBig,
  });

  factory TrackAlbum.fromJson(Map<String, dynamic> json) => TrackAlbum(
        id: json['id'] as int,
        title: json['title'] as String,
        coverSmall: json['cover_small'] as String?,
        coverMedium: json['cover_medium'] as String?,
        coverBig: json['cover_big'] as String?,
      );

  @override
  List<Object?> get props => [id, title];
}

class Track extends Equatable {
  final int id;
  final String title;
  final String titleShort;
  final String link;
  final int duration;
  final int rank;
  final bool explicitLyrics;
  final String? preview;
  final TrackArtist artist;
  final TrackAlbum album;

  const Track({
    required this.id,
    required this.title,
    required this.titleShort,
    required this.link,
    required this.duration,
    required this.rank,
    required this.explicitLyrics,
    this.preview,
    required this.artist,
    required this.album,
  });

  factory Track.fromJson(Map<String, dynamic> json) => Track(
        id: json['id'] as int,
        title: json['title'] as String,
        titleShort: json['title_short'] as String,
        link: json['link'] as String,
        duration: json['duration'] as int,
        rank: json['rank'] as int,
        explicitLyrics: json['explicit_lyrics'] as bool? ?? false,
        preview: json['preview'] as String?,
        artist: TrackArtist.fromJson(json['artist'] as Map<String, dynamic>),
        album: TrackAlbum.fromJson(json['album'] as Map<String, dynamic>),
      );

  String get durationFormatted {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get groupKey {
    final first = title.isNotEmpty ? title[0].toUpperCase() : '#';
    if (RegExp(r'[A-Z]').hasMatch(first)) return first;
    if (RegExp(r'[0-9]').hasMatch(first)) return '#';
    return '#';
  }

  @override
  List<Object?> get props => [id, title, artist, album];
}
