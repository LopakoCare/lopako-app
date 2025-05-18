import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// A reusable widget to display a YouTube video by video ID.
///
/// Usage:
/// ```dart
/// YouTubeVideoPlayer(
///   videoId: 'dQw4w9WgXcQ', // your YouTube video ID
///   autoPlay: false,
/// );
/// ```
class YouTubeVideoPlayer extends StatefulWidget {
  /// The YouTube video ID (not the full URL).
  final String videoId;

  /// Whether the video should start playing automatically.
  final bool autoPlay;

  /// Whether the video should be muted initially.
  final bool mute;

  const YouTubeVideoPlayer({
    Key? key,
    required this.videoId,
    this.autoPlay = false,
    this.mute = false,
  }) : super(key: key);

  @override
  _YouTubeVideoPlayerState createState() => _YouTubeVideoPlayerState();
}

class _YouTubeVideoPlayerState extends State<YouTubeVideoPlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: widget.autoPlay,
        mute: widget.mute,
        controlsVisibleAtStart: true,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
      ),
      builder: (context, player) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            player,
            // Optionally add custom controls or description here
          ],
        );
      },
    );
  }
}
