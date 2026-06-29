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
  static const _followingUserKeysKey =
      'morrowly.lifeSnippets.followingUserKeys';
  static const _followerUserKeysKey = 'morrowly.lifeSnippets.followerUserKeys';
  static const _chatThreadsKey = 'morrowly.lifeSnippets.chatThreads';
  static const _deletedPostKeysKey = 'morrowly.lifeSnippets.deletedPostKeys';

  final MorrowlyModerationStore _moderation = MorrowlyModerationStore.instance;
  final Set<String> _likedPostKeys = {};
  final Set<String> _outgoingFollowRequests = {};
  final Set<String> _followingUserKeys = {};
  final Set<String> _followerUserKeys = {};
  final Set<String> _deletedPostKeys = {};
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

  List<LifeSnippetUser> get followListUsers {
    final keys = {..._followingUserKeys, ..._outgoingFollowRequests};
    return keys
        .map(userByKey)
        .where((user) => !user.isCurrentUser)
        .where((user) => !_moderation.isAuthorBlocked(user.userKey))
        .toList();
  }

  List<LifeSnippetUser> get fanListUsers {
    return _followerUserKeys
        .map(userByKey)
        .where((user) => !user.isCurrentUser)
        .where((user) => !_moderation.isAuthorBlocked(user.userKey))
        .toList();
  }

  List<LifeSnippetUser> get blockedUsers {
    return _moderation.blockedAuthorKeys
        .map(_knownUserByKey)
        .whereType<LifeSnippetUser>()
        .where((user) => !user.isCurrentUser)
        .toList();
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

  LifeSnippetUser? _knownUserByKey(String userKey) {
    if (userKey == _currentUser.userKey) {
      return _currentUser;
    }
    for (final user in _seedUsers) {
      if (user.userKey == userKey) {
        return user;
      }
    }
    return null;
  }

  LifeSnippetPost? postByKey(String postKey) {
    for (final post in _seedPosts) {
      if (post.postKey == postKey) {
        if (shouldHidePost(post)) {
          return null;
        }
        return post;
      }
    }
    return null;
  }

  MorrowlyModerationTarget moderationTargetForPost(LifeSnippetPost post) {
    final author = userByKey(post.authorKey);
    return MorrowlyModerationTarget(
      contentKey: post.postKey,
      authorKey: author.userKey,
      authorName: author.displayName,
      kind: MorrowlyModerationKind.snippet,
    );
  }

  MorrowlyModerationTarget moderationTargetForComment(
    LifeSnippetComment comment,
  ) {
    final author = userByKey(comment.authorKey);
    return MorrowlyModerationTarget(
      contentKey: comment.commentKey,
      authorKey: author.userKey,
      authorName: author.displayName,
      kind: MorrowlyModerationKind.comment,
    );
  }

  MorrowlyModerationTarget moderationTargetForUser(String userKey) {
    final user = userByKey(userKey);
    return MorrowlyModerationTarget(
      contentKey: _profileContentKey(userKey),
      authorKey: user.userKey,
      authorName: user.displayName,
      kind: MorrowlyModerationKind.profile,
    );
  }

  bool shouldHidePost(LifeSnippetPost post) {
    return _moderation.shouldHide(
      contentKey: post.postKey,
      authorKey: post.authorKey,
    );
  }

  bool shouldHideComment(LifeSnippetComment comment) {
    return _moderation.shouldHide(
      contentKey: comment.commentKey,
      authorKey: comment.authorKey,
    );
  }

  bool shouldHideUserProfile(String userKey) {
    return _moderation.shouldHide(
      contentKey: _profileContentKey(userKey),
      authorKey: userKey,
    );
  }

  bool isUserBlocked(String userKey) {
    return _moderation.isAuthorBlocked(userKey);
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
    return visiblePosts(
      LifeSnippetFeedFilter.popular,
    ).where((post) => post.authorKey == userKey).toList();
  }

  List<LifeSnippetComment> commentsForPost(String postKey) {
    final post = _seedPosts.firstWhere(
      (post) => post.postKey == postKey,
      orElse: () => _emptyPost,
    );
    final comments =
        [
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
    if (_moderation.isAuthorBlocked(userKey)) {
      return false;
    }
    return _followingUserKeys.contains(userKey) &&
        _followerUserKeys.contains(userKey);
  }

  List<LifeChatMessage> chatMessagesFor(String userKey) {
    if (_moderation.isAuthorBlocked(userKey)) {
      return const [];
    }
    return List.unmodifiable(_chatThreads[userKey] ?? const []);
  }

  List<String> get chatThreadUserKeys {
    final keys = _chatThreads.entries
        .where((entry) => entry.value.isNotEmpty)
        .where((entry) => !_moderation.isAuthorBlocked(entry.key))
        .where((entry) => _knownUserByKey(entry.key) != null)
        .toList();
    keys.sort((left, right) {
      return right.value.last.createdAt.compareTo(left.value.last.createdAt);
    });
    return keys.map((entry) => entry.key).toList();
  }

  Future<void> requestFollow(String userKey) async {
    if (userKey == _currentUser.userKey ||
        _followingUserKeys.contains(userKey) ||
        _moderation.isAuthorBlocked(userKey)) {
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

  Future<void> reportPost(
    LifeSnippetPost post, {
    MorrowlyReportReason reason = MorrowlyReportReason.inappropriate,
  }) async {
    await load();
    await _moderation.reportContent(
      target: moderationTargetForPost(post),
      reason: reason,
    );
  }

  Future<void> reportComment(
    LifeSnippetComment comment, {
    MorrowlyReportReason reason = MorrowlyReportReason.inappropriate,
  }) async {
    await load();
    await _moderation.reportContent(
      target: moderationTargetForComment(comment),
      reason: reason,
    );
  }

  Future<void> reportUser(
    String userKey, {
    MorrowlyReportReason reason = MorrowlyReportReason.inappropriate,
  }) async {
    await load();
    await _moderation.reportContent(
      target: moderationTargetForUser(userKey),
      reason: reason,
    );
  }

  Future<void> blockUser(String userKey) async {
    await load();
    await _moderation.blockAuthor(moderationTargetForUser(userKey));
    _outgoingFollowRequests.remove(userKey);
    _followingUserKeys.remove(userKey);
    _followerUserKeys.remove(userKey);
    await _saveStringSet(_outgoingFollowRequestsKey, _outgoingFollowRequests);
    await _saveStringSet(_followingUserKeysKey, _followingUserKeys);
    await _saveStringSet(_followerUserKeysKey, _followerUserKeys);
    notifyListeners();
  }

  Future<void> unblockUser(String userKey) async {
    await _moderation.unblockAuthor(userKey);
    notifyListeners();
  }

  Future<void> updateCurrentUserProfile({
    required String displayName,
    required String signatureLine,
    required String avatarLocalPath,
    required String gender,
    required String region,
    required String birthDate,
  }) async {
    final gateStore = await LocalGateStore.open();
    await gateStore.updateProfile(
      displayName: displayName,
      signatureLine: signatureLine,
      avatarLocalPath: avatarLocalPath,
      gender: gender,
      region: region,
      birthDate: birthDate,
    );
    _currentUser = _currentUserFromGate(gateStore);
    notifyListeners();
  }

  Future<void> clearLocalAccountData() async {
    await load();
    _likedPostKeys.clear();
    _outgoingFollowRequests.clear();
    _followingUserKeys.clear();
    _followerUserKeys.clear();
    _commentsByPost.clear();
    _chatThreads.clear();
    _pendingReviewPosts.clear();
    await _preferences!.remove(_pendingPostsKey);
    await _preferences!.remove(_commentsKey);
    await _preferences!.remove(_likedPostsKey);
    await _preferences!.remove(_outgoingFollowRequestsKey);
    await _preferences!.remove(_followingUserKeysKey);
    await _preferences!.remove(_followerUserKeysKey);
    await _preferences!.remove(_chatThreadsKey);
    await _moderation.clearLocalRecords();
    _currentUser = _fallbackCurrentUser;
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
    if (_moderation.isAuthorBlocked(userKey)) {
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
    _currentUser = _currentUserFromGate(gateStore);
    notifyListeners();
  }

  LifeSnippetUser _currentUserFromGate(LocalGateStore gateStore) {
    return LifeSnippetUser(
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
    final decoded = jsonDecode(
      _preferences!.getString(_chatThreadsKey) ?? '{}',
    );
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

String _profileContentKey(String userKey) => 'profile-$userKey';

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
    postKey: 'snippet-lake-cocktail',
    authorKey: 'carolyn-massey',
    body:
        'I hope scattered life can also have passionate romance. You must be happy in the future!',
    media: const [
      LifeSnippetMedia(
        mediaKey: 'sunrise-lake-a',
        path: 'assets/images/post/memory_lake_cocktail_view.jpg',
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
    postKey: 'snippet-harbor-supper',
    authorKey: 'evan-perkins',
    body:
        'A sunset table, a few cards, and the kind of evening I want to remember slowly.',
    media: const [
      LifeSnippetMedia(
        mediaKey: 'harbor-supper-a',
        path: 'assets/images/post/memory_harbor_supper_sunset.jpg',
        kind: LifeSnippetMediaKind.asset,
      ),
    ],
    createdAt: DateTime(2025, 11, 24, 19, 18),
    likeCount: 116,
    commentCount: 0,
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
    postKey: 'snippet-coffee-letter',
    authorKey: 'carolyn-massey',
    body:
        'Coffee cooled beside the letter before I found the words I wanted to keep.',
    media: const [
      LifeSnippetMedia(
        mediaKey: 'coffee-letter-a',
        path: 'assets/images/post/memory_coffee_letter_table.jpg',
        kind: LifeSnippetMediaKind.asset,
      ),
    ],
    createdAt: DateTime(2025, 11, 20, 10, 12),
    likeCount: 102,
    commentCount: 0,
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
    ],
    createdAt: DateTime(2025, 11, 18, 16, 12),
    likeCount: 76,
    commentCount: 0,
  ),
  LifeSnippetPost(
    postKey: 'snippet-green-path',
    authorKey: 'talia-arden',
    body:
        'The path bent out of sight, so I saved the turn for a braver version of me.',
    media: const [
      LifeSnippetMedia(
        mediaKey: 'green-path-a',
        path: 'assets/images/post/memory_green_path_turn.jpg',
        kind: LifeSnippetMediaKind.asset,
      ),
    ],
    createdAt: DateTime(2025, 11, 17, 15, 4),
    likeCount: 84,
    commentCount: 0,
  ),
  LifeSnippetPost(
    postKey: 'snippet-amber-room',
    authorKey: 'carolyn-massey',
    body: 'This quiet amber corner made the whole day feel less temporary.',
    media: const [
      LifeSnippetMedia(
        mediaKey: 'amber-room-a',
        path: 'assets/images/post/memory_amber_room_table.jpg',
        kind: LifeSnippetMediaKind.asset,
      ),
    ],
    createdAt: DateTime(2025, 11, 16, 20, 22),
    likeCount: 91,
    commentCount: 0,
  ),
  LifeSnippetPost(
    postKey: 'snippet-beach-mat',
    authorKey: 'evan-perkins',
    body:
        'A beach mat, a warm pause, and one small proof that rest can be planned.',
    media: const [
      LifeSnippetMedia(
        mediaKey: 'beach-mat-a',
        path: 'assets/images/post/memory_beach_mat_memory.jpg',
        kind: LifeSnippetMediaKind.asset,
      ),
    ],
    createdAt: DateTime(2025, 11, 15, 14, 9),
    likeCount: 70,
    commentCount: 0,
  ),
  LifeSnippetPost(
    postKey: 'snippet-cafe-companion',
    authorKey: 'talia-arden',
    body: 'Some tables remember conversations better than we do.',
    media: const [
      LifeSnippetMedia(
        mediaKey: 'cafe-companion-a',
        path: 'assets/images/post/memory_cafe_companion_table.jpg',
        kind: LifeSnippetMediaKind.asset,
      ),
    ],
    createdAt: DateTime(2025, 11, 14, 11, 42),
    likeCount: 118,
    commentCount: 0,
  ),
  LifeSnippetPost(
    postKey: 'snippet-car-window',
    authorKey: 'carolyn-massey',
    body: 'The road kept moving, but the light stayed with me for a few miles.',
    media: const [
      LifeSnippetMedia(
        mediaKey: 'car-window-a',
        path: 'assets/images/post/memory_car_window_drive.jpg',
        kind: LifeSnippetMediaKind.asset,
      ),
    ],
    createdAt: DateTime(2025, 11, 13, 17, 28),
    likeCount: 63,
    commentCount: 0,
  ),
  LifeSnippetPost(
    postKey: 'snippet-cathedral-morning',
    authorKey: 'evan-perkins',
    body:
        'Morning made the stone look gentle, so I stood there longer than planned.',
    media: const [
      LifeSnippetMedia(
        mediaKey: 'cathedral-morning-a',
        path: 'assets/images/post/memory_cathedral_morning.jpg',
        kind: LifeSnippetMediaKind.asset,
      ),
    ],
    createdAt: DateTime(2025, 11, 12, 9, 36),
    likeCount: 95,
    commentCount: 0,
  ),
  LifeSnippetPost(
    postKey: 'snippet-garden-portrait',
    authorKey: 'talia-arden',
    body:
        'A garden portrait for the version of me that keeps choosing softness.',
    media: const [
      LifeSnippetMedia(
        mediaKey: 'garden-portrait-a',
        path: 'assets/images/post/memory_garden_portrait.jpg',
        kind: LifeSnippetMediaKind.asset,
      ),
    ],
    createdAt: DateTime(2025, 11, 11, 13, 18),
    likeCount: 132,
    commentCount: 0,
  ),
  LifeSnippetPost(
    postKey: 'snippet-hammock-valley',
    authorKey: 'carolyn-massey',
    body: 'If future me forgets how to slow down, start with this valley.',
    media: const [
      LifeSnippetMedia(
        mediaKey: 'hammock-valley-a',
        path: 'assets/images/post/memory_hammock_valley_rest.jpg',
        kind: LifeSnippetMediaKind.asset,
      ),
    ],
    createdAt: DateTime(2025, 11, 10, 16, 44),
    likeCount: 73,
    commentCount: 0,
  ),
  LifeSnippetPost(
    postKey: 'snippet-handheld-game',
    authorKey: 'evan-perkins',
    body: 'Tiny games are better when the afternoon has nowhere urgent to go.',
    media: const [
      LifeSnippetMedia(
        mediaKey: 'handheld-game-a',
        path: 'assets/images/post/memory_handheld_game_rest.jpg',
        kind: LifeSnippetMediaKind.asset,
      ),
    ],
    createdAt: DateTime(2025, 11, 9, 15, 20),
    likeCount: 58,
    commentCount: 0,
  ),
  LifeSnippetPost(
    postKey: 'snippet-lemonade-arcade',
    authorKey: 'talia-arden',
    body: 'A bright drink and an old machine made the day feel fictional.',
    media: const [
      LifeSnippetMedia(
        mediaKey: 'lemonade-arcade-a',
        path: 'assets/images/post/memory_lemonade_arcade.jpg',
        kind: LifeSnippetMediaKind.asset,
      ),
    ],
    createdAt: DateTime(2025, 11, 8, 12, 16),
    likeCount: 82,
    commentCount: 0,
  ),
  LifeSnippetPost(
    postKey: 'snippet-palm-street',
    authorKey: 'carolyn-massey',
    body: 'The palm street looked like it had already forgiven the week.',
    media: const [
      LifeSnippetMedia(
        mediaKey: 'palm-street-a',
        path: 'assets/images/post/memory_palm_street_walk.jpg',
        kind: LifeSnippetMediaKind.asset,
      ),
    ],
    createdAt: DateTime(2025, 11, 7, 18, 2),
    likeCount: 104,
    commentCount: 0,
  ),
  LifeSnippetPost(
    postKey: 'snippet-paper-wall',
    authorKey: 'evan-perkins',
    body: 'Paused by the paper wall and let the silence finish the sentence.',
    media: const [
      LifeSnippetMedia(
        mediaKey: 'paper-wall-a',
        path: 'assets/images/post/memory_paper_wall_pause.jpg',
        kind: LifeSnippetMediaKind.asset,
      ),
    ],
    createdAt: DateTime(2025, 11, 6, 10, 50),
    likeCount: 77,
    commentCount: 0,
  ),
  LifeSnippetPost(
    postKey: 'snippet-poolside-wings',
    authorKey: 'talia-arden',
    body: 'A poolside picture for the days that need proof of sunlight.',
    media: const [
      LifeSnippetMedia(
        mediaKey: 'poolside-wings-a',
        path: 'assets/images/post/memory_poolside_wings.jpg',
        kind: LifeSnippetMediaKind.asset,
      ),
    ],
    createdAt: DateTime(2025, 11, 5, 14, 37),
    likeCount: 125,
    commentCount: 0,
  ),
  LifeSnippetPost(
    postKey: 'snippet-quiet-stair',
    authorKey: 'carolyn-massey',
    body: 'Waiting on the quiet stair felt less lonely than rushing past it.',
    media: const [
      LifeSnippetMedia(
        mediaKey: 'quiet-stair-a',
        path: 'assets/images/post/memory_quiet_stair_wait.jpg',
        kind: LifeSnippetMediaKind.asset,
      ),
    ],
    createdAt: DateTime(2025, 11, 4, 9, 24),
    likeCount: 66,
    commentCount: 0,
  ),
  LifeSnippetPost(
    postKey: 'snippet-resort-pool',
    authorKey: 'evan-perkins',
    body: 'The pool was still enough to make every plan feel optional.',
    media: const [
      LifeSnippetMedia(
        mediaKey: 'resort-pool-a',
        path: 'assets/images/post/memory_resort_pool_still.jpg',
        kind: LifeSnippetMediaKind.asset,
      ),
    ],
    createdAt: DateTime(2025, 11, 3, 16, 8),
    likeCount: 88,
    commentCount: 0,
  ),
  LifeSnippetPost(
    postKey: 'snippet-travel-mirror',
    authorKey: 'talia-arden',
    body: 'Travel mirror, narrow lane, and one small version of becoming.',
    media: const [
      LifeSnippetMedia(
        mediaKey: 'travel-mirror-a',
        path: 'assets/images/post/memory_travel_mirror_lane.jpg',
        kind: LifeSnippetMediaKind.asset,
      ),
    ],
    createdAt: DateTime(2025, 11, 2, 18, 55),
    likeCount: 99,
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
