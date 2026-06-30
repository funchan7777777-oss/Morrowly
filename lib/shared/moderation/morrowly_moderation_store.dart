import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MorrowlyModerationKind {
  capsule,
  memorySeal,
  comment,
  profile,
  message,
  chat,
}

enum MorrowlyReportReason { harassment, inappropriate, spam, scam, other }

extension MorrowlyReportReasonCopy on MorrowlyReportReason {
  String get label {
    return switch (this) {
      MorrowlyReportReason.harassment => 'Harassment or bullying',
      MorrowlyReportReason.inappropriate => 'Inappropriate content',
      MorrowlyReportReason.spam => 'Spam or repeated content',
      MorrowlyReportReason.scam => 'Scam or misleading behavior',
      MorrowlyReportReason.other => 'Something else',
    };
  }
}

class MorrowlyModerationTarget {
  const MorrowlyModerationTarget({
    required this.contentKey,
    required this.authorKeeperId,
    required this.authorName,
    required this.sourceKind,
  });

  final String contentKey;
  final String authorKeeperId;
  final String authorName;
  final MorrowlyModerationKind sourceKind;

  String get contentLabel {
    return switch (sourceKind) {
      MorrowlyModerationKind.capsule => 'capsule',
      MorrowlyModerationKind.memorySeal => 'memory seal',
      MorrowlyModerationKind.comment => 'comment',
      MorrowlyModerationKind.profile => 'profile',
      MorrowlyModerationKind.message => 'message',
      MorrowlyModerationKind.chat => 'chat',
    };
  }
}

class MorrowlyModerationStore extends ChangeNotifier {
  MorrowlyModerationStore._();

  static final MorrowlyModerationStore instance = MorrowlyModerationStore._();

  static const _reportedContentKeysKey =
      'morrowly.moderation.reportedContentKeys';
  static const _blockedKeeperIdsKey = 'morrowly.moderation.blockedKeeperIds';
  static const _reportRecordsKey = 'morrowly.moderation.reportRecords';

  SharedPreferences? _preferences;
  Future<void>? _loading;
  final Set<String> _reportedContentKeys = {};
  final Set<String> _blockedKeeperIds = {};

  bool get isLoaded => _preferences != null;
  Set<String> get reportedContentKeys => Set.unmodifiable(_reportedContentKeys);
  Set<String> get blockedKeeperIds => Set.unmodifiable(_blockedKeeperIds);

  Future<void> load() {
    final activeLoad = _loading;
    if (activeLoad != null) {
      return activeLoad;
    }

    final load = _load();
    _loading = load;
    return load;
  }

  bool isContentReported(String contentKey) {
    return _reportedContentKeys.contains(contentKey);
  }

  bool isKeeperBlocked(String authorKeeperId) {
    return _blockedKeeperIds.contains(authorKeeperId);
  }

  bool shouldHide({
    required String contentKey,
    required String authorKeeperId,
  }) {
    return isContentReported(contentKey) || isKeeperBlocked(authorKeeperId);
  }

  Future<void> reportContent({
    required MorrowlyModerationTarget target,
    required MorrowlyReportReason reason,
  }) async {
    await load();

    _reportedContentKeys.add(target.contentKey);
    await _preferences!.setStringList(
      _reportedContentKeysKey,
      _reportedContentKeys.toList()..sort(),
    );
    await _appendReportRecord(target: target, reason: reason);
    notifyListeners();
  }

  Future<void> blockKeeper(MorrowlyModerationTarget target) async {
    await load();

    _blockedKeeperIds.add(target.authorKeeperId);
    await _preferences!.setStringList(
      _blockedKeeperIdsKey,
      _blockedKeeperIds.toList()..sort(),
    );
    notifyListeners();
  }

  Future<void> unblockKeeper(String authorKeeperId) async {
    await load();

    _blockedKeeperIds.remove(authorKeeperId);
    await _preferences!.setStringList(
      _blockedKeeperIdsKey,
      _blockedKeeperIds.toList()..sort(),
    );
    notifyListeners();
  }

  Future<void> clearLocalRecords() async {
    await load();

    _reportedContentKeys.clear();
    _blockedKeeperIds.clear();
    await _preferences!.remove(_reportedContentKeysKey);
    await _preferences!.remove(_blockedKeeperIdsKey);
    await _preferences!.remove(_reportRecordsKey);
    notifyListeners();
  }

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    _preferences = preferences;
    _reportedContentKeys
      ..clear()
      ..addAll(preferences.getStringList(_reportedContentKeysKey) ?? const []);
    _blockedKeeperIds
      ..clear()
      ..addAll(preferences.getStringList(_blockedKeeperIdsKey) ?? const []);
    notifyListeners();
  }

  Future<void> _appendReportRecord({
    required MorrowlyModerationTarget target,
    required MorrowlyReportReason reason,
  }) async {
    final records = _preferences!.getStringList(_reportRecordsKey) ?? [];
    records.add(
      jsonEncode({
        'contentKey': target.contentKey,
        'authorKeeperId': target.authorKeeperId,
        'authorName': target.authorName,
        'sourceKind': target.sourceKind.name,
        'reason': reason.name,
        'recordedAt': DateTime.now().toIso8601String(),
      }),
    );
    await _preferences!.setStringList(_reportRecordsKey, records);
  }
}
