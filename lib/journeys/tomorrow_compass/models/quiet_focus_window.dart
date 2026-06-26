class QuietFocusWindow {
  const QuietFocusWindow({
    required this.windowKey,
    required this.doorwayLabel,
    required this.startsAtMinute,
    required this.closesAtMinute,
    required this.attentionBoundary,
    required this.recoveryPermission,
    required this.interruptionPolicy,
  });

  final String windowKey;
  final String doorwayLabel;
  final int startsAtMinute;
  final int closesAtMinute;
  final String attentionBoundary;
  final String recoveryPermission;
  final String interruptionPolicy;
}
