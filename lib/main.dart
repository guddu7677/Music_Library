import 'package:flutter/material.dart';
import 'package:music_library/screens/library_screen.dart';
import 'package:music_library/screens/track_details_screen.dart';

void main() {
  runApp(MusicLibraryApp());
}

class MusicLibraryApp extends StatelessWidget {
  const MusicLibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Music_Library",
        home: LibraryScreen(),
        routes: {
          "/TrackDetailScreen":(context)=>TrackDetailsScreen(),
           "/LibraryScreen":(context)=>LibraryScreen()

        },
    );
  }
}
