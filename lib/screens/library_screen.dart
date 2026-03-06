import 'package:flutter/material.dart';
import 'package:music_library/models/track.dart';
import 'package:music_library/repositories/track_repository.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {

  final TrackRepository _repository = TrackRepository();

  final ScrollController _scrollController = ScrollController();

  final TextEditingController _searchController = TextEditingController();

  List<Track> tracks = [];

  PageCursor cursor = PageCursor.start;

  bool isLoading = false;

  bool isSearching = false;

  @override
  void initState() {
    super.initState();

    loadTracks();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 200) {
      loadTracks();
    }
  }

  Future<void> loadTracks() async {
    if (isLoading || cursor.isExhausted || isSearching) return;

    setState(() {
      isLoading = true;
    });

    final result = await _repository.loadNextPage(cursor);

    setState(() {
      tracks.addAll(result.tracks);
      cursor = result.nextCursor;
      isLoading = false;
    });
  }

  Future<void> searchTracks(String query) async {

    if (query.trim().isEmpty) {
      setState(() {
        isSearching = false;
        tracks.clear();
        cursor = PageCursor.start;
      });

      loadTracks();
      return;
    }

    setState(() {
      isSearching = true;
    });

    final results = await _repository.searchTracks(query);

    setState(() {
      tracks = results;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        children: [

          _AppHeader(totalTracks: tracks.length),

          _SearchBar(
            controller: _searchController,
            onChanged: searchTracks,
          ),

           _GroupByToggle(),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: tracks.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {

                if (index >= tracks.length) {
                  return  Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final track = tracks[index];

                return ListTile(
                  leading:  CircleAvatar(
                    child: Icon(Icons.music_note),
                  ),

                  title: Text(
                    track.title,
                    style:  TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Text("huuh"),

                  trailing:  Icon(Icons.chevron_right),

                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {

  final int totalTracks;

   _AppHeader({required this.totalTracks});

  @override
  Widget build(BuildContext context) {

    final statusBarH = MediaQuery.of(context).padding.top;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(20, statusBarH + 10, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            "YOUR COLLECTION",
            style: TextStyle(
              fontSize: 10,
              color: cs.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),

           SizedBox(height: 5),

          Text(
            "Music Library",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),

           SizedBox(height: 6),

          Container(
            padding:  EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "$totalTracks tracks",
              style:  TextStyle(fontSize: 12),
            ),
          )
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {

  final TextEditingController controller;

  final Function(String) onChanged;

   _SearchBar({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {

    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding:  EdgeInsets.all(14),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: "Search tracks...",
          prefixIcon:  Icon(Icons.search),
          filled: true,
          fillColor: cs.onSurface.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _GroupByToggle extends StatelessWidget {
   _GroupByToggle();

  @override
  Widget build(BuildContext context) {

    return  Padding(
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [

          Text("Group by: "),

          SizedBox(width: 10),

          _Chip(label: "Title"),

          SizedBox(width: 8),

          _Chip(label: "Artist"),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {

  final String label;

   _Chip({required this.label});

  @override
  Widget build(BuildContext context) {

    return Chip(
      label: Text(label),
    );
  }
}