import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MorrowlyModerationKind { capsule, snippet, comment, profile, message, chat }

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
    required this.authorKey,
    required this.authorName,
    required this.kind,
  });

  final String contentKey;
  final String authorKey;
  final String authorName;
  final MorrowlyModerationKind kind;

  String get contentLabel {
    return switch (kind) {
      MorrowlyModerationKind.capsule => 'capsule',
      MorrowlyModerationKind.snippet => 'snippet',
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
  static const _blockedAuthorKeysKey = 'morrowly.moderation.blockedAuthorKeys';
  static const _reportRecordsKey = 'morrowly.moderation.reportRecords';

  SharedPreferences? _preferences;
  Future<void>? _loading;
  final Set<String> _reportedContentKeys = {};
  final Set<String> _blockedAuthorKeys = {};

  bool get isLoaded => _preferences != null;
  Set<String> get reportedContentKeys => Set.unmodifiable(_reportedContentKeys);
  Set<String> get blockedAuthorKeys => Set.unmodifiable(_blockedAuthorKeys);

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

  bool isAuthorBlocked(String authorKey) {
    return _blockedAuthorKeys.contains(authorKey);
  }

  bool shouldHide({required String contentKey, required String authorKey}) {
    return isContentReported(contentKey) || isAuthorBlocked(authorKey);
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

  Future<void> blockAuthor(MorrowlyModerationTarget target) async {
    await load();

    _blockedAuthorKeys.add(target.authorKey);
    await _preferences!.setStringList(
      _blockedAuthorKeysKey,
      _blockedAuthorKeys.toList()..sort(),
    );
    notifyListeners();
  }

  Future<void> unblockAuthor(String authorKey) async {
    await load();

    _blockedAuthorKeys.remove(authorKey);
    await _preferences!.setStringList(
      _blockedAuthorKeysKey,
      _blockedAuthorKeys.toList()..sort(),
    );
    notifyListeners();
  }

  Future<void> clearLocalRecords() async {
    await load();

    _reportedContentKeys.clear();
    _blockedAuthorKeys.clear();
    await _preferences!.remove(_reportedContentKeysKey);
    await _preferences!.remove(_blockedAuthorKeysKey);
    await _preferences!.remove(_reportRecordsKey);
    notifyListeners();
  }

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    _preferences = preferences;
    _reportedContentKeys
      ..clear()
      ..addAll(preferences.getStringList(_reportedContentKeysKey) ?? const []);
    _blockedAuthorKeys
      ..clear()
      ..addAll(preferences.getStringList(_blockedAuthorKeysKey) ?? const []);
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
        'authorKey': target.authorKey,
        'authorName': target.authorName,
        'kind': target.kind.name,
        'reason': reason.name,
        'createdAt': DateTime.now().toIso8601String(),
      }),
    );
    await _preferences!.setStringList(_reportRecordsKey, records);
  }
}
