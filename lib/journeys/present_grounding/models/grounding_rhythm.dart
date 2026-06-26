class GroundingRhythm {
  const GroundingRhythm({
    required this.rhythmKey,
    required this.displayName,
    required this.settlingPhrase,
    required this.minutes,
    required this.bodyCue,
    required this.repeatPattern,
    required this.colorMood,
  });

  final String rhythmKey;
  final String displayName;
  final String settlingPhrase;
  final int minutes;
  final String bodyCue;
  final String repeatPattern;
  final String colorMood;
}
