import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_library/bloc/library/library_bloc.dart';
import 'package:music_library/screens/track_details_screen.dart';
import 'package:music_library/widgets/widgets.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<LibraryBloc>().add(const LibraryStarted());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      context.read<LibraryBloc>().add(const LibraryLoadMoreRequested());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AppHeader(),
          _SearchBar(controller: _searchController),
          _GroupByToggle(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return BlocConsumer<LibraryBloc, LibraryState>(
      listenWhen: (p, c) => p.errorMessage != c.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null &&
            state.status != LibraryStatus.noInternet) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
          );
        }
      },
      builder: (context, state) {
        switch (state.status) {
          case LibraryStatus.initial:
          case LibraryStatus.loading:
            return const _LoadingView();

          case LibraryStatus.noInternet:
            return _NoInternetView(
              onRetry: () =>
                  context.read<LibraryBloc>().add(const LibraryStarted()),
            );

          case LibraryStatus.failure:
            return _ErrorView(
              message: state.errorMessage ?? 'Unknown error',
              onRetry: () =>
                  context.read<LibraryBloc>().add(const LibraryStarted()),
            );

          case LibraryStatus.success:
            return _TrackList(
              scrollController: _scrollController,
              state: state,
            );
        }
      },
    );
  }
}

class _AppHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusBarH = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(22, statusBarH + 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR COLLECTION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                    letterSpacing: 2.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Music Library',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                    letterSpacing: -0.5,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                BlocBuilder<LibraryBloc, LibraryState>(
                  buildWhen: (p, c) =>
                      p.allTracks.length != c.allTracks.length,
                  builder: (_, state) => _CountPill(
                      count: state.allTracks.length),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              _IconBtn(icon: Icons.grid_view_rounded, onTap: () {}),
              const SizedBox(height: 8),
              _IconBtn(icon: Icons.sort_rounded, onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  final int count;
  const _CountPill({required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withOpacity(0.2)),
      ),
      child: Text(
        '$count tracks',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: cs.primary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: cs.onSurface.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.onSurface.withOpacity(0.07)),
        ),
        child: Icon(icon, color: cs.onSurface.withOpacity(0.5), size: 18),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontSize: 14,
          color: cs.onSurface,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search tracks or artists…',
          hintStyle: TextStyle(
            color: cs.onSurface.withOpacity(0.3),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon:
              Icon(Icons.search_rounded, color: cs.onSurface.withOpacity(0.35)),
          suffixIcon: ValueListenableBuilder(
            valueListenable: controller,
            builder: (_, val, __) => val.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded,
                        size: 18, color: cs.onSurface.withOpacity(0.4)),
                    onPressed: () {
                      controller.clear();
                      context
                          .read<LibraryBloc>()
                          .add(const LibrarySearchCleared());
                    },
                  )
                : const SizedBox.shrink(),
          ),
          filled: true,
          fillColor: cs.onSurface.withOpacity(0.045),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                BorderSide(color: cs.onSurface.withOpacity(0.07), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: cs.primary.withOpacity(0.4), width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        ),
        onChanged: (q) =>
            context.read<LibraryBloc>().add(LibrarySearchChanged(q)),
      ),
    );
  }
}

class _GroupByToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      buildWhen: (p, c) => p.groupBy != c.groupBy,
      builder: (context, state) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Row(
          children: [
            Text(
              'Group by:',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
            const SizedBox(width: 10),
            _Chip(
              label: 'Title A–Z',
              selected: state.groupBy == GroupBy.title,
              onTap: () => context
                  .read<LibraryBloc>()
                  .add(const LibraryGroupByChanged(GroupBy.title)),
            ),
            const SizedBox(width: 8),
            _Chip(
              label: 'Artist A–Z',
              selected: state.groupBy == GroupBy.artist,
              onTap: () => context
                  .read<LibraryBloc>()
                  .add(const LibraryGroupByChanged(GroupBy.artist)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.onSurface.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? cs.primary
                : cs.onSurface.withOpacity(0.08),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: cs.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? cs.onPrimary : cs.onSurface.withOpacity(0.5),
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _TrackList extends StatelessWidget {
  final ScrollController scrollController;
  final LibraryState state;
  const _TrackList({required this.scrollController, required this.state});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (state.displayItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 72, color: cs.onSurface.withOpacity(0.15)),
            const SizedBox(height: 14),
            Text(
              state.searchQuery.isNotEmpty
                  ? 'No tracks found for\n"${state.searchQuery}"'
                  : 'No tracks loaded',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurface.withOpacity(0.35),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.only(bottom: 8),
          itemCount:
              state.displayItems.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.displayItems.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.primary.withOpacity(0.5),
                    ),
                  ),
                ),
              );
            }

            final item = state.displayItems[index];
            if (item is StickyHeaderItem) {
              return StickyHeader(label: item.label);
            } else if (item is TrackListItem) {
              return TrackTile(
                track: item.track,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TrackDetailScreen(track: item.track),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),

        if (state.errorMessage == 'NO INTERNET CONNECTION' &&
            state.allTracks.isNotEmpty)
          const Positioned(
              top: 0, left: 0, right: 0, child: NoInternetBanner()),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your library…',
            style: TextStyle(
              color: cs.onSurface.withOpacity(0.35),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}


class _NoInternetView extends StatelessWidget {
  final VoidCallback onRetry;
  const _NoInternetView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  size: 40, color: Colors.redAccent),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Connection',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.redAccent,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your internet connection\nand try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurface.withOpacity(0.4),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.orange.withOpacity(0.2)),
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 36, color: Colors.orange),
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurface.withOpacity(0.4),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}