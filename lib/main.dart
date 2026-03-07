import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_library/screens/library_screen.dart';
import 'bloc/library/library_bloc.dart';
import 'repositories/track_repository.dart';

void main() {
  runApp( MusicLibraryApp());
}

class MusicLibraryApp extends StatelessWidget {
  const MusicLibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => TrackRepository(),
      child: BlocProvider(
        create: (context) => LibraryBloc(
          repository: context.read<TrackRepository>(),
        ),
        child: MaterialApp(
          title: 'Music Library',
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(),
          home:  LibraryScreen(),
        ),
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor:  Color(0xFF6C63FF),
        brightness: Brightness.dark,
      ),
      appBarTheme:  AppBarTheme(
        centerTitle: false,
        elevation: 0,
      ),
      listTileTheme: ListTileThemeData(
        dense: true,
      ),
    );
  }
}
