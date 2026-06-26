import 'package:morrowly/journeys/welcome_gate/models/credential_gate_seed.dart';
import 'package:morrowly/journeys/welcome_gate/models/profile_intake_draft.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalGateStore {
  LocalGateStore(this._preferences);

  final SharedPreferences _preferences;

  static const _sessionActiveKey = 'morrowly.session.active';
  static const _registeredEmailKey = 'morrowly.local.email';
  static const _registeredPasswordKey = 'morrowly.local.password';
  static const _profileNameKey = 'morrowly.profile.name';
  static const _profileHandleKey = 'morrowly.profile.handle';
  static const _profileSignatureKey = 'morrowly.profile.signature';
  static const _profileAvatarPathKey = 'morrowly.profile.avatarPath';
  static const _profileGenderKey = 'morrowly.profile.gender';
  static const _profileRegionKey = 'morrowly.profile.region';
  static const _appleUserKey = 'morrowly.apple.userIdentifier';
  static const _lastProviderKey = 'morrowly.session.provider';

  static Future<LocalGateStore> open() async {
    return LocalGateStore(await SharedPreferences.getInstance());
  }

  bool get hasActiveSession {
    return _preferences.getBool(_sessionActiveKey) ?? false;
  }

  bool get hasLocalAccount {
    final email = _preferences.getString(_registeredEmailKey) ?? '';
    final password = _preferences.getString(_registeredPasswordKey) ?? '';
    return email.isNotEmpty && password.isNotEmpty;
  }

  String get savedDisplayName {
    return _preferences.getString(_profileNameKey) ?? '';
  }

  Future<LocalCredentialCheck> verifyLocalCredential({
    required String emailAddress,
    required String passwordText,
  }) async {
    final storedEmail = _preferences.getString(_registeredEmailKey) ?? '';
    final storedPassword = _preferences.getString(_registeredPasswordKey) ?? '';

    if (storedEmail.isEmpty || storedPassword.isEmpty) {
      return LocalCredentialCheck.noLocalAccount;
    }

    final normalizedInput = emailAddress.trim().toLowerCase();
    if (storedEmail.toLowerCase() != normalizedInput ||
        storedPassword != passwordText) {
      return LocalCredentialCheck.mismatch;
    }

    await _preferences.setBool(_sessionActiveKey, true);
    await _preferences.setString(_lastProviderKey, 'local');
    return LocalCredentialCheck.accepted;
  }

  Future<void> completeProfile({
    required PendingCredentialSeed seed,
    required ProfileIntakeDraft profile,
  }) async {
    if (seed.isRegistration) {
      await _preferences.setString(
        _registeredEmailKey,
        seed.emailAddress.trim(),
      );
      await _preferences.setString(_registeredPasswordKey, seed.passwordText);
    }

    if (seed.isApple) {
      await _preferences.setString(_appleUserKey, seed.appleUserIdentifier);
      await _preferences.setString(_lastProviderKey, 'apple');
    } else {
      await _preferences.setString(_lastProviderKey, 'local');
    }

    await _preferences.setString(_profileNameKey, profile.displayName.trim());
    await _preferences.setString(
      _profileHandleKey,
      profile.chosenHandle.trim(),
    );
    await _preferences.setString(
      _profileSignatureKey,
      profile.signatureLine.trim(),
    );
    await _preferences.setString(
      _profileAvatarPathKey,
      profile.avatarLocalPath,
    );
    await _preferences.setString(
      _profileGenderKey,
      profile.socialSignalChoice.name,
    );
    await _preferences.setString(_profileRegionKey, profile.regionLedgerLabel);
    await _preferences.setBool(_sessionActiveKey, true);
  }
}

enum LocalCredentialCheck { accepted, noLocalAccount, mismatch }
