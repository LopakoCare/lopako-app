// routine_activity_screen.dart
import 'package:flutter/material.dart';
import 'package:lopako_app_lis/core/widgets/icon_3d.dart';
import 'package:lopako_app_lis/features/routines/models/resource_utils_model.dart';
import 'package:lopako_app_lis/features/routines/models/routine_activity_model.dart';
import 'package:lopako_app_lis/generated/l10n.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cached_network_image/cached_network_image.dart';


class RoutineActivityScreen extends StatefulWidget {
  final RoutineActivity activity;
  final VoidCallback? onFinished;

  const RoutineActivityScreen({
    super.key,
    required this.activity,
    this.onFinished,
  });

  @override
  State<RoutineActivityScreen> createState() => _RoutineActivityScreenState();
}

class _RoutineActivityScreenState extends State<RoutineActivityScreen> {
  final _player = AudioPlayer();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);

    final ordered = [
      ...widget.activity.resources
          .where((r) => r.resourceType == ResourceType.video),
      ...widget.activity.resources
          .where((r) => r.resourceType == ResourceType.audio),
      ...widget.activity.resources
          .where((r) => r.resourceType == ResourceType.image),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity.type == RoutineActivityType.microlearning
          ? localizations.microlearningActivity
          : localizations.practiceActivity),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // === Encabezado con icono, título y descripción ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon3d(widget.activity.icon, size: 64),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.activity.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.activity.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // === Contenido ===
            Expanded(
              child: ListView.separated(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                itemCount: ordered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 24),
                itemBuilder: (context, i) => _buildResource(ordered[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResource(String url) {
    switch (url.resourceType) {
    // ----------------- Vídeo -----------------
      case ResourceType.video:
        final id = YoutubePlayer.convertUrlToId(url)!;
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: YoutubePlayer(
            controller: YoutubePlayerController(
              initialVideoId: id,
              flags: const YoutubePlayerFlags(
                autoPlay: false,
                enableCaption: true,
              ),
            ),
            showVideoProgressIndicator: true,
          ),
        );

    // ----------------- Audio -----------------
      case ResourceType.audio:
        return _AudioTile(player: _player, url: url);

    // ----------------- Imagen ----------------
      case ResourceType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (_, __) => const AspectRatio(
                aspectRatio: 16 / 9,
                child: Center(child: CircularProgressIndicator())),
            errorWidget: (_, __, ___) => const AspectRatio(
                aspectRatio: 16 / 9, child: Center(child: Icon(Icons.error))),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

// Pequeño widget para audio con iconografía coherente
class _AudioTile extends StatefulWidget {
  final AudioPlayer player;
  final String url;
  const _AudioTile({required this.player, required this.url});

  @override
  State<_AudioTile> createState() => _AudioTileState();
}

class _AudioTileState extends State<_AudioTile> {
  var _isPlaying = false;

  @override
  void initState() {
    super.initState();
    widget.player.playerStateStream.listen((s) {
      setState(() => _isPlaying = s.playing);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: Theme.of(context).colorScheme.surfaceVariant,
      leading: Icon(
        _isPlaying ? Icons.pause_circle : Icons.play_circle,
        size: 42,
      ),
      title: Text(widget.url.split('/').last),
      onTap: () async {
        if (_isPlaying) {
          await widget.player.pause();
        } else {
          await widget.player.setUrl(widget.url);
          await widget.player.play();
        }
      },
    );
  }
}