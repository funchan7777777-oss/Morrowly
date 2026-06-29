import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:morrowly/journeys/present_grounding/models/life_snippet_models.dart';
import 'package:morrowly/journeys/welcome_gate/data/local_gate_store.dart';
import 'package:morrowly/shared/moderation/morrowly_moderation_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LifeSnippetRelationshipGate implements Exception {
  const LifeSnippetRelationshipGate();
}

class LifeSnippetStore extends ChangeNotifier {
  LifeSnippetStore._();

  static final LifeSnippetStore instance = LifeSnippetStore._();

  static const currentUserKey = 'current-user';
  static const _pendingPostsKey = 'morrowly.lifeSnippets.pendingPosts';
  static const _commentsKey = 'morrowly.lifeSnippets.commentsByPost';
  static const _likedPostsKey = 'morrowly.lifeSnippets.likedPostKeys';
  static const _outgoingFollowRequestsKey =
      'morrowly.lifeSnippets.outgoingFollowRequests';
  static const _followingUserKeysKey = 'morrowly.lifeSnippets.followingUserKeys';
  static const _followerUserKeysKey = 'morrowly.lifeSnippets.followerUserKeys';
  static const _chatThreadsKey = 'morrowly.lifeSnippets.chatThreads';

  final MorrowlyModerationStore _moderation =
      MorrowlyModerationStore.instance;
  final Set<String> _likedPostKeys = {};
  final Set<String> _outgoingFollowRequests = {};
  final Set<String> _followingUserKeys = {};
  final Set<String> _followerUserKeys = {};
  final Map<String, List<LifeSnippetComment>> _commentsByPost = {};
  final Map<String, List<LifeChatMessage>> _chatThreads = {};
  final List<LifeSnippetPost> _pendingReviewPosts = [];

  SharedPreferences? _preferences;
  LifeSnippetUser _currentUser = _fallbackCurrentUser;
  Future<void>? _loading;
  bool _isListeningToModeration = false;

  bool get isLoaded => _preferences != null;
  LifeSnippetUser get currentUser => _currentUser;
  List<LifeSnippetPost> get pendingReviewPosts =>
      List.unmodifiable(_pendingReviewPosts);

  List<LifeSnippetUser> get people {
    return [_currentUser, ..._seedUsers];
  }

  Future<void> load() {
    final activeLoad = _loading;
    if (activeLoad != null) {
      return activeLoad;
    }

    final load = _load();
    _loading = load;
    return load;
  }

  LifeSnippetUser userByKey(String userKey) {
    if (userKey == _currentUser.userKey) {
      return _currentUser;
    }
    return _seedUsers.firstWhere(
      (user) => user.userKey == userKey,
      orElse: () => _seedUsers.first,
    );
  }

  List<LifeSnippetPost> visiblePosts(LifeSnippetFeedFilter filter) {
    final posts = _seedPosts.where((post) {
      if (post.isPendingReview) {
        return false;
      }
      if (filter == LifeSnippetFeedFilter.followed &&
          !_followingUserKeys.contains(post.authorKey)) {
        return false;
      }
      return !_moderation.shouldHide(
        contentKey: post.postKey,
        authorKey: post.authorKey,
      );
    }).toList();

    posts.sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return posts;
  }

  List<LifeSnippetPost> postsForUser(String userKey) {
    return visiblePosts(LifeSnippetFeedFilter.popular)
        .where((post) => post.authorKey == userKey)
        .toList();
  }

  List<LifeSnippetComment> commentsForPost(String postKey) {
    final post = _seedPosts.firstWhere(
      (post) => post.postKey == postKey,
      orElse: () => _emptyPost,
    );
    final comments = [
      ...post.seedComments,
      ...(_commentsByPost[postKey] ?? const <LifeSnippetComment>[]),
    ].where((comment) {
      return !_moderation.shouldHide(
        contentKey: comment.commentKey,
        authorKey: comment.authorKey,
      );
    }).toList();
    comments.sort((left, right) => left.createdAt.compareTo(right.createdAt));
    return comments;
  }

  int visibleCommentCount(LifeSnippetPost post) {
    return commentsForPost(post.postKey).length;
  }

  int visibleLikeCount(LifeSnippetPost post) {
    return post.likeCount + (_likedPostKeys.contains(post.postKey) ? 1 : 0);
  }

  bool isPostLiked(String postKey) {
    return _likedPostKeys.contains(postKey);
  }

  LifeFollowStatus followStatusFor(String userKey) {
    if (_followingUserKeys.contains(userKey)) {
      return LifeFollowStatus.following;
    }
    if (_outgoingFollowRequests.contains(userKey)) {
      return LifeFollowStatus.requested;
    }
    return LifeFollowStatus.none;
  }

  bool isMutualFollow(String userKey) {
    return _followingUserKeys.contains(userKey) &&
        _followerUserKeys.contains(userKey);
  }

  List<LifeChatMessage> chatMessagesFor(String userKey) {
    return List.unmodifiable(_chatThreads[userKey] ?? const []);
  }

  Future<void> requestFollow(String userKey) async {
    if (userKey == _currentUser.userKey ||
        _followingUserKeys.contains(userKey)) {
      return;
    }

    await load();
    _outgoingFollowRequests.add(userKey);
    await _saveStringSet(_outgoingFollowRequestsKey, _outgoingFollowRequests);
    notifyListeners();
  }

  Future<void> toggleLike(String postKey) async {
    await load();
    if (!_likedPostKeys.add(postKey)) {
      _likedPostKeys.remove(postKey);
    }
    await _saveStringSet(_likedPostsKey, _likedPostKeys);
    notifyListeners();
  }

  Future<void> addComment({
    required String postKey,
    required String body,
  }) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return;
    }

    await load();
    final comment = LifeSnippetComment(
      commentKey: 'comment-${DateTime.now().microsecondsSinceEpoch}',
      authorKey: _currentUser.userKey,
      body: trimmed,
      createdAt: DateTime.now(),
    );
    final comments = _commentsByPost.putIfAbsent(postKey, () => []);
    comments.add(comment);
    await _saveComments();
    notifyListeners();
  }

  Future<void> submitPostForReview({
    required String body,
    required List<LifeSnippetMedia> media,
  }) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty && media.isEmpty) {
      return;
    }

    await load();
    _pendingReviewPosts.insert(
      0,
      LifeSnippetPost(
        postKey: 'pending-${DateTime.now().microsecondsSinceEpoch}',
        authorKey: _currentUser.userKey,
        body: trimmed,
        media: media,
        createdAt: DateTime.now(),
        likeCount: 0,
        commentCount: 0,
        isPendingReview: true,
      ),
    );
    await _preferences!.setString(
      _pendingPostsKey,
      jsonEncode(_pendingReviewPosts.map((post) => post.toJson()).toList()),
    );
    notifyListeners();
  }

  Future<void> reportPost(LifeSnippetPost post) async {
    final author = userByKey(post.authorKey);
    await _moderation.reportContent(
      target: MorrowlyModerationTarget(
        contentKey: post.postKey,
        authorKey: author.userKey,
        authorName: author.displayName,
        kind: MorrowlyModerationKind.snippet,
      ),
      reason: MorrowlyReportReason.inappropriate,
    );
  }

  Future<void> reportComment(LifeSnippetComment comment) async {
    final author = userByKey(comment.authorKey);
    await _moderation.reportContent(
      target: MorrowlyModerationTarget(
        contentKey: comment.commentKey,
        authorKey: author.userKey,
        authorName: author.displayName,
        kind: MorrowlyModerationKind.comment,
      ),
      reason: MorrowlyReportReason.inappropriate,
    );
  }

  Future<void> blockUser(String userKey) async {
    final user = userByKey(userKey);
    await _moderation.blockAuthor(
      MorrowlyModerationTarget(
        contentKey: 'author-$userKey',
        authorKey: user.userKey,
        authorName: user.displayName,
        kind: MorrowlyModerationKind.snippet,
      ),
    );
    _outgoingFollowRequests.remove(userKey);
    _followingUserKeys.remove(userKey);
    _followerUserKeys.remove(userKey);
    await _saveStringSet(_outgoingFollowRequestsKey, _outgoingFollowRequests);
    await _saveStringSet(_followingUserKeysKey, _followingUserKeys);
    await _saveStringSet(_followerUserKeysKey, _followerUserKeys);
    notifyListeners();
  }

  Future<void> sendMessage({
    required String userKey,
    required String body,
  }) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return;
    }
    if (!isMutualFollow(userKey)) {
      throw const LifeSnippetRelationshipGate();
    }

    await load();
    final thread = _chatThreads.putIfAbsent(userKey, () => []);
    thread.add(
      LifeChatMessage(
        messageKey: 'message-${DateTime.now().microsecondsSinceEpoch}',
        senderKey: _currentUser.userKey,
        body: trimmed,
        createdAt: DateTime.now(),
      ),
    );
    await _saveChatThreads();
    notifyListeners();
  }

  Future<void> _load() async {
    _preferences = await SharedPreferences.getInstance();
    await _moderation.load();
    if (!_isListeningToModeration) {
      _moderation.addListener(notifyListeners);
      _isListeningToModeration = true;
    }

    _likedPostKeys
      ..clear()
      ..addAll(_preferences!.getStringList(_likedPostsKey) ?? const []);
    _outgoingFollowRequests
      ..clear()
      ..addAll(
        _preferences!.getStringList(_outgoingFollowRequestsKey) ?? const [],
      );
    _followingUserKeys
      ..clear()
      ..addAll(_preferences!.getStringList(_followingUserKeysKey) ?? const []);
    _followerUserKeys
      ..clear()
      ..addAll(_preferences!.getStringList(_followerUserKeysKey) ?? const []);

    _loadPendingPosts();
    _loadComments();
    _loadChatThreads();

    final gateStore = await LocalGateStore.open();
    _currentUser = LifeSnippetUser(
      userKey: currentUserKey,
      displayName: gateStore.savedDisplayName.isEmpty
          ? 'Morrowly friend'
          : gateStore.savedDisplayName,
      ageLine: '23',
      placeLine: gateStore.savedRegion,
      avatarAsset: 'assets/images/head/bloom_arch_window.jpg',
      avatarLocalPath: gateStore.savedAvatarPath,
      signatureLine: gateStore.savedSignatureLine.isEmpty
          ? 'Preserve wishes for future you'
          : gateStore.savedSignatureLine,
      isCurrentUser: true,
      followCount: _followingUserKeys.length,
      fansCount: _followerUserKeys.length,
      likeCount: 0,
      capsuleCount: _pendingReviewPosts.length,
    );
    notifyListeners();
  }

  void _loadPendingPosts() {
    _pendingReviewPosts
      ..clear()
      ..addAll(
        decodeJsonObjectList(
          _preferences!.getString(_pendingPostsKey) ?? '[]',
        ).map(LifeSnippetPost.fromJson),
      );
  }

  void _loadComments() {
    _commentsByPost.clear();
    final decoded = jsonDecode(_preferences!.getString(_commentsKey) ?? '{}');
    if (decoded is! Map) {
      return;
    }
    for (final entry in decoded.entries) {
      final postKey = '${entry.key}';
      final value = entry.value;
      if (value is! List) {
        continue;
      }
      _commentsByPost[postKey] = value
          .map(castJsonObject)
          .map(LifeSnippetComment.fromJson)
          .toList();
    }
  }

  void _loadChatThreads() {
    _chatThreads.clear();
    final decoded = jsonDecode(_preferences!.getString(_chatThreadsKey) ?? '{}');
    if (decoded is! Map) {
      return;
    }
    for (final entry in decoded.entries) {
      final userKey = '${entry.key}';
      final value = entry.value;
      if (value is! List) {
        continue;
      }
      _chatThreads[userKey] = value
          .map(castJsonObject)
          .map(LifeChatMessage.fromJson)
          .toList();
    }
  }

  Future<void> _saveComments() async {
    final encoded = <String, Object?>{
      for (final entry in _commentsByPost.entries)
        entry.key: entry.value.map((comment) => comment.toJson()).toList(),
    };
    await _preferences!.setString(_commentsKey, jsonEncode(encoded));
  }

  Future<void> _saveChatThreads() async {
    final encoded = <String, Object?>{
      for (final entry in _chatThreads.entries)
        entry.key: entry.value.map((message) => message.toJson()).toList(),
    };
    await _preferences!.setString(_chatThreadsKey, jsonEncode(encoded));
  }

  Future<void> _saveStringSet(String key, Set<String> values) async {
    await _preferences!.setStringList(key, values.toList()..sort());
  }
}

const _fallbackCurrentUser = LifeSnippetUser(
  userKey: LifeSnippetStore.currentUserKey,
  displayName: 'Morrowly friend',
  ageLine: '23',
  placeLine: 'United States',
  avatarAsset: 'assets/images/head/bloom_arch_window.jpg',
  signatureLine: 'Preserve wishes for future you',
  isCurrentUser: true,
);

const _seedUsers = [
  LifeSnippetUser(
    userKey: 'carolyn-massey',
    displayName: 'Carolyn Massey',
    ageLine: '23',
    placeLine: 'Australia',
    avatarAsset: 'assets/images/head/bloom_arch_window.jpg',
    signatureLine: 'Preserve wishes for future you',
    followCount: 246,
    fansCount: 28,
    likeCount: 1214,
    capsuleCount: 784,
  ),
  LifeSnippetUser(
    userKey: 'evan-perkins',
    displayName: 'Evan Perkins',
    ageLine: '25',
    placeLine: 'Canada',
    avatarAsset: 'assets/images/head/muse_cafe_shadow.jpg',
    signatureLine: 'Save small weather from ordinary days',
    followCount: 180,
    fansCount: 42,
    likeCount: 936,
    capsuleCount: 318,
  ),
  LifeSnippetUser(
    userKey: 'talia-arden',
    displayName: 'Talia Arden',
    ageLine: '21',
    placeLine: 'Switzerland',
    avatarAsset: 'assets/images/head/bloom_lake_glow.jpg',
    signatureLine: 'Let a softer future find the proof',
    followCount: 319,
    fansCount: 64,
    likeCount: 1430,
    capsuleCount: 529,
  ),
];

final _seedPosts = [
  LifeSnippetPost(
    postKey: 'snippet-sunrise-lake',
    authorKey: 'carolyn-massey',
    body:
        'I hope scattered life can also have passionate romance. You must be happy in the future!',
    media: const [
      LifeSnippetMedia(
        mediaKey: 'sunrise-lake-a',
        path: 'assets/images/post/memory_lake_cocktail_view.jpg',
        kind: LifeSnippetMediaKind.asset,
      ),
      LifeSnippetMedia(
        mediaKey: 'sunrise-lake-b',
        path: 'assets/images/post/memory_harbor_supper_sunset.jpg',
        kind: LifeSnippetMediaKind.asset,
      ),
    ],
    createdAt: DateTime(2025, 11, 25, 8, 45),
    likeCount: 123,
    commentCount: 2,
    seedComments: [
      LifeSnippetComment(
        commentKey: 'comment-evan-coffee',
        authorKey: 'evan-perkins',
        body:
            'This hand brewed coffee is very fragrant and has a faint jasmine aroma.',
        createdAt: DateTime(2025, 11, 25, 8, 45),
      ),
      LifeSnippetComment(
        commentKey: 'comment-talia-soft',
        authorKey: 'talia-arden',
        body: 'This sunset looks like it kept a promise for later.',
        createdAt: DateTime(2025, 11, 25, 9, 10),
      ),
    ],
  ),
  LifeSnippetPost(
    postKey: 'snippet-window-note',
    authorKey: 'talia-arden',
    body:
        'Leaving a tiny note for the year I finally stop rushing through beautiful things.',
    media: const [
      LifeSnippetMedia(
        mediaKey: 'window-note-a',
        path: 'assets/images/post/memory_dusk_window_note.jpg',
        kind: LifeSnippetMediaKind.asset,
      ),
      LifeSnippetMedia(
        mediaKey: 'window-note-b',
        path: 'assets/images/post/memory_coffee_letter_table.jpg',
        kind: LifeSnippetMediaKind.asset,
      ),
    ],
    createdAt: DateTime(2025, 11, 21, 18, 30),
    likeCount: 89,
    commentCount: 1,
    seedComments: [
      LifeSnippetComment(
        commentKey: 'comment-carolyn-window',
        authorKey: 'carolyn-massey',
        body: 'The quiet in this feels expensive in the best way.',
        createdAt: DateTime(2025, 11, 21, 19, 5),
      ),
    ],
  ),
  LifeSnippetPost(
    postKey: 'snippet-market-light',
    authorKey: 'evan-perkins',
    body:
        'Today looked ordinary until the market light landed on everyone at once.',
    media: const [
      LifeSnippetMedia(
        mediaKey: 'market-light-a',
        path: 'assets/images/post/memory_flower_market_smile.jpg',
        kind: LifeSnippetMediaKind.asset,
      ),
      LifeSnippetMedia(
        mediaKey: 'market-light-b',
        path: 'assets/images/post/memory_green_path_turn.jpg',
        kind: LifeSnippetMediaKind.asset,
      ),
    ],
    createdAt: DateTime(2025, 11, 18, 16, 12),
    likeCount: 76,
    commentCount: 0,
  ),
];

final _emptyPost = LifeSnippetPost(
  postKey: '',
  authorKey: '',
  body: '',
  media: const [],
  createdAt: DateTime(2000),
  likeCount: 0,
  commentCount: 0,
);
