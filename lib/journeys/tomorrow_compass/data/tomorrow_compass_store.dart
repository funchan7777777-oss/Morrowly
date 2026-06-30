import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TomorrowCompassDraft {
  const TomorrowCompassDraft({
    required this.anchorLine,
    required this.firstStep,
    required this.quietBoundary,
    required this.recoveryPlan,
    required this.eveningQuestion,
    required this.focusMinutes,
  });

  static const empty = TomorrowCompassDraft(
    anchorLine: '',
    firstStep: '',
    quietBoundary: '',
    recoveryPlan: '',
    eveningQuestion: '',
    focusMinutes: 25,
  );

  final String anchorLine;
  final String firstStep;
  final String quietBoundary;
  final String recoveryPlan;
  final String eveningQuestion;
  final int focusMinutes;

  bool get hasMeaningfulPlan {
    return anchorLine.trim().isNotEmpty && firstStep.trim().isNotEmpty;
  }

  TomorrowCompassDraft copyWith({
    String? anchorLine,
    String? firstStep,
    String? quietBoundary,
    String? recoveryPlan,
    String? eveningQuestion,
    int? focusMinutes,
  }) {
    return TomorrowCompassDraft(
      anchorLine: anchorLine ?? this.anchorLine,
      firstStep: firstStep ?? this.firstStep,
      quietBoundary: quietBoundary ?? this.quietBoundary,
      recoveryPlan: recoveryPlan ?? this.recoveryPlan,
      eveningQuestion: eveningQuestion ?? this.eveningQuestion,
      focusMinutes: focusMinutes ?? this.focusMinutes,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'anchorLine': anchorLine,
      'firstStep': firstStep,
      'quietBoundary': quietBoundary,
      'recoveryPlan': recoveryPlan,
      'eveningQuestion': eveningQuestion,
      'focusMinutes': focusMinutes,
    };
  }

  static TomorrowCompassDraft fromJson(Map<String, Object?> json) {
    final focusMinutes = json['focusMinutes'];
    return TomorrowCompassDraft(
      anchorLine: '${json['anchorLine'] ?? ''}',
      firstStep: '${json['firstStep'] ?? ''}',
      quietBoundary: '${json['quietBoundary'] ?? ''}',
      recoveryPlan: '${json['recoveryPlan'] ?? ''}',
      eveningQuestion: '${json['eveningQuestion'] ?? ''}',
      focusMinutes: focusMinutes is int
          ? focusMinutes.clamp(10, 90).toInt()
          : TomorrowCompassDraft.empty.focusMinutes,
    );
  }
}

class TomorrowCompassSeal {
  const TomorrowCompassSeal({required this.draft, required this.sealedAt});

  final TomorrowCompassDraft draft;
  final DateTime sealedAt;

  Map<String, Object?> toJson() {
    return {'draft': draft.toJson(), 'sealedAt': sealedAt.toIso8601String()};
  }

  static TomorrowCompassSeal? fromJson(Map<String, Object?> json) {
    final draftJson = json['draft'];
    final sealedAt = DateTime.tryParse('${json['sealedAt'] ?? ''}');
    if (draftJson is! Map || sealedAt == null) {
      return null;
    }

    return TomorrowCompassSeal(
      draft: TomorrowCompassDraft.fromJson(
        Map<String, Object?>.from(draftJson),
      ),
      sealedAt: sealedAt,
    );
  }
}

class TomorrowCompassStore extends ChangeNotifier {
  TomorrowCompassStore._();

  static final TomorrowCompassStore instance = TomorrowCompassStore._();

  static const _draftKey = 'morrowly.tomorrowCompass.draft';
  static const _sealsKey = 'morrowly.tomorrowCompass.seals';

  SharedPreferences? _preferences;
  Future<void>? _loading;
  TomorrowCompassDraft _draft = TomorrowCompassDraft.empty;
  final List<TomorrowCompassSeal> _seals = [];

  TomorrowCompassDraft get draft => _draft;
  List<TomorrowCompassSeal> get seals => List.unmodifiable(_seals);
  TomorrowCompassSeal? get latestSeal => _seals.isEmpty ? null : _seals.first;

  Future<void> load() {
    final activeLoad = _loading;
    if (activeLoad != null) {
      return activeLoad;
    }

    final load = _load();
    _loading = load;
    return load;
  }

  Future<void> saveDraft(TomorrowCompassDraft draft) async {
    await load();
    _draft = draft;
    await _preferences!.setString(_draftKey, jsonEncode(draft.toJson()));
    notifyListeners();
  }

  Future<void> sealCurrentDraft() async {
    await load();
    if (!_draft.hasMeaningfulPlan) {
      return;
    }

    _seals.insert(
      0,
      TomorrowCompassSeal(draft: _draft, sealedAt: DateTime.now()),
    );
    if (_seals.length > 5) {
      _seals.removeRange(5, _seals.length);
    }
    await _preferences!.setString(
      _sealsKey,
      jsonEncode(_seals.map((seal) => seal.toJson()).toList()),
    );
    notifyListeners();
  }

  Future<void> resetDraft() async {
    await load();
    _draft = TomorrowCompassDraft.empty;
    await _preferences!.remove(_draftKey);
    notifyListeners();
  }

  Future<void> clear() async {
    await load();
    _draft = TomorrowCompassDraft.empty;
    _seals.clear();
    await _preferences!.remove(_draftKey);
    await _preferences!.remove(_sealsKey);
    notifyListeners();
  }

  Future<void> _load() async {
    _preferences = await SharedPreferences.getInstance();
    _draft = _decodeDraft(_preferences!.getString(_draftKey));
    _seals
      ..clear()
      ..addAll(_decodeSeals(_preferences!.getString(_sealsKey)));
    notifyListeners();
  }

  TomorrowCompassDraft _decodeDraft(String? raw) {
    if (raw == null || raw.isEmpty) {
      return TomorrowCompassDraft.empty;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return TomorrowCompassDraft.fromJson(
          Map<String, Object?>.from(decoded),
        );
      }
    } catch (_) {
      return TomorrowCompassDraft.empty;
    }
    return TomorrowCompassDraft.empty;
  }

  List<TomorrowCompassSeal> _decodeSeals(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map(
              (item) =>
                  TomorrowCompassSeal.fromJson(Map<String, Object?>.from(item)),
            )
            .whereType<TomorrowCompassSeal>()
            .toList();
      }
    } catch (_) {
      return const [];
    }
    return const [];
  }
}
