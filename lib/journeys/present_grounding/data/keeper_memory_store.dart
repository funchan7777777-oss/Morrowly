import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:morrowly/journeys/present_grounding/models/keeper_memory_thread.dart';
import 'package:morrowly/journeys/time_capsule/data/capsule_square_seed.dart';
import 'package:morrowly/journeys/time_capsule/models/capsule_chronicle.dart';
import 'package:morrowly/journeys/welcome_gate/data/local_gate_store.dart';
import 'package:morrowly/shared/moderation/morrowly_content_safety.dart';
import 'package:morrowly/shared/moderation/morrowly_moderation_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _signedInKeeperPlaceholderAvatar = '';

class MutualKeeperGate implements Exception {
  const MutualKeeperGate();
}

class KeeperReplyNotice {
  const KeeperReplyNotice({required this.post, required this.comment});

  final MemorySeal post;
  final MemoryReplyNote comment;
}

class KeeperMemoryStore extends ChangeNotifier {
  KeeperMemoryStore._();

  static final KeeperMemoryStore instance = KeeperMemoryStore._();

  static const signedInKeeperId = 'current-user';
  static const _reviewQueueSealsKey = 'morrowly.keeperMemory.reviewQueueSeals';
  static const _replyNotesKey = 'morrowly.keeperMemory.replyNotesBySeal';
  static const _glowedSealsKey = 'morrowly.keeperMemory.glowedSealIds';
  static const _outgoingKeeperRequestsKey =
      'morrowly.keeperMemory.outgoingKeeperRequests';
  static const _followedKeepersKey = 'morrowly.keeperMemory.followedKeeperIds';
  static const _followerKeepersKey = 'morrowly.keeperMemory.followerKeeperIds';
  static const _chatThreadsKey = 'morrowly.keeperMemory.letterThreads';
  static const _hiddenSealIdsKey = 'morrowly.keeperMemory.hiddenSealIds';
  static const _autoFollowerSeededKey =
      'morrowly.keeperMemory.autoFollowerSeeded';

  final MorrowlyModerationStore _moderation = MorrowlyModerationStore.instance;
  final Set<String> _glowedSealIds = {};
  final Set<String> _outgoingKeeperRequests = {};
  final Set<String> _followedKeeperIds = {};
  final Set<String> _followerKeeperIds = {};
  final Set<String> _hiddenSealIds = {};
  final Map<String, List<MemoryReplyNote>> _replyNotesBySeal = {};
  final Map<String, List<KeeperLetter>> _chatThreads = {};
  final List<MemorySeal> _reviewQueueSeals = [];

  SharedPreferences? _preferences;
  KeeperProfile _signedInKeeper = _fallbackSignedInKeeper;
  Future<void>? _loading;
  bool _isListeningToModeration = false;

  bool get isLoaded => _preferences != null;
  KeeperProfile get signedInKeeper => _signedInKeeper;
  List<MemorySeal> get reviewQueueSeals => List.unmodifiable(_reviewQueueSeals);

  List<KeeperProfile> get people {
    return [_signedInKeeper, ..._seedUsers];
  }

  List<KeeperProfile> get followListUsers {
    final keys = {..._followedKeeperIds, ..._outgoingKeeperRequests};
    return keys
        .map(keeperById)
        .where((user) => !user.belongsToSignedInKeeper)
        .where((user) => !_moderation.isKeeperBlocked(user.keeperId))
        .toList();
  }

  List<KeeperProfile> get fanListUsers {
    return _followerKeeperIds
        .map(keeperById)
        .where((user) => !user.belongsToSignedInKeeper)
        .where((user) => !_moderation.isKeeperBlocked(user.keeperId))
        .toList();
  }

  List<KeeperProfile> get incomingFollowRequestUsers {
    return _followerKeeperIds
        .where((keeperId) => !_followedKeeperIds.contains(keeperId))
        .map(keeperById)
        .where((user) => !user.belongsToSignedInKeeper)
        .where((user) => !_moderation.isKeeperBlocked(user.keeperId))
        .toList();
  }

  List<KeeperProfile> get mutualFriendUsers {
    return _followerKeeperIds
        .where(_followedKeeperIds.contains)
        .map(keeperById)
        .where((user) => !user.belongsToSignedInKeeper)
        .where((user) => !_moderation.isKeeperBlocked(user.keeperId))
        .toList();
  }

  List<KeeperReplyNotice> get replyNotices {
    final notices = <KeeperReplyNotice>[];
    for (final post in postsForUser(_signedInKeeper.keeperId)) {
      for (final comment in repliesForSeal(post.sealId)) {
        if (comment.authorKeeperId == _signedInKeeper.keeperId) {
          continue;
        }
        notices.add(KeeperReplyNotice(post: post, comment: comment));
      }
    }
    notices.sort(
      (left, right) => right.comment.pennedAt.compareTo(left.comment.pennedAt),
    );
    return List.unmodifiable(notices);
  }

  List<MemorySeal> get glowedSeals {
    return visiblePosts(
      MemoryShelfFilter.popular,
    ).where((post) => _glowedSealIds.contains(post.sealId)).toList();
  }

  List<KeeperProfile> get blockedUsers {
    return _moderation.blockedKeeperIds
        .map(_knownKeeperById)
        .whereType<KeeperProfile>()
        .where((user) => !user.belongsToSignedInKeeper)
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

  KeeperProfile keeperById(String keeperId) {
    if (keeperId == _signedInKeeper.keeperId) {
      return _signedInKeeper;
    }
    return _seedUsers.firstWhere(
      (user) => user.keeperId == keeperId,
      orElse: () => _capsuleKeeperById(keeperId) ?? _seedUsers.first,
    );
  }

  KeeperProfile? _knownKeeperById(String keeperId) {
    if (keeperId == _signedInKeeper.keeperId) {
      return _signedInKeeper;
    }
    for (final user in _seedUsers) {
      if (user.keeperId == keeperId) {
        return user;
      }
    }
    final capsuleUser = _capsuleKeeperById(keeperId);
    if (capsuleUser != null) {
      return capsuleUser;
    }
    return null;
  }

  KeeperProfile? _capsuleKeeperById(String keeperId) {
    if (keeperId == CapsuleSquareSeed.currentKeeper.keeperId) {
      return _signedInKeeper;
    }
    for (final keeper in CapsuleSquareSeed.allKeepers) {
      if (keeper.keeperId == keeperId) {
        return _lifeUserForCapsuleKeeper(keeper);
      }
    }
    return null;
  }

  KeeperProfile _lifeUserForCapsuleKeeper(CapsuleKeeper keeper) {
    for (final user in _seedUsers) {
      if (user.publicName == keeper.publicName ||
          user.portraitAsset == keeper.portraitAsset) {
        return user;
      }
    }
    return KeeperProfile(
      keeperId: keeper.keeperId,
      publicName: keeper.publicName,
      ageMark: keeper.ageMark,
      homeRegion: keeper.homeRegion,
      portraitAsset: keeper.portraitAsset,
      localPortraitPath: keeper.localPortraitPath,
      morrowLine: 'Leave tomorrow something kind to find',
    );
  }

  MemorySeal? sealById(String sealId) {
    for (final post in _seedPosts) {
      if (post.sealId == sealId) {
        if (shouldHidePost(post)) {
          return null;
        }
        return post;
      }
    }
    return null;
  }

  MorrowlyModerationTarget moderationTargetForPost(MemorySeal post) {
    final author = keeperById(post.authorKeeperId);
    return MorrowlyModerationTarget(
      contentKey: post.sealId,
      authorKeeperId: author.keeperId,
      authorName: author.publicName,
      sourceKind: MorrowlyModerationKind.memorySeal,
    );
  }

  MorrowlyModerationTarget moderationTargetForComment(MemoryReplyNote comment) {
    final author = keeperById(comment.authorKeeperId);
    return MorrowlyModerationTarget(
      contentKey: comment.replyId,
      authorKeeperId: author.keeperId,
      authorName: author.publicName,
      sourceKind: MorrowlyModerationKind.comment,
    );
  }

  MorrowlyModerationTarget moderationTargetForUser(String keeperId) {
    final user = keeperById(keeperId);
    return MorrowlyModerationTarget(
      contentKey: _profileContentKey(keeperId),
      authorKeeperId: user.keeperId,
      authorName: user.publicName,
      sourceKind: MorrowlyModerationKind.profile,
    );
  }

  bool shouldHidePost(MemorySeal post) {
    return _moderation.shouldHide(
      contentKey: post.sealId,
      authorKeeperId: post.authorKeeperId,
    );
  }

  bool shouldHideComment(MemoryReplyNote comment) {
    return _moderation.shouldHide(
      contentKey: comment.replyId,
      authorKeeperId: comment.authorKeeperId,
    );
  }

  bool shouldHideUserProfile(String keeperId) {
    return _moderation.shouldHide(
      contentKey: _profileContentKey(keeperId),
      authorKeeperId: keeperId,
    );
  }

  bool isUserBlocked(String keeperId) {
    return _moderation.isKeeperBlocked(keeperId);
  }

  List<MemorySeal> visiblePosts(MemoryShelfFilter filter) {
    final posts = _seedPosts.where((post) {
      if (post.awaitsReview) {
        return false;
      }
      if (_hiddenSealIds.contains(post.sealId)) {
        return false;
      }
      if (filter == MemoryShelfFilter.followed &&
          !_followedKeeperIds.contains(post.authorKeeperId)) {
        return false;
      }
      return !_moderation.shouldHide(
        contentKey: post.sealId,
        authorKeeperId: post.authorKeeperId,
      );
    }).toList();

    posts.sort((left, right) => right.sealedAt.compareTo(left.sealedAt));
    return posts;
  }

  List<MemorySeal> postsForUser(String keeperId) {
    return visiblePosts(
      MemoryShelfFilter.popular,
    ).where((post) => post.authorKeeperId == keeperId).toList();
  }

  List<MemoryReplyNote> repliesForSeal(String sealId) {
    final post = _seedPosts.firstWhere(
      (post) => post.sealId == sealId,
      orElse: () => _emptyPost,
    );
    final replies =
        [
          ...post.seedReplyNotes,
          ...(_replyNotesBySeal[sealId] ?? const <MemoryReplyNote>[]),
        ].where((comment) {
          return !_moderation.shouldHide(
            contentKey: comment.replyId,
            authorKeeperId: comment.authorKeeperId,
          );
        }).toList();
    replies.sort((left, right) => left.pennedAt.compareTo(right.pennedAt));
    return replies;
  }

  int visibleReplyCount(MemorySeal post) {
    return repliesForSeal(post.sealId).length;
  }

  int visibleLikeCount(MemorySeal post) {
    return post.glowCount + (_glowedSealIds.contains(post.sealId) ? 1 : 0);
  }

  int profileFollowCountFor(String keeperId) {
    if (keeperId == signedInKeeperId) {
      return _followedKeeperIds.length;
    }
    final user = keeperById(keeperId);
    return min(user.followingCount, 12);
  }

  int profileFansCountFor(String keeperId) {
    if (keeperId == signedInKeeperId) {
      return _followerKeeperIds.length;
    }
    final user = keeperById(keeperId);
    return min(user.followerCount, 9);
  }

  int profileLikeCountFor(String keeperId) {
    final userPosts = postsForUser(keeperId);
    return userPosts.fold<int>(
      0,
      (total, post) => total + visibleLikeCount(post),
    );
  }

  int profileCapsuleCountFor(String keeperId) {
    if (keeperId == signedInKeeperId) {
      return _reviewQueueSeals.length;
    }
    return postsForUser(keeperId).length;
  }

  bool isPostLiked(String sealId) {
    return _glowedSealIds.contains(sealId);
  }

  KeeperLinkState followStatusFor(String keeperId) {
    if (_followedKeeperIds.contains(keeperId)) {
      return KeeperLinkState.following;
    }
    if (_outgoingKeeperRequests.contains(keeperId)) {
      return KeeperLinkState.requested;
    }
    return KeeperLinkState.none;
  }

  bool isMutualFollow(String keeperId) {
    if (_moderation.isKeeperBlocked(keeperId)) {
      return false;
    }
    return _followedKeeperIds.contains(keeperId) &&
        _followerKeeperIds.contains(keeperId);
  }

  List<KeeperLetter> chatMessagesFor(String keeperId) {
    if (_moderation.isKeeperBlocked(keeperId) || !isMutualFollow(keeperId)) {
      return const [];
    }
    return List.unmodifiable(_chatThreads[keeperId] ?? const []);
  }

  List<String> get letterThreadKeeperIds {
    final keys = _chatThreads.entries
        .where((entry) => entry.value.isNotEmpty)
        .where((entry) => !_moderation.isKeeperBlocked(entry.key))
        .where((entry) => isMutualFollow(entry.key))
        .where((entry) => _knownKeeperById(entry.key) != null)
        .toList();
    keys.sort((left, right) {
      return right.value.last.sentAt.compareTo(left.value.last.sentAt);
    });
    return keys.map((entry) => entry.key).toList();
  }

  Future<void> requestFollow(String keeperId) async {
    await load();
    if (keeperId == _signedInKeeper.keeperId ||
        _followedKeeperIds.contains(keeperId) ||
        _moderation.isKeeperBlocked(keeperId)) {
      return;
    }

    if (_followerKeeperIds.contains(keeperId)) {
      _outgoingKeeperRequests.remove(keeperId);
      _followedKeeperIds.add(keeperId);
      await _saveStringSet(_outgoingKeeperRequestsKey, _outgoingKeeperRequests);
      await _saveStringSet(_followedKeepersKey, _followedKeeperIds);
    } else {
      _outgoingKeeperRequests.add(keeperId);
      await _saveStringSet(_outgoingKeeperRequestsKey, _outgoingKeeperRequests);
    }
    _refreshCurrentUserCounts();
    notifyListeners();
  }

  Future<void> acceptIncomingFollow(String keeperId) async {
    await load();
    if (!_followerKeeperIds.contains(keeperId) ||
        _moderation.isKeeperBlocked(keeperId)) {
      return;
    }
    _outgoingKeeperRequests.remove(keeperId);
    _followedKeeperIds.add(keeperId);
    await _saveStringSet(_outgoingKeeperRequestsKey, _outgoingKeeperRequests);
    await _saveStringSet(_followedKeepersKey, _followedKeeperIds);
    _refreshCurrentUserCounts();
    notifyListeners();
  }

  Future<void> toggleLike(String sealId) async {
    await load();
    if (!_glowedSealIds.add(sealId)) {
      _glowedSealIds.remove(sealId);
    }
    await _saveStringSet(_glowedSealsKey, _glowedSealIds);
    notifyListeners();
  }

  Future<void> addComment({
    required String sealId,
    required String replyText,
  }) async {
    final trimmed = replyText.trim();
    if (trimmed.isEmpty) {
      return;
    }
    MorrowlyContentSafety.ensureText(
      trimmed,
      surface: MorrowlySafetySurface.comment,
    );

    await load();
    final comment = MemoryReplyNote(
      replyId: 'comment-${DateTime.now().microsecondsSinceEpoch}',
      authorKeeperId: _signedInKeeper.keeperId,
      noteLine: trimmed,
      pennedAt: DateTime.now(),
    );
    final replies = _replyNotesBySeal.putIfAbsent(sealId, () => []);
    replies.add(comment);
    await _saveComments();
    notifyListeners();
  }

  Future<void> deleteOwnPostLocally(MemorySeal post) async {
    await load();
    if (post.authorKeeperId != _signedInKeeper.keeperId) {
      return;
    }
    _hiddenSealIds.add(post.sealId);
    await _saveStringSet(_hiddenSealIdsKey, _hiddenSealIds);
    notifyListeners();
  }

  Future<void> submitPostForReview({
    required String noteLine,
    required List<MemoryAttachment> attachments,
  }) async {
    final trimmed = noteLine.trim();
    if (trimmed.isEmpty && attachments.isEmpty) {
      return;
    }
    if (trimmed.isNotEmpty) {
      MorrowlyContentSafety.ensureText(
        trimmed,
        surface: MorrowlySafetySurface.publicMemorySeal,
      );
    }

    await load();
    _reviewQueueSeals.insert(
      0,
      MemorySeal(
        sealId: 'pending-${DateTime.now().microsecondsSinceEpoch}',
        authorKeeperId: _signedInKeeper.keeperId,
        noteLine: trimmed,
        attachments: attachments,
        sealedAt: DateTime.now(),
        glowCount: 0,
        replyCount: 0,
        awaitsReview: true,
      ),
    );
    await _preferences!.setString(
      _reviewQueueSealsKey,
      jsonEncode(_reviewQueueSeals.map((post) => post.toJson()).toList()),
    );
    _refreshCurrentUserCounts();
    notifyListeners();
  }

  Future<void> reportPost(
    MemorySeal post, {
    MorrowlyReportReason reason = MorrowlyReportReason.inappropriate,
  }) async {
    await load();
    await _moderation.reportContent(
      target: moderationTargetForPost(post),
      reason: reason,
    );
  }

  Future<void> reportComment(
    MemoryReplyNote comment, {
    MorrowlyReportReason reason = MorrowlyReportReason.inappropriate,
  }) async {
    await load();
    await _moderation.reportContent(
      target: moderationTargetForComment(comment),
      reason: reason,
    );
  }

  Future<void> reportUser(
    String keeperId, {
    MorrowlyReportReason reason = MorrowlyReportReason.inappropriate,
  }) async {
    await load();
    await _moderation.reportContent(
      target: moderationTargetForUser(keeperId),
      reason: reason,
    );
  }

  Future<void> blockUser(String keeperId) async {
    await load();
    await _moderation.blockKeeper(moderationTargetForUser(keeperId));
    _outgoingKeeperRequests.remove(keeperId);
    _followedKeeperIds.remove(keeperId);
    _followerKeeperIds.remove(keeperId);
    await _saveStringSet(_outgoingKeeperRequestsKey, _outgoingKeeperRequests);
    await _saveStringSet(_followedKeepersKey, _followedKeeperIds);
    await _saveStringSet(_followerKeepersKey, _followerKeeperIds);
    _refreshCurrentUserCounts();
    notifyListeners();
  }

  Future<void> unblockUser(String keeperId) async {
    await _moderation.unblockKeeper(keeperId);
    notifyListeners();
  }

  Future<void> updateCurrentUserProfile({
    required String publicName,
    required String morrowLine,
    required String localPortraitPath,
    required String gender,
    required String region,
    required String birthDate,
  }) async {
    MorrowlyContentSafety.ensureProfile(
      keeperName: publicName,
      handle: publicName,
      morrowLine: morrowLine,
    );
    final gateStore = await LocalGateStore.open();
    await gateStore.updateProfile(
      keeperName: publicName,
      morrowLine: morrowLine,
      localPortraitPath: localPortraitPath,
      gender: gender,
      region: region,
      birthDate: birthDate,
    );
    _signedInKeeper = _signedKeeperFromGate(gateStore);
    notifyListeners();
  }

  Future<void> clearLocalAccountData() async {
    await load();
    _glowedSealIds.clear();
    _outgoingKeeperRequests.clear();
    _followedKeeperIds.clear();
    _followerKeeperIds.clear();
    _replyNotesBySeal.clear();
    _chatThreads.clear();
    _reviewQueueSeals.clear();
    _hiddenSealIds.clear();
    await _preferences!.remove(_reviewQueueSealsKey);
    await _preferences!.remove(_replyNotesKey);
    await _preferences!.remove(_glowedSealsKey);
    await _preferences!.remove(_outgoingKeeperRequestsKey);
    await _preferences!.remove(_followedKeepersKey);
    await _preferences!.remove(_followerKeepersKey);
    await _preferences!.remove(_chatThreadsKey);
    await _preferences!.remove(_hiddenSealIdsKey);
    await _preferences!.remove(_autoFollowerSeededKey);
    await _moderation.clearLocalRecords();
    _signedInKeeper = _fallbackSignedInKeeper;
    notifyListeners();
  }

  Future<void> sendMessage({
    required String keeperId,
    required String letterText,
  }) async {
    await load();
    final trimmed = letterText.trim();
    if (trimmed.isEmpty) {
      return;
    }
    MorrowlyContentSafety.ensureText(
      trimmed,
      surface: MorrowlySafetySurface.privateMessage,
    );
    if (!isMutualFollow(keeperId)) {
      throw const MutualKeeperGate();
    }
    if (_moderation.isKeeperBlocked(keeperId)) {
      throw const MutualKeeperGate();
    }

    final thread = _chatThreads.putIfAbsent(keeperId, () => []);
    thread.add(
      KeeperLetter(
        letterId: 'message-${DateTime.now().microsecondsSinceEpoch}',
        senderKeeperId: _signedInKeeper.keeperId,
        letterText: trimmed,
        sentAt: DateTime.now(),
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

    _glowedSealIds
      ..clear()
      ..addAll(_preferences!.getStringList(_glowedSealsKey) ?? const []);
    _outgoingKeeperRequests
      ..clear()
      ..addAll(
        _preferences!.getStringList(_outgoingKeeperRequestsKey) ?? const [],
      );
    _followedKeeperIds
      ..clear()
      ..addAll(_preferences!.getStringList(_followedKeepersKey) ?? const []);
    _followerKeeperIds
      ..clear()
      ..addAll(_preferences!.getStringList(_followerKeepersKey) ?? const []);
    _hiddenSealIds
      ..clear()
      ..addAll(_preferences!.getStringList(_hiddenSealIdsKey) ?? const []);

    await _seedIncomingFollowersIfNeeded();
    _loadPendingPosts();
    _loadComments();
    _loadChatThreads();

    final gateStore = await LocalGateStore.open();
    _signedInKeeper = _signedKeeperFromGate(gateStore);
    notifyListeners();
  }

  Future<void> _seedIncomingFollowersIfNeeded() async {
    if (_preferences!.getBool(_autoFollowerSeededKey) == true) {
      return;
    }

    final random = Random();
    final candidates =
        _seedUsers
            .where((user) => !_moderation.isKeeperBlocked(user.keeperId))
            .map((user) => user.keeperId)
            .toList()
          ..shuffle(random);
    final count = min(candidates.length, 2 + random.nextInt(2));
    _followerKeeperIds.addAll(candidates.take(count));
    await _saveStringSet(_followerKeepersKey, _followerKeeperIds);
    await _preferences!.setBool(_autoFollowerSeededKey, true);
  }

  void _refreshCurrentUserCounts() {
    _signedInKeeper = KeeperProfile(
      keeperId: _signedInKeeper.keeperId,
      publicName: _signedInKeeper.publicName,
      ageMark: _signedInKeeper.ageMark,
      homeRegion: _signedInKeeper.homeRegion,
      portraitAsset: _signedInKeeper.portraitAsset,
      localPortraitPath: _signedInKeeper.localPortraitPath,
      morrowLine: _signedInKeeper.morrowLine,
      belongsToSignedInKeeper: true,
      followingCount: _followedKeeperIds.length,
      followerCount: _followerKeeperIds.length,
      glowCount: _signedInKeeper.glowCount,
      keptCapsuleCount: _reviewQueueSeals.length,
    );
  }

  KeeperProfile _signedKeeperFromGate(LocalGateStore gateStore) {
    return KeeperProfile(
      keeperId: signedInKeeperId,
      publicName: gateStore.savedKeeperName.isEmpty
          ? 'New Timekeeper'
          : gateStore.savedKeeperName,
      ageMark: '23',
      homeRegion: gateStore.savedRegion,
      portraitAsset: _signedInKeeperPlaceholderAvatar,
      localPortraitPath: gateStore.savedAvatarPath,
      morrowLine: gateStore.savedSignatureLine.isEmpty
          ? 'Leave tomorrow something kind to find'
          : gateStore.savedSignatureLine,
      belongsToSignedInKeeper: true,
      followingCount: _followedKeeperIds.length,
      followerCount: _followerKeeperIds.length,
      glowCount: 0,
      keptCapsuleCount: _reviewQueueSeals.length,
    );
  }

  void _loadPendingPosts() {
    _reviewQueueSeals
      ..clear()
      ..addAll(
        decodeJsonObjectList(
          _preferences!.getString(_reviewQueueSealsKey) ?? '[]',
        ).map(MemorySeal.fromJson),
      );
  }

  void _loadComments() {
    _replyNotesBySeal.clear();
    final decoded = jsonDecode(_preferences!.getString(_replyNotesKey) ?? '{}');
    if (decoded is! Map) {
      return;
    }
    for (final entry in decoded.entries) {
      final sealId = '${entry.key}';
      final value = entry.value;
      if (value is! List) {
        continue;
      }
      _replyNotesBySeal[sealId] = value
          .map(castJsonObject)
          .map(MemoryReplyNote.fromJson)
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
      final keeperId = '${entry.key}';
      final value = entry.value;
      if (value is! List) {
        continue;
      }
      _chatThreads[keeperId] = value
          .map(castJsonObject)
          .map(KeeperLetter.fromJson)
          .toList();
    }
  }

  Future<void> _saveComments() async {
    final encoded = <String, Object?>{
      for (final entry in _replyNotesBySeal.entries)
        entry.key: entry.value.map((comment) => comment.toJson()).toList(),
    };
    await _preferences!.setString(_replyNotesKey, jsonEncode(encoded));
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

String _profileContentKey(String keeperId) => 'profile-$keeperId';

const _fallbackSignedInKeeper = KeeperProfile(
  keeperId: KeeperMemoryStore.signedInKeeperId,
  publicName: 'New Timekeeper',
  ageMark: '23',
  homeRegion: 'United States',
  portraitAsset: _signedInKeeperPlaceholderAvatar,
  morrowLine: 'Leave tomorrow something kind to find',
  belongsToSignedInKeeper: true,
);

const _seedUsers = [
  KeeperProfile(
    keeperId: 'carolyn-massey',
    publicName: 'Carolyn Massey',
    ageMark: '23',
    homeRegion: 'Australia',
    portraitAsset:
        'assets/morrowly_art/keepers/morrowly_keeper_bloom_arch_window.jpg',
    morrowLine: 'Leave tomorrow something kind to find',
    followingCount: 8,
    followerCount: 3,
    glowCount: 24,
    keptCapsuleCount: 2,
  ),
  KeeperProfile(
    keeperId: 'evan-perkins',
    publicName: 'Evan Perkins',
    ageMark: '25',
    homeRegion: 'Canada',
    portraitAsset:
        'assets/morrowly_art/keepers/morrowly_keeper_muse_cafe_shadow.jpg',
    morrowLine: 'Save small weather from ordinary days',
    followingCount: 6,
    followerCount: 2,
    glowCount: 18,
    keptCapsuleCount: 2,
  ),
  KeeperProfile(
    keeperId: 'talia-arden',
    publicName: 'Talia Arden',
    ageMark: '21',
    homeRegion: 'Switzerland',
    portraitAsset:
        'assets/morrowly_art/keepers/morrowly_keeper_bloom_lake_glow.jpg',
    morrowLine: 'Let a softer future find the proof',
    followingCount: 10,
    followerCount: 4,
    glowCount: 31,
    keptCapsuleCount: 1,
  ),
];

final _seedPosts = [
  MemorySeal(
    sealId: 'memory-seal-lake-cocktail',
    authorKeeperId: 'carolyn-massey',
    noteLine:
        'Sealing this lake light for a later morning, when I need proof that quiet days can still glow.',
    attachments: const [
      MemoryAttachment(
        attachmentId: 'sunrise-lake-a',
        sourcePath:
            'assets/morrowly_art/moments/morrowly_moment_lake_cocktail_view.jpg',
        sourceKind: MemoryAttachmentSource.bundledMoment,
      ),
    ],
    sealedAt: DateTime(2025, 11, 25, 8, 45),
    glowCount: 14,
    replyCount: 2,
    seedReplyNotes: [
      MemoryReplyNote(
        replyId: 'comment-evan-coffee',
        authorKeeperId: 'evan-perkins',
        noteLine:
            'This feels like the kind of small hour future you will be glad you kept.',
        pennedAt: DateTime(2025, 11, 25, 8, 45),
      ),
      MemoryReplyNote(
        replyId: 'comment-talia-soft',
        authorKeeperId: 'talia-arden',
        noteLine: 'The sunset already feels like a note addressed to tomorrow.',
        pennedAt: DateTime(2025, 11, 25, 9, 10),
      ),
    ],
  ),
  MemorySeal(
    sealId: 'memory-seal-harbor-supper',
    authorKeeperId: 'evan-perkins',
    noteLine:
        'A sunset table, a few cards, and the kind of evening I want to remember slowly.',
    attachments: const [
      MemoryAttachment(
        attachmentId: 'harbor-supper-a',
        sourcePath:
            'assets/morrowly_art/moments/morrowly_moment_harbor_supper_sunset.jpg',
        sourceKind: MemoryAttachmentSource.bundledMoment,
      ),
    ],
    sealedAt: DateTime(2025, 11, 24, 19, 18),
    glowCount: 12,
    replyCount: 0,
  ),
  MemorySeal(
    sealId: 'memory-seal-window-note',
    authorKeeperId: 'talia-arden',
    noteLine:
        'Leaving a tiny note for the year I finally stop rushing through beautiful things.',
    attachments: const [
      MemoryAttachment(
        attachmentId: 'window-note-a',
        sourcePath:
            'assets/morrowly_art/moments/morrowly_moment_dusk_window_note.jpg',
        sourceKind: MemoryAttachmentSource.bundledMoment,
      ),
    ],
    sealedAt: DateTime(2025, 11, 21, 18, 30),
    glowCount: 9,
    replyCount: 1,
    seedReplyNotes: [
      MemoryReplyNote(
        replyId: 'comment-carolyn-window',
        authorKeeperId: 'carolyn-massey',
        noteLine: 'The quiet in this feels carefully kept.',
        pennedAt: DateTime(2025, 11, 21, 19, 5),
      ),
    ],
  ),
  MemorySeal(
    sealId: 'memory-seal-coffee-letter',
    authorKeeperId: 'carolyn-massey',
    noteLine:
        'Coffee cooled beside the letter before I found the words I wanted to keep.',
    attachments: const [
      MemoryAttachment(
        attachmentId: 'coffee-letter-a',
        sourcePath:
            'assets/morrowly_art/moments/morrowly_moment_coffee_letter_table.jpg',
        sourceKind: MemoryAttachmentSource.bundledMoment,
      ),
    ],
    sealedAt: DateTime(2025, 11, 20, 10, 12),
    glowCount: 11,
    replyCount: 0,
  ),
  MemorySeal(
    sealId: 'memory-seal-market-light',
    authorKeeperId: 'evan-perkins',
    noteLine:
        'Today looked ordinary until the market light landed on everyone at once.',
    attachments: const [
      MemoryAttachment(
        attachmentId: 'market-light-a',
        sourcePath:
            'assets/morrowly_art/moments/morrowly_moment_flower_market_smile.jpg',
        sourceKind: MemoryAttachmentSource.bundledMoment,
      ),
    ],
    sealedAt: DateTime(2025, 11, 18, 16, 12),
    glowCount: 7,
    replyCount: 0,
  ),
  MemorySeal(
    sealId: 'memory-seal-green-path',
    authorKeeperId: 'talia-arden',
    noteLine:
        'The path bent out of sight, so I saved the turn for a braver version of me.',
    attachments: const [
      MemoryAttachment(
        attachmentId: 'green-path-a',
        sourcePath:
            'assets/morrowly_art/moments/morrowly_moment_green_path_turn.jpg',
        sourceKind: MemoryAttachmentSource.bundledMoment,
      ),
    ],
    sealedAt: DateTime(2025, 11, 17, 15, 4),
    glowCount: 8,
    replyCount: 0,
  ),
  MemorySeal(
    sealId: 'memory-seal-amber-room',
    authorKeeperId: 'carolyn-massey',
    noteLine: 'This quiet amber corner made the whole day feel less temporary.',
    attachments: const [
      MemoryAttachment(
        attachmentId: 'amber-room-a',
        sourcePath:
            'assets/morrowly_art/moments/morrowly_moment_amber_room_table.jpg',
        sourceKind: MemoryAttachmentSource.bundledMoment,
      ),
    ],
    sealedAt: DateTime(2025, 11, 16, 20, 22),
    glowCount: 10,
    replyCount: 0,
  ),
  MemorySeal(
    sealId: 'memory-seal-beach-mat',
    authorKeeperId: 'evan-perkins',
    noteLine:
        'A beach mat, a warm pause, and one small proof that rest can be planned.',
    attachments: const [
      MemoryAttachment(
        attachmentId: 'beach-mat-a',
        sourcePath:
            'assets/morrowly_art/moments/morrowly_moment_beach_mat_memory.jpg',
        sourceKind: MemoryAttachmentSource.bundledMoment,
      ),
    ],
    sealedAt: DateTime(2025, 11, 15, 14, 9),
    glowCount: 6,
    replyCount: 0,
  ),
  MemorySeal(
    sealId: 'memory-seal-cafe-companion',
    authorKeeperId: 'talia-arden',
    noteLine: 'Some tables remember conversations better than we do.',
    attachments: const [
      MemoryAttachment(
        attachmentId: 'cafe-companion-a',
        sourcePath:
            'assets/morrowly_art/moments/morrowly_moment_cafe_companion_table.jpg',
        sourceKind: MemoryAttachmentSource.bundledMoment,
      ),
    ],
    sealedAt: DateTime(2025, 11, 14, 11, 42),
    glowCount: 13,
    replyCount: 0,
  ),
  MemorySeal(
    sealId: 'memory-seal-car-window',
    authorKeeperId: 'carolyn-massey',
    noteLine:
        'The road kept moving, but the light stayed with me for a few miles.',
    attachments: const [
      MemoryAttachment(
        attachmentId: 'car-window-a',
        sourcePath:
            'assets/morrowly_art/moments/morrowly_moment_car_window_drive.jpg',
        sourceKind: MemoryAttachmentSource.bundledMoment,
      ),
    ],
    sealedAt: DateTime(2025, 11, 13, 17, 28),
    glowCount: 5,
    replyCount: 0,
  ),
  MemorySeal(
    sealId: 'memory-seal-cathedral-morning',
    authorKeeperId: 'evan-perkins',
    noteLine:
        'Morning made the stone look gentle, so I stood there longer than planned.',
    attachments: const [
      MemoryAttachment(
        attachmentId: 'cathedral-morning-a',
        sourcePath:
            'assets/morrowly_art/moments/morrowly_moment_cathedral_morning.jpg',
        sourceKind: MemoryAttachmentSource.bundledMoment,
      ),
    ],
    sealedAt: DateTime(2025, 11, 12, 9, 36),
    glowCount: 9,
    replyCount: 0,
  ),
  MemorySeal(
    sealId: 'memory-seal-garden-portrait',
    authorKeeperId: 'talia-arden',
    noteLine:
        'A garden portrait for the version of me that keeps choosing softness.',
    attachments: const [
      MemoryAttachment(
        attachmentId: 'garden-portrait-a',
        sourcePath:
            'assets/morrowly_art/moments/morrowly_moment_garden_portrait.jpg',
        sourceKind: MemoryAttachmentSource.bundledMoment,
      ),
    ],
    sealedAt: DateTime(2025, 11, 11, 13, 18),
    glowCount: 16,
    replyCount: 0,
  ),
  MemorySeal(
    sealId: 'memory-seal-hammock-valley',
    authorKeeperId: 'carolyn-massey',
    noteLine: 'If future me forgets how to slow down, start with this valley.',
    attachments: const [
      MemoryAttachment(
        attachmentId: 'hammock-valley-a',
        sourcePath:
            'assets/morrowly_art/moments/morrowly_moment_hammock_valley_rest.jpg',
        sourceKind: MemoryAttachmentSource.bundledMoment,
      ),
    ],
    sealedAt: DateTime(2025, 11, 10, 16, 44),
    glowCount: 7,
    replyCount: 0,
  ),
  MemorySeal(
    sealId: 'memory-seal-handheld-game',
    authorKeeperId: 'evan-perkins',
    noteLine:
        'Tiny games are better when the afternoon has nowhere urgent to go.',
    attachments: const [
      MemoryAttachment(
        attachmentId: 'handheld-game-a',
        sourcePath:
            'assets/morrowly_art/moments/morrowly_moment_handheld_game_rest.jpg',
        sourceKind: MemoryAttachmentSource.bundledMoment,
      ),
    ],
    sealedAt: DateTime(2025, 11, 9, 15, 20),
    glowCount: 4,
    replyCount: 0,
  ),
  MemorySeal(
    sealId: 'memory-seal-lemonade-arcade',
    authorKeeperId: 'talia-arden',
    noteLine: 'A bright drink and an old machine made the day feel fictional.',
    attachments: const [
      MemoryAttachment(
        attachmentId: 'lemonade-arcade-a',
        sourcePath:
            'assets/morrowly_art/moments/morrowly_moment_lemonade_arcade.jpg',
        sourceKind: MemoryAttachmentSource.bundledMoment,
      ),
    ],
    sealedAt: DateTime(2025, 11, 8, 12, 16),
    glowCount: 8,
    replyCount: 0,
  ),
  MemorySeal(
    sealId: 'memory-seal-palm-street',
    authorKeeperId: 'carolyn-massey',
    noteLine: 'The palm street looked like it had already forgiven the week.',
    attachments: const [
      MemoryAttachment(
        attachmentId: 'palm-street-a',
        sourcePath:
            'assets/morrowly_art/moments/morrowly_moment_palm_street_walk.jpg',
        sourceKind: MemoryAttachmentSource.bundledMoment,
      ),
    ],
    sealedAt: DateTime(2025, 11, 7, 18, 2),
    glowCount: 11,
    replyCount: 0,
  ),
  MemorySeal(
    sealId: 'memory-seal-paper-wall',
    authorKeeperId: 'evan-perkins',
    noteLine:
        'Paused by the paper wall and let the silence finish the sentence.',
    attachments: const [
      MemoryAttachment(
        attachmentId: 'paper-wall-a',
        sourcePath:
            'assets/morrowly_art/moments/morrowly_moment_paper_wall_pause.jpg',
        sourceKind: MemoryAttachmentSource.bundledMoment,
      ),
    ],
    sealedAt: DateTime(2025, 11, 6, 10, 50),
    glowCount: 6,
    replyCount: 0,
  ),
  MemorySeal(
    sealId: 'memory-seal-poolside-wings',
    authorKeeperId: 'talia-arden',
    noteLine: 'A poolside picture for the days that need proof of sunlight.',
    attachments: const [
      MemoryAttachment(
        attachmentId: 'poolside-wings-a',
        sourcePath:
            'assets/morrowly_art/moments/morrowly_moment_poolside_wings.jpg',
        sourceKind: MemoryAttachmentSource.bundledMoment,
      ),
    ],
    sealedAt: DateTime(2025, 11, 5, 14, 37),
    glowCount: 15,
    replyCount: 0,
  ),
  MemorySeal(
    sealId: 'memory-seal-quiet-stair',
    authorKeeperId: 'carolyn-massey',
    noteLine:
        'Waiting on the quiet stair felt less lonely than rushing past it.',
    attachments: const [
      MemoryAttachment(
        attachmentId: 'quiet-stair-a',
        sourcePath:
            'assets/morrowly_art/moments/morrowly_moment_quiet_stair_wait.jpg',
        sourceKind: MemoryAttachmentSource.bundledMoment,
      ),
    ],
    sealedAt: DateTime(2025, 11, 4, 9, 24),
    glowCount: 5,
    replyCount: 0,
  ),
  MemorySeal(
    sealId: 'memory-seal-resort-pool',
    authorKeeperId: 'evan-perkins',
    noteLine: 'The pool was still enough to make every plan feel optional.',
    attachments: const [
      MemoryAttachment(
        attachmentId: 'resort-pool-a',
        sourcePath:
            'assets/morrowly_art/moments/morrowly_moment_resort_pool_still.jpg',
        sourceKind: MemoryAttachmentSource.bundledMoment,
      ),
    ],
    sealedAt: DateTime(2025, 11, 3, 16, 8),
    glowCount: 8,
    replyCount: 0,
  ),
  MemorySeal(
    sealId: 'memory-seal-travel-mirror',
    authorKeeperId: 'talia-arden',
    noteLine: 'Travel mirror, narrow lane, and one small version of becoming.',
    attachments: const [
      MemoryAttachment(
        attachmentId: 'travel-mirror-a',
        sourcePath:
            'assets/morrowly_art/moments/morrowly_moment_travel_mirror_lane.jpg',
        sourceKind: MemoryAttachmentSource.bundledMoment,
      ),
    ],
    sealedAt: DateTime(2025, 11, 2, 18, 55),
    glowCount: 10,
    replyCount: 0,
  ),
];

final _emptyPost = MemorySeal(
  sealId: '',
  authorKeeperId: '',
  noteLine: '',
  attachments: const [],
  sealedAt: DateTime(2000),
  glowCount: 0,
  replyCount: 0,
);
