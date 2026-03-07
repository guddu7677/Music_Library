import 'package:flutter/material.dart';
import 'package:music_library/models/track.dart';


class TrackTile extends StatelessWidget {
  final Track track;
  final VoidCallback? onTap;
  final bool isPlaying;

const TrackTile({
    super.key,
    required this.track,
    this.onTap,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isPlaying
              ? cs.primary.withOpacity(0.12)
              : cs.surface.withOpacity(0.6),
          border: Border.all(
            color: isPlaying
                ? cs.primary.withOpacity(0.35)
                : Colors.white.withOpacity(0.06),
            width: 1,
          ),
          boxShadow: isPlaying
              ? [
                  BoxShadow(
                    color: cs.primary.withOpacity(0.15),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _AlbumArt(url: track.album.coverSmall, isPlaying: isPlaying),
           SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.titleShort,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isPlaying ? cs.primary : cs.onSurface,
                      fontSize: 14,
                      letterSpacing: -0.2,
                    ),
                  ),
                 SizedBox(height: 3),
                  Text(
                    track.artist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withOpacity(0.55),
                      fontSize: 12,
                    ),
                  ),
                 SizedBox(height: 2),
                  Text(
                    'ID: ${track.id}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurface.withOpacity(0.25),
                      fontSize: 9,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
           SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  track.durationFormatted,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.4),
                    fontSize: 11,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                if (track.explicitLyrics) ...[
                 SizedBox(height: 5),
                  _ExplicitBadge(),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExplicitBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
      ),
      child: Text(
        'E',
        style: TextStyle(
          fontSize: 9,
          color: Colors.redAccent,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _AlbumArt extends StatelessWidget {
  final String? url;
  final bool isPlaying;

 _AlbumArt({this.url, required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: url != null && url!.isNotEmpty
                ? Image.network(
                    url!,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : _placeholder(),
                  )
                : _placeholder(),
          ),
        ),
        if (isPlaying)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: cs.primary.withOpacity(0.55),
                child: Center(child: _PlayingBars()),
              ),
            ),
          ),
      ],
    );
  }

  Widget _placeholder() => Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey.shade800, Colors.grey.shade900],
          ),
        ),
        child: Icon(Icons.music_note_rounded,
            color: Colors.white24, size: 22),
      );
}

class _PlayingBars extends StatefulWidget {
 _PlayingBars();

  @override
  State<_PlayingBars> createState() => _PlayingBarsState();
}

class _PlayingBarsState extends State<_PlayingBars>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + i * 120),
      )..repeat(reverse: true),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controllers[i],
          builder: (_, __) => Container(
            width: 3,
            height: 6 + (_controllers[i].value * 14),
            margin: EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class StickyHeader extends StatelessWidget {
  final String label;
  final int? count;

 StickyHeader({super.key, required this.label, this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.07),
        border: Border(
          top: BorderSide(color: cs.primary.withOpacity(0.12)),
          bottom: BorderSide(color: cs.primary.withOpacity(0.08)),
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: cs.primary,
              letterSpacing: 2.0,
            ),
          ),
         SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary.withOpacity(0.3), Colors.transparent],
                ),
              ),
            ),
          ),
          if (count != null) ...[
           SizedBox(width: 10),
            Container(
              padding:
                 EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: cs.primary.withOpacity(0.15), width: 1),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  color: cs.onSurface.withOpacity(0.4),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class NoInternetBanner extends StatefulWidget {
 NoInternetBanner({super.key});

  @override
  State<NoInternetBanner> createState() => _NoInternetBannerState();
}

class _NoInternetBannerState extends State<NoInternetBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7B0000), Color(0xFFB00020)],
        ),
        border: Border(
          bottom: BorderSide(color: Color(0x33FF5050)),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 18),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.wifi_off_rounded,
                color: Colors.white, size: 13),
          ),
         SizedBox(width: 10),
         Text(
            'NO INTERNET CONNECTION',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 1.4,
            ),
          ),
         Spacer(),
          AnimatedBuilder(
            animation: _dotController,
            builder: (_, __) => Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(_dotController.value * 0.8),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}