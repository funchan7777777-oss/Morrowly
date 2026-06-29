import 'dart:convert';

enum LifeSnippetFeedFilter { popular, followed }

enum LifeSnippetMediaKind { asset, localFile }

enum LifeFollowStatus { none, requested, following }

class LifeSnippetUser {
  const LifeSnippetUser({
    required this.userKey,
    required this.displayName,
    required this.ageLine,
    required this.placeLine,
    required this.avatarAsset,
    required this.signatureLine,
    this.avatarLocalPath = '',
    this.isCurrentUser = false,
    this.followCount = 0,
    this.fansCount = 0,
    this.likeCount = 0,
    this.capsuleCount = 0,
  });

  final String userKey;
  final String displayName;
  final String ageLine;
  final String placeLine;
  final String avatarAsset;
  final String avatarLocalPath;
  final String signatureLine;
  final bool isCurrentUser;
  final int followCount;
  final int fansCount;
  final int likeCount;
  final int capsuleCount;

  String get regionLine => '$ageLine · $placeLine';
}

class LifeSnippetMedia {
  const LifeSnippetMedia({
    required this.mediaKey,
    required this.path,
    required this.kind,
  });

  final String mediaKey;
  final String path;
  final LifeSnippetMediaKind kind;

  Map<String, Object?> toJson() {
    return {
      'mediaKey': mediaKey,
      'path': path,
      'kind': kind.name,
    };
  }

  static LifeSnippetMedia fromJson(Map<String, Object?> json) {
    return LifeSnippetMedia(
      mediaKey: json['mediaKey'] as String? ?? '',
      path: json['path'] as String? ?? '',
      kind: LifeSnippetMediaKind.values.firstWhere(
        (kind) => kind.name == json['kind'],
        orElse: () => LifeSnippetMediaKind.asset,
      ),
    );
  }
}

class LifeSnippetComment {
  const LifeSnippetComment({
    required this.commentKey,
    required this.authorKey,
    required this.body,
    required this.createdAt,
  });

  final String commentKey;
  final String authorKey;
  final String body;
  final DateTime createdAt;

  Map<String, Object?> toJson() {
    return {
      'commentKey': commentKey,
      'authorKey': authorKey,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static LifeSnippetComment fromJson(Map<String, Object?> json) {
    return LifeSnippetComment(
      commentKey: json['commentKey'] as String? ?? '',
      authorKey: json['authorKey'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class LifeSnippetPost {
  const LifeSnippetPost({
    required this.postKey,
    required this.authorKey,
    required this.body,
    required this.media,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    this.seedComments = const [],
    this.isPendingReview = false,
  });

  final String postKey;
  final String authorKey;
  final String body;
  final List<LifeSnippetMedia> media;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final List<LifeSnippetComment> seedComments;
  final bool isPendingReview;

  LifeSnippetPost copyWith({
    int? likeCount,
    int? commentCount,
    List<LifeSnippetComment>? seedComments,
    bool? isPendingReview,
  }) {
    return LifeSnippetPost(
      postKey: postKey,
      authorKey: authorKey,
      body: body,
      media: media,
      createdAt: createdAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      seedComments: seedComments ?? this.seedComments,
      isPendingReview: isPendingReview ?? this.isPendingReview,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'postKey': postKey,
      'authorKey': authorKey,
      'body': body,
      'media': media.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'likeCount': likeCount,
      'commentCount': commentCount,
      'seedComments': seedComments.map((comment) => comment.toJson()).toList(),
      'isPendingReview': isPendingReview,
    };
  }

  static LifeSnippetPost fromJson(Map<String, Object?> json) {
    final media = json['media'] as List<Object?>? ?? const [];
    final comments = json['seedComments'] as List<Object?>? ?? const [];
    return LifeSnippetPost(
      postKey: json['postKey'] as String? ?? '',
      authorKey: json['authorKey'] as String? ?? '',
      body: json['body'] as String? ?? '',
      media: media
          .whereType<Map<String, Object?>>()
          .map(LifeSnippetMedia.fromJson)
          .toList(),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      seedComments: comments
          .whereType<Map<String, Object?>>()
          .map(LifeSnippetComment.fromJson)
          .toList(),
      isPendingReview: json['isPendingReview'] as bool? ?? false,
    );
  }
}

class LifeChatMessage {
  const LifeChatMessage({
    required this.messageKey,
    required this.senderKey,
    required this.body,
    required this.createdAt,
  });

  final String messageKey;
  final String senderKey;
  final String body;
  final DateTime createdAt;

  Map<String, Object?> toJson() {
    return {
      'messageKey': messageKey,
      'senderKey': senderKey,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static LifeChatMessage fromJson(Map<String, Object?> json) {
    return LifeChatMessage(
      messageKey: json['messageKey'] as String? ?? '',
      senderKey: json['senderKey'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

List<Map<String, Object?>> decodeJsonObjectList(String source) {
  final decoded = jsonDecode(source);
  if (decoded is! List<Object?>) {
    return const [];
  }
  return decoded.whereType<Map<String, Object?>>().toList();
}
