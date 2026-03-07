import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_library/bloc/track_details/track_detail_event.dart';
import 'package:music_library/bloc/track_details/track_state.dart';
import 'package:music_library/models/track_detail.dart';
import 'package:music_library/repositories/track_repository.dart';
import 'package:music_library/services/api_service.dart';


class TrackDetailBloc extends Bloc<TrackDetailEvent, TrackDetailState> {
  final TrackRepository _repository;

  TrackDetailBloc({TrackRepository? repository})
      : _repository = repository ?? TrackRepository(),
        super(const TrackDetailState()) {
    on<TrackDetailLoaded>(_onLoaded);
    on<TrackDetailRetried>(_onRetried);
  }

  Future<void> _onLoaded(
      TrackDetailLoaded event, Emitter<TrackDetailState> emit) async {
    emit(state.copyWith(
      detailStatus: TrackDetailStatus.loading,
      lyricsStatus: TrackDetailStatus.loading,
    ));
    await _fetchAll(event.trackId, emit);
  }

  Future<void> _onRetried(
      TrackDetailRetried event, Emitter<TrackDetailState> emit) async {
    emit(const TrackDetailState(
      detailStatus: TrackDetailStatus.loading,
      lyricsStatus: TrackDetailStatus.loading,
    ));
    await _fetchAll(event.trackId, emit);
  }

  Future<void> _fetchAll(int trackId, Emitter<TrackDetailState> emit) async {
    final results = await Future.wait([
      _repository
          .getTrackDetail(trackId)
          .then<Object>((d) => d)
          .catchError((e) => e is Exception ? e : Exception(e.toString())),
      _repository
          .getLyrics(trackId)
          .then<Object>((l) => l)
          .catchError((e) => e is Exception ? e : Exception(e.toString())),
    ]);

    final detailResult = results[0];
    final lyricsResult = results[1];

    TrackDetailStatus detailStatus;
    TrackDetail? detail;
    String? detailError;

    if (detailResult is TrackDetail) {
      detailStatus = TrackDetailStatus.success;
      detail = detailResult;
    } else if (detailResult is NoInternetException) {
      detailStatus = TrackDetailStatus.noInternet;
      detailError = 'NO INTERNET CONNECTION';
    } else {
      detailStatus = TrackDetailStatus.failure;
      detailError = detailResult.toString();
    }

    TrackDetailStatus lyricsStatus;
    Lyrics? lyrics;
    String? lyricsError;

    if (lyricsResult is Lyrics) {
      lyricsStatus = TrackDetailStatus.success;
      lyrics = lyricsResult;
    } else if (lyricsResult is NoInternetException) {
      lyricsStatus = TrackDetailStatus.noInternet;
      lyricsError = 'NO INTERNET CONNECTION';
    } else {
      lyricsStatus = TrackDetailStatus.failure;
      lyricsError = lyricsResult.toString();
    }

    emit(state.copyWith(
      detailStatus: detailStatus,
      lyricsStatus: lyricsStatus,
      detail: detail,
      lyrics: lyrics,
      detailError: detailError,
      lyricsError: lyricsError,
    ));
  }
}