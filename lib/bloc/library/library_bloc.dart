import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_library/models/track.dart';
import 'package:music_library/repositories/track_repository.dart';
import 'package:music_library/services/api_service.dart';

part 'library_event.dart';
part 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final TrackRepository _repository;
  Timer? _searchDebounce;

  LibraryBloc({TrackRepository? repository})
      : _repository = repository ?? TrackRepository(),
        super(const LibraryState()) {
    on<LibraryStarted>(_onStarted);
    on<LibraryLoadMoreRequested>(_onLoadMore);
    on<LibrarySearchChanged>(_onSearchChanged);
    on<LibrarySearchCleared>(_onSearchCleared);
    on<LibraryGroupByChanged>(_onGroupByChanged);
    on<_LibrarySearchAPIRequested>(_onSearchAPI);
  }

  Future<void> _onStarted(
      LibraryStarted event, Emitter<LibraryState> emit) async {
    emit(state.copyWith(status: LibraryStatus.loading));
    await _loadPage(emit, cursor: PageCursor.start, existingTracks: []);
  }

  Future<void> _onLoadMore(
      LibraryLoadMoreRequested event, Emitter<LibraryState> emit) async {
    if (state.isLoadingMore ||
        state.hasReachedMax ||
        state.searchQuery.isNotEmpty) return;

    emit(state.copyWith(isLoadingMore: true));
    await _loadPage(emit,
        cursor: state.cursor, existingTracks: state.allTracks);
  }

  Future<void> _loadPage(
    Emitter<LibraryState> emit, {
    required PageCursor cursor,
    required List<Track> existingTracks,
  }) async {
    try {
      final result = await _repository.loadNextPage(cursor);
      final merged = [...existingTracks, ...result.tracks];
      final displayItems = _buildDisplayItems(merged, state.groupBy);

      emit(state.copyWith(
        status: LibraryStatus.success,
        allTracks: merged,
        displayItems: displayItems,
        isLoadingMore: false,
        hasReachedMax: result.nextCursor.isExhausted,
        cursor: result.nextCursor,
      ));
    } on NoInternetException {
      emit(state.copyWith(
        status: existingTracks.isEmpty
            ? LibraryStatus.noInternet
            : LibraryStatus.success,
        isLoadingMore: false,
        errorMessage: 'NO INTERNET CONNECTION',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: existingTracks.isEmpty
            ? LibraryStatus.failure
            : LibraryStatus.success,
        isLoadingMore: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSearchChanged(
      LibrarySearchChanged event, Emitter<LibraryState> emit) {
    _searchDebounce?.cancel();
    final query = event.query.trim();

    if (query.isEmpty) {
      final displayItems = _buildDisplayItems(state.allTracks, state.groupBy);
      emit(state.copyWith(
        searchQuery: '',
        displayItems: displayItems,
        status: LibraryStatus.success,
      ));
      return;
    }

    final localFiltered = state.allTracks.where((t) {
      final q = query.toLowerCase();
      return t.title.toLowerCase().contains(q) ||
          t.artist.name.toLowerCase().contains(q);
    }).toList();

    emit(state.copyWith(
      searchQuery: query,
      displayItems: _buildDisplayItems(localFiltered, state.groupBy),
      status: LibraryStatus.success,
    ));

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      add(_LibrarySearchAPIRequested(query));
    });
  }

  Future<void> _onSearchAPI(
      _LibrarySearchAPIRequested event, Emitter<LibraryState> emit) async {
    if (state.searchQuery != event.query) return;

    try {
      final results = await _repository.searchTracks(event.query);
      final ids = {for (final t in state.allTracks) t.id};
      final fresh = results.where((t) => !ids.contains(t.id)).toList();
      final merged = [...state.allTracks, ...fresh];

      final q = event.query.toLowerCase();
      final filtered = merged.where((t) {
        return t.title.toLowerCase().contains(q) ||
            t.artist.name.toLowerCase().contains(q);
      }).toList();

      emit(state.copyWith(
        allTracks: merged,
        displayItems: _buildDisplayItems(filtered, state.groupBy),
        status: LibraryStatus.success,
      ));
    } on NoInternetException {
      emit(state.copyWith(errorMessage: 'NO INTERNET CONNECTION'));
    } catch (_) {}
  }

  void _onSearchCleared(
      LibrarySearchCleared event, Emitter<LibraryState> emit) {
    _searchDebounce?.cancel();
    emit(state.copyWith(
      searchQuery: '',
      displayItems: _buildDisplayItems(state.allTracks, state.groupBy),
      status: LibraryStatus.success,
    ));
  }

  void _onGroupByChanged(
      LibraryGroupByChanged event, Emitter<LibraryState> emit) {
    final tracks = state.searchQuery.isEmpty
        ? state.allTracks
        : state.displayItems
            .whereType<TrackListItem>()
            .map((i) => i.track)
            .toList();
    emit(state.copyWith(
      groupBy: event.groupBy,
      displayItems: _buildDisplayItems(tracks, event.groupBy),
    ));
  }

  List<ListItem> _buildDisplayItems(List<Track> tracks, GroupBy groupBy) {
    if (tracks.isEmpty) return [];

    final sorted = [...tracks];
    if (groupBy == GroupBy.title) {
      sorted.sort((a, b) => a.title.compareTo(b.title));
    } else {
      sorted.sort((a, b) {
        final c = a.artist.name.compareTo(b.artist.name);
        return c != 0 ? c : a.title.compareTo(b.title);
      });
    }

    final items = <ListItem>[];
    String? currentKey;

    for (final track in sorted) {
      final key = groupBy == GroupBy.title
          ? track.groupKey
          : _artistGroupKey(track.artist.name);

      if (key != currentKey) {
        currentKey = key;
        items.add(StickyHeaderItem(key));
      }
      items.add(TrackListItem(track));
    }
    return items;
  }

  String _artistGroupKey(String name) {
    if (name.isEmpty) return '#';
    final first = name[0].toUpperCase();
    return RegExp(r'[A-Z]').hasMatch(first) ? first : '#';
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}

class _LibrarySearchAPIRequested extends LibraryEvent {
  final String query;
  const _LibrarySearchAPIRequested(this.query);
  @override
  List<Object?> get props => [query];
}
