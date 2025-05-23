enum ResourceType { video, audio, image, unknown }

extension ResourceClassifier on String {
  ResourceType get resourceType {
    final lower = toLowerCase();
    if (lower.contains('youtube.com') || lower.contains('youtu.be')) {
      return ResourceType.video;
    }
    if (lower.endsWith('.mp3') || lower.endsWith('.wav')) {
      return ResourceType.audio;
    }
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif')) {
      return ResourceType.image;
    }
    return ResourceType.unknown;
  }
}