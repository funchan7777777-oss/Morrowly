enum MorrowlySafetySurface {
  profile,
  publicMemorySeal,
  publicCapsule,
  comment,
  privateMessage,
}

class MorrowlyContentSafetyException implements Exception {
  const MorrowlyContentSafetyException({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  String toString() => '$title: $message';
}

class MorrowlyContentSafety {
  const MorrowlyContentSafety._();

  static void ensureProfile({
    required String keeperName,
    required String handle,
    required String morrowLine,
  }) {
    ensureText(keeperName, surface: MorrowlySafetySurface.profile);
    ensureText(handle, surface: MorrowlySafetySurface.profile);
    ensureText(morrowLine, surface: MorrowlySafetySurface.profile);
  }

  static void ensureText(
    String value, {
    required MorrowlySafetySurface surface,
  }) {
    final normalized = _normalize(value);
    if (normalized.isEmpty) {
      return;
    }

    final surfaceName = switch (surface) {
      MorrowlySafetySurface.profile => 'profile',
      MorrowlySafetySurface.publicMemorySeal => 'public memory seal',
      MorrowlySafetySurface.publicCapsule => 'capsule',
      MorrowlySafetySurface.comment => 'comment',
      MorrowlySafetySurface.privateMessage => 'message',
    };

    if (_repeatedCharacterPattern.hasMatch(normalized) ||
        _repeatedSymbolPattern.hasMatch(value)) {
      throw MorrowlyContentSafetyException(
        title: 'Soften this $surfaceName',
        message:
            'This looks like spam or repeated noise. Edit it into a clear memory before saving.',
      );
    }

    if (surface != MorrowlySafetySurface.privateMessage &&
        _externalContactPattern.hasMatch(normalized)) {
      throw MorrowlyContentSafetyException(
        title: 'Keep contact inside Morrowly',
        message:
            'Public profiles, capsules, memory seals, and comments cannot include links, emails, phone numbers, or outside handles.',
      );
    }

    for (final pattern in _blockedPatterns) {
      if (pattern.expression.hasMatch(normalized)) {
        throw MorrowlyContentSafetyException(
          title: pattern.title,
          message: pattern.message,
        );
      }
    }
  }

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '')
        .trim();
  }
}

class _SafetyPattern {
  const _SafetyPattern(this.expression, this.title, this.message);

  final RegExp expression;
  final String title;
  final String message;
}

final _repeatedCharacterPattern = RegExp(r'(.)\1{7,}');
final _repeatedSymbolPattern = RegExp(r'[^\w\s]{8,}');
final _externalContactPattern = RegExp(
  r'(https?:\/\/|www\.|@[a-z0-9_]{3,}|[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}|\+?\d[\d\s().-]{7,}\d)',
);

final _blockedPatterns = [
  _SafetyPattern(
    RegExp(r'\b(kys|kill yourself|go die|end yourself)\b'),
    'Keep people safe',
    'Morrowly cannot save text that encourages self-harm or targets another person.',
  ),
  _SafetyPattern(
    RegExp(r'\b(i will hurt|i will find you|hurt you|kill you)\b'),
    'Remove threats',
    'Remove threatening language before saving this memory.',
  ),
  _SafetyPattern(
    RegExp(r'\b(nudes?|porn|onlyfans|hookup|sugar daddy|sugar baby)\b'),
    'Keep it respectful',
    'Sexual solicitation or explicit adult promotion is not allowed in Morrowly content.',
  ),
  _SafetyPattern(
    RegExp(r'\b(child porn|underage sex|minor nude)\b'),
    'Unsafe content blocked',
    'Content involving minors in a sexual context is not allowed.',
  ),
  _SafetyPattern(
    RegExp(r'\b(nazi|terrorist praise|hate group)\b'),
    'Avoid hateful content',
    'Hateful praise, extremist promotion, or abusive group targeting cannot be saved.',
  ),
  _SafetyPattern(
    RegExp(r'\b(gift card code|wire transfer|crypto giveaway|cashapp|venmo)\b'),
    'Possible scam blocked',
    'Financial solicitation, payment handles, and giveaway-style requests are not allowed here.',
  ),
  _SafetyPattern(
    RegExp(r'\b(dox|home address|passport number|social security)\b'),
    'Protect private information',
    'Do not share private identity or location details about yourself or another person.',
  ),
];
