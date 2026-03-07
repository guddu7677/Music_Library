import 'package:equatable/equatable.dart';

import 'package:music_library/models/track_detail.dart';


enum TrackDetailStatus { initial, loading, success, failure, noInternet }

class TrackDetailState extends Equatable {
  final TrackDetailStatus detailStatus;
  final TrackDetailStatus lyricsStatus;
  final TrackDetail? detail;
  final Lyrics? lyrics;
  final String? detailError;
  final String? lyricsError;

  const TrackDetailState({
    this.detailStatus = TrackDetailStatus.initial,
    this.lyricsStatus = TrackDetailStatus.initial,
    this.detail,
    this.lyrics,
    this.detailError,
    this.lyricsError,
  });

  TrackDetailState copyWith({
    TrackDetailStatus? detailStatus,
    TrackDetailStatus? lyricsStatus,
    TrackDetail? detail,
    Lyrics? lyrics,
   
    Object? detailError = _sentinel,
    Object? lyricsError = _sentinel,
  }) {
    return TrackDetailState(
      detailStatus: detailStatus ?? this.detailStatus,
      lyricsStatus: lyricsStatus ?? this.lyricsStatus,
      detail: detail ?? this.detail,
      lyrics: lyrics ?? this.lyrics,
      detailError:
          detailError == _sentinel ? this.detailError : detailError as String?,
      lyricsError:
          lyricsError == _sentinel ? this.lyricsError : lyricsError as String?,
    );
  }

  @override
  List<Object?> get props => [
        detailStatus,
        lyricsStatus,
        detail,
        lyrics,
        detailError,
        lyricsError,
      ];
}

const Object _sentinel = Object();