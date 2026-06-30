import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:morrowly/journeys/time_capsule/data/capsule_square_seed.dart';
import 'package:morrowly/journeys/time_capsule/models/capsule_chronicle.dart';
import 'package:morrowly/shared/moderation/morrowly_content_safety.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalCapsuleStore extends ChangeNotifier {
  LocalCapsuleStore._();

  static final LocalCapsuleStore instance = LocalCapsuleStore._();

  static const _capsulesKey = 'morrowly.timeCapsules.localCapsules';

  final List<PublicCapsuleSeal> _capsules = [];
  SharedPreferences? _preferences;
  Future<void>? _loading;

  List<PublicCapsuleSeal> get capsules => List.unmodifiable(_capsules);
  List<PublicCapsuleSeal> get publicCapsules => _capsules
      .where(
        (capsule) =>
            capsule.shelfScope == CapsuleShelfScope.publicSquare &&
            !capsule.isLocalDraft,
      )
      .toList();

  int get archivedCount => _capsules.length;
  int get toBeOpenedCount {
    return _capsules.where((capsule) => !capsule.canOpenNow).length;
  }

  int get unlockedCount {
    return _capsules.where((capsule) => capsule.canOpenNow).length;
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

  Future<void> add(PublicCapsuleSeal capsule) async {
    await load();
    _ensureCapsuleIsSafe(capsule);
    _capsules.removeWhere((item) => item.sealId == capsule.sealId);
    _capsules.insert(0, capsule);
    await _save();
    notifyListeners();
  }

  Future<void> replace(PublicCapsuleSeal capsule) async {
    await load();
    _ensureCapsuleIsSafe(capsule);
    for (var index = 0; index < _capsules.length; index++) {
      if (_capsules[index].sealId == capsule.sealId) {
        _capsules[index] = capsule;
        await _save();
        notifyListeners();
        return;
      }
    }
  }

  Future<void> remove(String sealId) async {
    await load();
    _capsules.removeWhere((item) => item.sealId == sealId);
    await _save();
    notifyListeners();
  }

  Future<void> replaceAll(List<PublicCapsuleSeal> capsules) async {
    await load();
    for (final capsule in capsules) {
      _ensureCapsuleIsSafe(capsule);
    }
    _capsules
      ..clear()
      ..addAll(capsules);
    await _save();
    notifyListeners();
  }

  Future<void> clear() async {
    await load();
    _capsules.clear();
    await _preferences!.remove(_capsulesKey);
    notifyListeners();
  }

  Future<void> _load() async {
    _preferences = await SharedPreferences.getInstance();
    _capsules
      ..clear()
      ..addAll(_decodeCapsules(_preferences!.getString(_capsulesKey) ?? '[]'));
    notifyListeners();
  }

  Future<void> _save() async {
    await _preferences!.setString(
      _capsulesKey,
      jsonEncode(_capsules.map(_capsuleToJson).toList()),
    );
  }

  void _ensureCapsuleIsSafe(PublicCapsuleSeal capsule) {
    MorrowlyContentSafety.ensureText(
      capsule.sealedMessage,
      surface: MorrowlySafetySurface.publicCapsule,
    );
    for (final reply in capsule.replies) {
      MorrowlyContentSafety.ensureText(
        reply.sealedMessage,
        surface: MorrowlySafetySurface.comment,
      );
    }
  }

  List<PublicCapsuleSeal> _decodeCapsules(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }

    final capsules = <PublicCapsuleSeal>[];
    for (final item in decoded) {
      if (item is Map) {
        final capsule = _capsuleFromJson(Map<String, Object?>.from(item));
        if (capsule != null) {
          capsules.add(capsule);
        }
      }
    }
    return capsules;
  }

  Map<String, Object?> _capsuleToJson(PublicCapsuleSeal capsule) {
    return {
      'sealId': capsule.sealId,
      'keeperPublicName': capsule.keeper.publicName,
      'keeperAgeLine': capsule.keeper.ageMark,
      'keeperPlaceLine': capsule.keeper.homeRegion,
      'keeperAvatarAsset': capsule.keeper.portraitAsset,
      'keeperAvatarLocalPath': capsule.keeper.localPortraitPath,
      'sealedMessage': capsule.sealedMessage,
      'memoryFragments': capsule.memoryFragments.map(_fragmentToJson).toList(),
      'sealedAt': capsule.sealedAt.toIso8601String(),
      'unlocksAt': capsule.unlocksAt.toIso8601String(),
      'shelfScope': capsule.shelfScope.name,
      'replyTrailCount': capsule.replyTrailCount,
      'replies': capsule.replies.map(_replyToJson).toList(),
      'isLocalDraft': capsule.isLocalDraft,
    };
  }

  PublicCapsuleSeal? _capsuleFromJson(Map<String, Object?> json) {
    final sealId = json['sealId'];
    final sealedMessage = json['sealedMessage'];
    final sealedAt = DateTime.tryParse('${json['sealedAt'] ?? ''}');
    final unlocksAt = DateTime.tryParse('${json['unlocksAt'] ?? ''}');
    if (sealId is! String ||
        sealedMessage is! String ||
        sealedAt == null ||
        unlocksAt == null) {
      return null;
    }

    final fragmentList = json['memoryFragments'];
    final replyList = json['replies'];
    final visibilityName = '${json['shelfScope'] ?? ''}';
    final shelfScope = CapsuleShelfScope.values.firstWhere(
      (value) => value.name == visibilityName,
      orElse: () => CapsuleShelfScope.publicSquare,
    );

    final replyTrailCount = json['replyTrailCount'];
    return PublicCapsuleSeal(
      sealId: sealId,
      keeper: CapsuleKeeper(
        keeperId: CapsuleSquareSeed.currentKeeper.keeperId,
        publicName:
            '${json['keeperPublicName'] ?? CapsuleSquareSeed.currentKeeper.publicName}',
        ageMark:
            '${json['keeperAgeLine'] ?? CapsuleSquareSeed.currentKeeper.ageMark}',
        homeRegion:
            '${json['keeperPlaceLine'] ?? CapsuleSquareSeed.currentKeeper.homeRegion}',
        signalBand: CapsuleSquareSeed.currentKeeper.signalBand,
        portraitAsset:
            '${json['keeperAvatarAsset'] ?? CapsuleSquareSeed.currentKeeper.portraitAsset}',
        localPortraitPath: '${json['keeperAvatarLocalPath'] ?? ''}',
      ),
      sealedMessage: sealedMessage,
      memoryFragments: fragmentList is List
          ? fragmentList
                .whereType<Map>()
                .map(
                  (item) => _fragmentFromJson(Map<String, Object?>.from(item)),
                )
                .whereType<CapsuleMemoryFragment>()
                .toList()
          : const [],
      sealedAt: sealedAt,
      unlocksAt: unlocksAt,
      shelfScope: shelfScope,
      visitorTrail: CapsuleSquareSeed.allKeepers,
      replyTrailCount: replyTrailCount is int ? replyTrailCount : 0,
      replies: replyList is List
          ? replyList
                .whereType<Map>()
                .map((item) => _replyFromJson(Map<String, Object?>.from(item)))
                .whereType<CapsuleReply>()
                .toList()
          : const [],
      isLocalDraft: json['isLocalDraft'] == true,
    );
  }

  Map<String, Object?> _fragmentToJson(CapsuleMemoryFragment fragment) {
    return {
      'fragmentId': fragment.fragmentId,
      'sourcePath': fragment.sourcePath,
      'fragmentKind': fragment.fragmentKind.name,
      'captionTrace': fragment.captionTrace,
      'isLocalFile': fragment.isLocalFile,
    };
  }

  CapsuleMemoryFragment? _fragmentFromJson(Map<String, Object?> json) {
    final fragmentId = json['fragmentId'];
    final sourcePath = json['sourcePath'];
    if (fragmentId is! String || sourcePath is! String) {
      return null;
    }

    final kindName = '${json['fragmentKind'] ?? json['kind'] ?? ''}';
    final kind = MemoryFragmentKind.values.firstWhere(
      (value) => value.name == kindName,
      orElse: () => MemoryFragmentKind.still,
    );
    return CapsuleMemoryFragment(
      fragmentId: fragmentId,
      sourcePath: sourcePath,
      fragmentKind: kind,
      captionTrace: '${json['captionTrace'] ?? ''}',
      isLocalFile: json['isLocalFile'] == true,
    );
  }

  Map<String, Object?> _replyToJson(CapsuleReply reply) {
    return {
      'replyId': reply.replyId,
      'authorKeeperId': reply.author.keeperId,
      'authorName': reply.author.publicName,
      'authorAgeMark': reply.author.ageMark,
      'authorHomeRegion': reply.author.homeRegion,
      'authorSignalBand': reply.author.signalBand.name,
      'authorPortraitAsset': reply.author.portraitAsset,
      'authorLocalPortraitPath': reply.author.localPortraitPath,
      'sealedMessage': reply.sealedMessage,
      'arrivalLabel': reply.arrivalLabel,
    };
  }

  CapsuleReply? _replyFromJson(Map<String, Object?> json) {
    final replyId = json['replyId'];
    final sealedMessage = json['sealedMessage'];
    if (replyId is! String || sealedMessage is! String) {
      return null;
    }
    final signalBandName = '${json['authorSignalBand'] ?? ''}';
    final signalBand = KeeperSignalBand.values.firstWhere(
      (value) => value.name == signalBandName,
      orElse: () => KeeperSignalBand.bloom,
    );
    return CapsuleReply(
      replyId: replyId,
      author: CapsuleKeeper(
        keeperId: '${json['authorKeeperId'] ?? ''}',
        publicName: '${json['authorName'] ?? 'Morrowly keeper'}',
        ageMark: '${json['authorAgeMark'] ?? ''}',
        homeRegion: '${json['authorHomeRegion'] ?? ''}',
        signalBand: signalBand,
        portraitAsset: '${json['authorPortraitAsset'] ?? ''}',
        localPortraitPath: '${json['authorLocalPortraitPath'] ?? ''}',
      ),
      sealedMessage: sealedMessage,
      arrivalLabel: '${json['arrivalLabel'] ?? ''}',
    );
  }
}
