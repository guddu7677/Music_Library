part of 'library_bloc.dart';

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();
  @override
  List<Object?> get props => [];
}

class LibraryStarted extends LibraryEvent {
  const LibraryStarted();
}

class LibraryLoadMoreRequested extends LibraryEvent {
  const LibraryLoadMoreRequested();
}

class LibrarySearchChanged extends LibraryEvent {
  final String query;
  const LibrarySearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class LibrarySearchCleared extends LibraryEvent {
  const LibrarySearchCleared();
}

class LibraryGroupByChanged extends LibraryEvent {
  final GroupBy groupBy;
  const LibraryGroupByChanged(this.groupBy);

  @override
  List<Object?> get props => [groupBy];
}
