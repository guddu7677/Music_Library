import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_library/bloc/track_details/track_detail_bloc.dart';
import 'package:music_library/bloc/track_details/track_detail_event.dart';
import 'package:music_library/bloc/track_details/track_state.dart';
import 'package:music_library/models/track.dart';
import 'package:music_library/models/track_detail.dart';
import 'package:music_library/repositories/track_repository.dart';

class TrackDetailScreen extends StatelessWidget {
  final Track track;
const TrackDetailScreen({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TrackDetailBloc(repository: TrackRepository())
        ..add(TrackDetailLoaded(track.id)),
      child: _TrackDetailView(track: track),
    );
  }
}

class _TrackDetailView extends StatelessWidget {
  final Track track;
 _TrackDetailView({required this.track});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: BlocBuilder<TrackDetailBloc, TrackDetailState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              _SliverHeader(state: state, track: track),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DetailSection(state: state, track: track),
                    _LyricsSection(state: state, trackId: track.id),
                   SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SliverHeader extends StatelessWidget {
  final TrackDetailState state;
  final Track track;
 _SliverHeader({required this.state, required this.track});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final coverUrl = state.detail?.albumCover ?? '';

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: cs.surface,
      elevation: 0,
      leading: Padding(
        padding: EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ),
      title: Text(
        'Track Details',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: cs.onSurface.withOpacity(0.7),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            coverUrl.isNotEmpty
                ? Image.network(
                    coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _CoverPlaceholder(),
                  )
                : _CoverPlaceholder(),

           DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.35, 0.75, 1.0],
                  colors: [
                    Colors.transparent,
                    Color(0xCC0C101E),
                    Color(0xFF0C101E),
                  ],
                ),
              ),
            ),

            if (state.detail?.explicitLyrics == true)
              Positioned(
                top: 52,
                right: 16,
                child: Container(
                  padding:
                     EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.red.withOpacity(0.35)),
                  ),
                  child: Text(
                    'EXPLICIT',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1F38), Color(0xFF0E1120)],
        ),
      ),
      child: Center(
        child: Icon(Icons.album_rounded, size: 80, color: Colors.white10),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final TrackDetailState state;
  final Track track;
 const _DetailSection({required this.state, required this.track});

  @override
  Widget build(BuildContext context) {
    switch (state.detailStatus) {
      case TrackDetailStatus.initial:
      case TrackDetailStatus.loading:
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator()),
        );

      case TrackDetailStatus.noInternet:
        return Padding(
          padding: EdgeInsets.all(20),
          child: _NoInternetWidget(
            onRetry: () => context
                .read<TrackDetailBloc>()
                .add(TrackDetailRetried(track.id)),
          ),
        );

      case TrackDetailStatus.failure:
        return Padding(
          padding: EdgeInsets.all(20),
          child: _ErrorWidget(
            message: state.detailError ?? 'Failed to load details',
            onRetry: () => context
                .read<TrackDetailBloc>()
                .add(TrackDetailRetried(track.id)),
          ),
        );

      case TrackDetailStatus.success:
        return _SuccessDetail(detail: state.detail!);
    }
  }
}

class _SuccessDetail extends StatelessWidget {
  final TrackDetail detail;
 _SuccessDetail({required this.detail});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.title,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
         SizedBox(height: 16),

          _InfoRow(
            leading: detail.artistPicture.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.network(
                      detail.artistPicture,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _avatarFallback(cs),
                    ),
                  )
                : _avatarFallback(cs),
            label: 'Artist',
            value: detail.artistName,
          ),
         SizedBox(height: 10),

          _InfoRow(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.primary.withOpacity(0.18)),
              ),
              child: Icon(Icons.album_rounded,
                  size: 22, color: cs.primary.withOpacity(0.7)),
            ),
            label: 'Album',
            value: detail.albumTitle,
          ),
         SizedBox(height: 18),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.timer_outlined,
                label: detail.durationFormatted,
              ),
              _InfoChip(
                icon: Icons.trending_up_rounded,
                label: 'Rank ${detail.rank}',
              ),
              _InfoChip(
                icon: Icons.tag_rounded,
                label: 'ID ${detail.id}',
              ),
              if (detail.explicitLyrics)
               _InfoChip(
                  icon: Icons.explicit_rounded,
                  label: 'Explicit',
                  isRed: true,
                ),
            ],
          ),
         SizedBox(height: 24),

          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  cs.onSurface.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(ColorScheme cs) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: cs.onSurface.withOpacity(0.06),
          shape: BoxShape.circle,
          border: Border.all(color: cs.onSurface.withOpacity(0.08)),
        ),
        child: Icon(Icons.person_rounded,
            size: 22, color: cs.onSurface.withOpacity(0.3)),
      );
}

class _InfoRow extends StatelessWidget {
  final Widget leading;
  final String label;
  final String value;
 _InfoRow(
      {required this.leading, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        leading,
       SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface.withOpacity(0.3),
                  letterSpacing: 1.2,
                ),
              ),
             SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isRed;
 _InfoChip(
      {required this.icon, required this.label, this.isRed = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = isRed ? Colors.redAccent : cs.onSurface.withOpacity(0.55);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: isRed
            ? Colors.red.withOpacity(0.1)
            : cs.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRed
              ? Colors.red.withOpacity(0.25)
              : cs.onSurface.withOpacity(0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
         SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _LyricsSection extends StatelessWidget {
  final TrackDetailState state;
  final int trackId;
 _LyricsSection({required this.state, required this.trackId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Lyrics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
             SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        cs.onSurface.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
         SizedBox(height: 14),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    switch (state.lyricsStatus) {
      case TrackDetailStatus.initial:
      case TrackDetailStatus.loading:
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: CircularProgressIndicator(),
          ),
        );

      case TrackDetailStatus.noInternet:
        return _NoInternetWidget(
          onRetry: () => context
              .read<TrackDetailBloc>()
              .add(TrackDetailRetried(trackId)),
        );

      case TrackDetailStatus.failure:
        return _ErrorWidget(
          message: state.lyricsError ?? 'Failed to load lyrics',
          onRetry: () => context
              .read<TrackDetailBloc>()
              .add(TrackDetailRetried(trackId)),
        );

      case TrackDetailStatus.success:
        final lyrics = state.lyrics;

        if (lyrics == null || !lyrics.available) {
          return Container(
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cs.onSurface.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.onSurface.withOpacity(0.07)),
            ),
            child: Row(
              children: [
                Icon(Icons.lyrics_outlined,
                    color: cs.onSurface.withOpacity(0.2), size: 22),
               SizedBox(width: 12),
                Text(
                  'Lyrics not available for this track.',
                  style: TextStyle(
                    color: cs.onSurface.withOpacity(0.35),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cs.onSurface.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.onSurface.withOpacity(0.07)),
          ),
          child: Text(
            lyrics.lyricsText!,
            style: TextStyle(
              height: 1.9,
              fontSize: 14,
              color: cs.onSurface.withOpacity(0.75),
              fontStyle: FontStyle.italic,
              letterSpacing: 0.1,
            ),
          ),
        );
    }
  }
}

class _NoInternetWidget extends StatelessWidget {
  final VoidCallback onRetry;
 _NoInternetWidget({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         Row(
            children: [
              Icon(Icons.wifi_off_rounded, color: Colors.redAccent, size: 20),
              SizedBox(width: 10),
              Text(
                'NO INTERNET CONNECTION',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
         SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh_rounded, size: 16),
            label: Text('Try Again',
                style: TextStyle(fontWeight: FontWeight.w700)),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.2),
              foregroundColor: Colors.redAccent,
              padding:
                 EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
 _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
             Icon(Icons.error_outline_rounded,
                  color: Colors.orange, size: 20),
             SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
         SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh_rounded, size: 16),
            label: Text('Retry',
                style: TextStyle(fontWeight: FontWeight.w700)),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange.withOpacity(0.15),
              foregroundColor: Colors.orange,
              padding:
                 EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}