import 'dart:convert';

enum MemoryShelfFilter { popular, followed }

enum MemoryAttachmentSource { bundledMoment, localShelfFile }

enum KeeperLinkState { none, requested, following }

class KeeperProfile {
  const KeeperProfile({
    required this.keeperId,
    required this.publicName,
    required this.ageMark,
    required this.homeRegion,
    required this.portraitAsset,
    required this.morrowLine,
    this.localPortraitPath = '',
    this.belongsToSignedInKeeper = false,
    this.followingCount = 0,
    this.followerCount = 0,
    this.glowCount = 0,
    this.keptCapsuleCount = 0,
  });

  final String keeperId;
  final String publicName;
  final String ageMark;
  final String homeRegion;
  final String portraitAsset;
  final String localPortraitPath;
  final String morrowLine;
  final bool belongsToSignedInKeeper;
  final int followingCount;
  final int followerCount;
  final int glowCount;
  final int keptCapsuleCount;

  String get profileTrail => '$ageMark - $homeRegion';
}

class MemoryAttachment {
  const MemoryAttachment({
    required this.attachmentId,
    required this.sourcePath,
    required this.sourceKind,
  });

  final String attachmentId;
  final String sourcePath;
  final MemoryAttachmentSource sourceKind;

  Map<String, Object?> toJson() {
    return {
      'attachmentId': attachmentId,
      'sourcePath': sourcePath,
      'sourceKind': sourceKind.name,
    };
  }

  static MemoryAttachment fromJson(Map<String, Object?> json) {
    return MemoryAttachment(
      attachmentId: _stringFrom(json, 'attachmentId'),
      sourcePath: _stringFrom(json, 'sourcePath'),
      sourceKind: MemoryAttachmentSource.values.firstWhere(
        (sourceKind) => sourceKind.name == _stringFrom(json, 'sourceKind'),
        orElse: () => MemoryAttachmentSource.bundledMoment,
      ),
    );
  }
}

class MemoryReplyNote {
  const MemoryReplyNote({
    required this.replyId,
    required this.authorKeeperId,
    required this.noteLine,
    required this.pennedAt,
  });

  final String replyId;
  final String authorKeeperId;
  final String noteLine;
  final DateTime pennedAt;

  Map<String, Object?> toJson() {
    return {
      'replyId': replyId,
      'authorKeeperId': authorKeeperId,
      'noteLine': noteLine,
      'pennedAt': pennedAt.toIso8601String(),
    };
  }

  static MemoryReplyNote fromJson(Map<String, Object?> json) {
    return MemoryReplyNote(
      replyId: _stringFrom(json, 'replyId'),
      authorKeeperId: _stringFrom(json, 'authorKeeperId'),
      noteLine: _stringFrom(json, 'noteLine'),
      pennedAt:
          DateTime.tryParse(_stringFrom(json, 'pennedAt')) ?? DateTime.now(),
    );
  }
}

class MemorySeal {
  const MemorySeal({
    required this.sealId,
    required this.authorKeeperId,
    required this.noteLine,
    required this.attachments,
    required this.sealedAt,
    required this.glowCount,
    required this.replyCount,
    this.seedReplyNotes = const [],
    this.awaitsReview = false,
  });

  final String sealId;
  final String authorKeeperId;
  final String noteLine;
  final List<MemoryAttachment> attachments;
  final DateTime sealedAt;
  final int glowCount;
  final int replyCount;
  final List<MemoryReplyNote> seedReplyNotes;
  final bool awaitsReview;

  MemorySeal copyWith({
    int? glowCount,
    int? replyCount,
    List<MemoryReplyNote>? seedReplyNotes,
    bool? awaitsReview,
  }) {
    return MemorySeal(
      sealId: sealId,
      authorKeeperId: authorKeeperId,
      noteLine: noteLine,
      attachments: attachments,
      sealedAt: sealedAt,
      glowCount: glowCount ?? this.glowCount,
      replyCount: replyCount ?? this.replyCount,
      seedReplyNotes: seedReplyNotes ?? this.seedReplyNotes,
      awaitsReview: awaitsReview ?? this.awaitsReview,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'sealId': sealId,
      'authorKeeperId': authorKeeperId,
      'noteLine': noteLine,
      'attachments': attachments.map((item) => item.toJson()).toList(),
      'sealedAt': sealedAt.toIso8601String(),
      'glowCount': glowCount,
      'replyCount': replyCount,
      'seedReplyNotes': seedReplyNotes.map((reply) => reply.toJson()).toList(),
      'awaitsReview': awaitsReview,
    };
  }

  static MemorySeal fromJson(Map<String, Object?> json) {
    final attachmentValue = json['attachments'];
    final replyValue = json['seedReplyNotes'];
    final attachments = attachmentValue is List ? attachmentValue : const [];
    final replies = replyValue is List ? replyValue : const [];
    return MemorySeal(
      sealId: _stringFrom(json, 'sealId'),
      authorKeeperId: _stringFrom(json, 'authorKeeperId'),
      noteLine: _stringFrom(json, 'noteLine'),
      attachments: attachments
          .map(castJsonObject)
          .map(MemoryAttachment.fromJson)
          .toList(),
      sealedAt:
          DateTime.tryParse(_stringFrom(json, 'sealedAt')) ?? DateTime.now(),
      glowCount: _intFrom(json, 'glowCount'),
      replyCount: _intFrom(json, 'replyCount'),
      seedReplyNotes: replies
          .map(castJsonObject)
          .map(MemoryReplyNote.fromJson)
          .toList(),
      awaitsReview: _boolFrom(json, 'awaitsReview'),
    );
  }
}

class KeeperLetter {
  const KeeperLetter({
    required this.letterId,
    required this.senderKeeperId,
    required this.letterText,
    required this.sentAt,
  });

  final String letterId;
  final String senderKeeperId;
  final String letterText;
  final DateTime sentAt;

  Map<String, Object?> toJson() {
    return {
      'letterId': letterId,
      'senderKeeperId': senderKeeperId,
      'letterText': letterText,
      'sentAt': sentAt.toIso8601String(),
    };
  }

  static KeeperLetter fromJson(Map<String, Object?> json) {
    return KeeperLetter(
      letterId: _stringFrom(json, 'letterId'),
      senderKeeperId: _stringFrom(json, 'senderKeeperId'),
      letterText: _stringFrom(json, 'letterText'),
      sentAt: DateTime.tryParse(_stringFrom(json, 'sentAt')) ?? DateTime.now(),
    );
  }
}

List<Map<String, Object?>> decodeJsonObjectList(String source) {
  final decoded = jsonDecode(source);
  if (decoded is! List) {
    return const [];
  }
  return decoded.map(castJsonObject).toList();
}

Map<String, Object?> castJsonObject(Object? value) {
  if (value is Map) {
    return value.map((key, value) => MapEntry('$key', value));
  }
  return const {};
}

String _stringFrom(Map<String, Object?> json, String key, {String? legacyKey}) {
  return (json[key] ?? (legacyKey == null ? null : json[legacyKey]))
          as String? ??
      '';
}

int _intFrom(Map<String, Object?> json, String key, {String? legacyKey}) {
  return (json[key] ?? (legacyKey == null ? null : json[legacyKey])) as int? ??
      0;
}

bool _boolFrom(Map<String, Object?> json, String key, {String? legacyKey}) {
  return (json[key] ?? (legacyKey == null ? null : json[legacyKey])) as bool? ??
      false;
}
