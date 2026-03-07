import 'package:equatable/equatable.dart';


abstract class TrackDetailEvent extends Equatable {
  const TrackDetailEvent();

  @override
  List<Object?> get props => [];
}

class TrackDetailLoaded extends TrackDetailEvent {
  final int trackId;
  const TrackDetailLoaded(this.trackId);

  @override
  List<Object?> get props => [trackId];
}

class TrackDetailRetried extends TrackDetailEvent {
  final int trackId;
  const TrackDetailRetried(this.trackId);

  @override
  List<Object?> get props => [trackId];
}