import 'package:flutter/widgets.dart';

/// A 3D-style icon widget that loads its image from the assets/icons directory.
///
/// The [id] corresponds to the filename (without extension) under assets/icons/.
/// You can customize the [size], [fit], and [extension] if needed.
class Icon3d extends StatelessWidget {
  /// The identifier for the icon asset (filename without extension).
  final String id;

  /// The width and height of the icon.
  final double? size;

  /// The file extension of the icon asset (defaults to 'png').
  final String extension;

  /// How the image should be inscribed into the space allocated.
  final BoxFit fit;

  /// Optional semantic label for accessibility.
  final String? semanticLabel;

  /// Creates an [Icon3d] widget.
  ///
  /// [id] is required and refers to the asset file `assets/icons/{id}.{extension}`.
  /// [size] controls both width and height.
  /// [extension] defaults to 'png'.
  /// [fit] defaults to [BoxFit.contain].
  const Icon3d(this.id, {
    Key? key,
    this.size,
    this.extension = 'png',
    this.fit = BoxFit.contain,
    this.semanticLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/$id.$extension',
      width: size,
      height: size,
      fit: fit,
      semanticLabel: semanticLabel,
    );
  }
}
