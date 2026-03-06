import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> tracks = [
      {"title": "tu hi hai ", "artist": "arjit singh"},
      {"title": "tere bin", "artist": "atif aslam"},
      {"title": "baarish", "artist": "Jubin da"},
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           _AppHeader(),
           _SearchBar(),
           _GroupByToggle(),

          Expanded(
            child: ListView.builder(
              itemCount: tracks.length,
              itemBuilder: (context, index) {
                final track = tracks[index];

                return ListTile(
                  leading:  CircleAvatar(
                    child: Icon(Icons.music_note),
                  ),
                  title: Text(
                    track["title"]!,
                    style:  TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(track["artist"]!),
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
  const _AppHeader();

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
            child:  Text(
              "6 tracks",
              style: TextStyle(fontSize: 12),
            ),
          )
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding:  EdgeInsets.all(14),
      child: TextField(
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
  const _GroupByToggle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 14),
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

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
    );
  }
}