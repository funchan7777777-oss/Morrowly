import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:morrowly/journeys/time_capsule/data/capsule_square_seed.dart';
import 'package:morrowly/journeys/time_capsule/models/capsule_chronicle.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalCapsuleStore extends ChangeNotifier {
  LocalCapsuleStore._();

  static final LocalCapsuleStore instance = LocalCapsuleStore._();

  static const _capsulesKey = 'morrowly.timeCapsules.localCapsules';

  final List<CapsuleSquareNote> _capsules = [];
  SharedPreferences? _preferences;
  Future<void>? _loading;

  List<CapsuleSquareNote> get capsules => List.unmodifiable(_capsules);
  List<CapsuleSquareNote> get publicCapsules => _capsules
      .where((capsule) => capsule.visibility == CapsuleVisibility.publicSquare)
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

  Future<void> add(CapsuleSquareNote capsule) async {
    await load();
    _capsules.removeWhere((item) => item.noteKey == capsule.noteKey);
    _capsules.insert(0, capsule);
    await _save();
    notifyListeners();
  }

  Future<void> replace(CapsuleSquareNote capsule) async {
    await load();
    for (var index = 0; index < _capsules.length; index++) {
      if (_capsules[index].noteKey == capsule.noteKey) {
        _capsules[index] = capsule;
        await _save();
        notifyListeners();
        return;
      }
    }
  }

  Future<void> remove(String noteKey) async {
    await load();
    _capsules.removeWhere((item) => item.noteKey == noteKey);
    await _save();
    notifyListeners();
  }

  Future<void> replaceAll(List<CapsuleSquareNote> capsules) async {
    await load();
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

  List<CapsuleSquareNote> _decodeCapsules(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }

    final capsules = <CapsuleSquareNote>[];
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

  Map<String, Object?> _capsuleToJson(CapsuleSquareNote capsule) {
    return {
      'noteKey': capsule.noteKey,
      'messageLine': capsule.messageLine,
      'mediaSnaps': capsule.mediaSnaps.map(_mediaToJson).toList(),
      'sealedAt': capsule.sealedAt.toIso8601String(),
      'openingAt': capsule.openingAt.toIso8601String(),
      'visibility': capsule.visibility.name,
      'leftMessageCount': capsule.leftMessageCount,
      'isLocalDraft': capsule.isLocalDraft,
    };
  }

  CapsuleSquareNote? _capsuleFromJson(Map<String, Object?> json) {
    final noteKey = json['noteKey'];
    final messageLine = json['messageLine'];
    final sealedAt = DateTime.tryParse('${json['sealedAt'] ?? ''}');
    final openingAt = DateTime.tryParse('${json['openingAt'] ?? ''}');
    if (noteKey is! String ||
        messageLine is! String ||
        sealedAt == null ||
        openingAt == null) {
      return null;
    }

    final mediaList = json['mediaSnaps'];
    final visibilityName = '${json['visibility'] ?? ''}';
    final visibility = CapsuleVisibility.values.firstWhere(
      (value) => value.name == visibilityName,
      orElse: () => CapsuleVisibility.publicSquare,
    );

    final leftMessageCount = json['leftMessageCount'];
    return CapsuleSquareNote(
      noteKey: noteKey,
      keeper: CapsuleSquareSeed.currentKeeper,
      messageLine: messageLine,
      mediaSnaps: mediaList is List
          ? mediaList
                .whereType<Map>()
                .map((item) => _mediaFromJson(Map<String, Object?>.from(item)))
                .whereType<CapsuleMediaSnap>()
                .toList()
          : const [],
      sealedAt: sealedAt,
      openingAt: openingAt,
      visibility: visibility,
      visitorTrail: CapsuleSquareSeed.allKeepers,
      leftMessageCount: leftMessageCount is int ? leftMessageCount : 0,
      isLocalDraft: json['isLocalDraft'] == true,
    );
  }

  Map<String, Object?> _mediaToJson(CapsuleMediaSnap media) {
    return {
      'snapKey': media.snapKey,
      'assetPath': media.assetPath,
      'kind': media.kind.name,
      'captionTrace': media.captionTrace,
      'isLocalFile': media.isLocalFile,
    };
  }

  CapsuleMediaSnap? _mediaFromJson(Map<String, Object?> json) {
    final snapKey = json['snapKey'];
    final assetPath = json['assetPath'];
    if (snapKey is! String || assetPath is! String) {
      return null;
    }

    final kindName = '${json['kind'] ?? ''}';
    final kind = CapsuleMediaKind.values.firstWhere(
      (value) => value.name == kindName,
      orElse: () => CapsuleMediaKind.still,
    );
    return CapsuleMediaSnap(
      snapKey: snapKey,
      assetPath: assetPath,
      kind: kind,
      captionTrace: '${json['captionTrace'] ?? ''}',
      isLocalFile: json['isLocalFile'] == true,
    );
  }
}
