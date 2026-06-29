enum KeeperSignalBand { bloom, muse }

enum CapsuleMediaKind { still, motion }

enum CapsuleVisibility { publicSquare, privateShelf }

enum CapsuleCraftKind { pictureLetter, videoMemory }

class CapsuleKeeper {
  const CapsuleKeeper({
    required this.keeperKey,
    required this.displayName,
    required this.ageLine,
    required this.placeLine,
    required this.signalBand,
    required this.avatarAsset,
  });

  final String keeperKey;
  final String displayName;
  final String ageLine;
  final String placeLine;
  final KeeperSignalBand signalBand;
  final String avatarAsset;
}

class CapsuleMediaSnap {
  const CapsuleMediaSnap({
    required this.snapKey,
    required this.assetPath,
    required this.kind,
    required this.captionTrace,
  });

  final String snapKey;
  final String assetPath;
  final CapsuleMediaKind kind;
  final String captionTrace;
}

class CapsuleOpeningPreset {
  const CapsuleOpeningPreset({
    required this.presetKey,
    required this.label,
    required this.openingAt,
    this.noteLine,
  });

  final String presetKey;
  final String label;
  final DateTime openingAt;
  final String? noteLine;
}

class CapsuleSquareNote {
  const CapsuleSquareNote({
    required this.noteKey,
    required this.keeper,
    required this.messageLine,
    required this.mediaSnaps,
    required this.sealedAt,
    required this.openingAt,
    required this.visibility,
    required this.visitorTrail,
    required this.leftMessageCount,
    this.isLocalDraft = false,
  });

  final String noteKey;
  final CapsuleKeeper keeper;
  final String messageLine;
  final List<CapsuleMediaSnap> mediaSnaps;
  final DateTime sealedAt;
  final DateTime openingAt;
  final CapsuleVisibility visibility;
  final List<CapsuleKeeper> visitorTrail;
  final int leftMessageCount;
  final bool isLocalDraft;

  bool get canOpenNow {
    return !DateTime.now().isBefore(openingAt);
  }
}

class CapsuleDraftLedger {
  const CapsuleDraftLedger({
    required this.craftKind,
    required this.messageLine,
    required this.mediaSnaps,
    required this.openingAt,
    required this.visibility,
  });

  final CapsuleCraftKind craftKind;
  final String messageLine;
  final List<CapsuleMediaSnap> mediaSnaps;
  final DateTime openingAt;
  final CapsuleVisibility visibility;

  bool get hasRequiredStory => messageLine.trim().isNotEmpty;

  CapsuleDraftLedger copyWith({
    CapsuleCraftKind? craftKind,
    String? messageLine,
    List<CapsuleMediaSnap>? mediaSnaps,
    DateTime? openingAt,
    CapsuleVisibility? visibility,
  }) {
    return CapsuleDraftLedger(
      craftKind: craftKind ?? this.craftKind,
      messageLine: messageLine ?? this.messageLine,
      mediaSnaps: mediaSnaps ?? this.mediaSnaps,
      openingAt: openingAt ?? this.openingAt,
      visibility: visibility ?? this.visibility,
    );
  }
}
