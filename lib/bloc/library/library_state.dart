part of 'library_bloc.dart';

enum GroupBy { title, artist }

enum LibraryStatus { initial, loading, success, failure, noInternet }

abstract class ListItem extends Equatable {
  const ListItem();
}

class StickyHeaderItem extends ListItem {
  final String label;
  const StickyHeaderItem(this.label);

  @override
  List<Object?> get props => [label];
}

class TrackListItem extends ListItem {
  final Track track;
  const TrackListItem(this.track);

  @override
  List<Object?> get props => [track.id];
}

class LibraryState extends Equatable {
  final LibraryStatus status;
  final List<Track> allTracks;        
  final List<ListItem> displayItems;  
  final bool isLoadingMore;
  final bool hasReachedMax;
  final String searchQuery;
  final GroupBy groupBy;
  final String? errorMessage;
  final PageCursor cursor;

  const LibraryState({
    this.status = LibraryStatus.initial,
    this.allTracks = const [],
    this.displayItems = const [],
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.searchQuery = '',
    this.groupBy = GroupBy.title,
    this.errorMessage,
    this.cursor = PageCursor.start,
  });

  LibraryState copyWith({
    LibraryStatus? status,
    List<Track>? allTracks,
    List<ListItem>? displayItems,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? searchQuery,
    GroupBy? groupBy,
    String? errorMessage,
    PageCursor? cursor,
  }) {
    return LibraryState(
      status: status ?? this.status,
      allTracks: allTracks ?? this.allTracks,
      displayItems: displayItems ?? this.displayItems,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
      groupBy: groupBy ?? this.groupBy,
      errorMessage: errorMessage,
      cursor: cursor ?? this.cursor,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allTracks.length, 
        displayItems.length,
        isLoadingMore,
        hasReachedMax,
        searchQuery,
        groupBy,
        errorMessage,
        cursor.queryIndex,
        cursor.pageIndex,
      ];
}
