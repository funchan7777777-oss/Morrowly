enum KeeperSignalBand { bloom, muse }

enum MemoryFragmentKind { still, motion }

enum CapsuleShelfScope { publicSquare, privateShelf }

enum CapsuleSealFormat { pictureLetter, videoMemory }

class CapsuleKeeper {
  const CapsuleKeeper({
    required this.keeperId,
    required this.publicName,
    required this.ageMark,
    required this.homeRegion,
    required this.signalBand,
    required this.portraitAsset,
    this.localPortraitPath = '',
  });

  final String keeperId;
  final String publicName;
  final String ageMark;
  final String homeRegion;
  final KeeperSignalBand signalBand;
  final String portraitAsset;
  final String localPortraitPath;
}

class CapsuleMemoryFragment {
  const CapsuleMemoryFragment({
    required this.fragmentId,
    required this.sourcePath,
    required this.fragmentKind,
    required this.captionTrace,
    this.isLocalFile = false,
  });

  final String fragmentId;
  final String sourcePath;
  final MemoryFragmentKind fragmentKind;
  final String captionTrace;
  final bool isLocalFile;
}

class CapsuleOpeningPreset {
  const CapsuleOpeningPreset({
    required this.presetId,
    required this.label,
    required this.unlocksAt,
    this.guidanceLine,
  });

  final String presetId;
  final String label;
  final DateTime unlocksAt;
  final String? guidanceLine;
}

class CapsuleReply {
  const CapsuleReply({
    required this.replyId,
    required this.author,
    required this.sealedMessage,
    required this.arrivalLabel,
  });

  final String replyId;
  final CapsuleKeeper author;
  final String sealedMessage;
  final String arrivalLabel;
}

class PublicCapsuleSeal {
  const PublicCapsuleSeal({
    required this.sealId,
    required this.keeper,
    required this.sealedMessage,
    required this.memoryFragments,
    required this.sealedAt,
    required this.unlocksAt,
    required this.shelfScope,
    required this.visitorTrail,
    required this.replyTrailCount,
    this.replies = const [],
    this.isLocalDraft = false,
  });

  final String sealId;
  final CapsuleKeeper keeper;
  final String sealedMessage;
  final List<CapsuleMemoryFragment> memoryFragments;
  final DateTime sealedAt;
  final DateTime unlocksAt;
  final CapsuleShelfScope shelfScope;
  final List<CapsuleKeeper> visitorTrail;
  final int replyTrailCount;
  final List<CapsuleReply> replies;
  final bool isLocalDraft;

  bool get canOpenNow {
    return !DateTime.now().isBefore(unlocksAt);
  }

  PublicCapsuleSeal copyWith({
    String? sealId,
    CapsuleKeeper? keeper,
    String? sealedMessage,
    List<CapsuleMemoryFragment>? memoryFragments,
    DateTime? sealedAt,
    DateTime? unlocksAt,
    CapsuleShelfScope? shelfScope,
    List<CapsuleKeeper>? visitorTrail,
    int? replyTrailCount,
    List<CapsuleReply>? replies,
    bool? isLocalDraft,
  }) {
    return PublicCapsuleSeal(
      sealId: sealId ?? this.sealId,
      keeper: keeper ?? this.keeper,
      sealedMessage: sealedMessage ?? this.sealedMessage,
      memoryFragments: memoryFragments ?? this.memoryFragments,
      sealedAt: sealedAt ?? this.sealedAt,
      unlocksAt: unlocksAt ?? this.unlocksAt,
      shelfScope: shelfScope ?? this.shelfScope,
      visitorTrail: visitorTrail ?? this.visitorTrail,
      replyTrailCount: replyTrailCount ?? this.replyTrailCount,
      replies: replies ?? this.replies,
      isLocalDraft: isLocalDraft ?? this.isLocalDraft,
    );
  }
}

class CapsuleDraftLedger {
  const CapsuleDraftLedger({
    required this.sealFormat,
    required this.sealedMessage,
    required this.memoryFragments,
    required this.unlocksAt,
    required this.shelfScope,
  });

  final CapsuleSealFormat sealFormat;
  final String sealedMessage;
  final List<CapsuleMemoryFragment> memoryFragments;
  final DateTime unlocksAt;
  final CapsuleShelfScope shelfScope;

  bool get hasRequiredStory => sealedMessage.trim().isNotEmpty;

  CapsuleDraftLedger copyWith({
    CapsuleSealFormat? sealFormat,
    String? sealedMessage,
    List<CapsuleMemoryFragment>? memoryFragments,
    DateTime? unlocksAt,
    CapsuleShelfScope? shelfScope,
  }) {
    return CapsuleDraftLedger(
      sealFormat: sealFormat ?? this.sealFormat,
      sealedMessage: sealedMessage ?? this.sealedMessage,
      memoryFragments: memoryFragments ?? this.memoryFragments,
      unlocksAt: unlocksAt ?? this.unlocksAt,
      shelfScope: shelfScope ?? this.shelfScope,
    );
  }
}
