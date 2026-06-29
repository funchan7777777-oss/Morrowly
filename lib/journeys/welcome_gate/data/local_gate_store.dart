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
  static const _profileBirthDateKey = 'morrowly.profile.birthDate';
  static const _appleUserKey = 'morrowly.apple.userIdentifier';
  static const _lastProviderKey = 'morrowly.session.provider';
  static const _legalAgreementKey = 'morrowly.legal.agreementAccepted';

  static Future<LocalGateStore> open() async {
    return LocalGateStore(await SharedPreferences.getInstance());
  }

  bool get hasActiveSession {
    return _preferences.getBool(_sessionActiveKey) ?? false;
  }

  bool get hasAcceptedLegalAgreement {
    return _preferences.getBool(_legalAgreementKey) ?? false;
  }

  bool get hasLocalAccount {
    final email = _preferences.getString(_registeredEmailKey) ?? '';
    final password = _preferences.getString(_registeredPasswordKey) ?? '';
    return email.isNotEmpty && password.isNotEmpty;
  }

  String get savedDisplayName {
    return _preferences.getString(_profileNameKey) ?? '';
  }

  String get savedHandle {
    return _preferences.getString(_profileHandleKey) ?? '';
  }

  String get savedSignatureLine {
    return _preferences.getString(_profileSignatureKey) ?? '';
  }

  String get savedAvatarPath {
    return _preferences.getString(_profileAvatarPathKey) ?? '';
  }

  String get savedGender {
    return _preferences.getString(_profileGenderKey) ?? '';
  }

  String get savedRegion {
    return _preferences.getString(_profileRegionKey) ?? 'United States';
  }

  String get savedBirthDate {
    return _preferences.getString(_profileBirthDateKey) ?? '';
  }

  Future<void> setLegalAgreementAccepted(bool accepted) async {
    await _preferences.setBool(_legalAgreementKey, accepted);
  }

  Future<void> acceptLocalLogin({
    required String emailAddress,
    required String passwordText,
  }) async {
    await _preferences.setString(_registeredEmailKey, emailAddress.trim());
    await _preferences.setString(_registeredPasswordKey, passwordText);
    await _preferences.setBool(_sessionActiveKey, true);
    await _preferences.setString(_lastProviderKey, 'local');
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

  Future<void> updateProfile({
    required String displayName,
    required String signatureLine,
    required String avatarLocalPath,
    required String gender,
    required String region,
    required String birthDate,
  }) async {
    await _preferences.setString(_profileNameKey, displayName.trim());
    await _preferences.setString(_profileSignatureKey, signatureLine.trim());
    await _preferences.setString(_profileAvatarPathKey, avatarLocalPath);
    await _preferences.setString(_profileGenderKey, gender);
    await _preferences.setString(_profileRegionKey, region);
    await _preferences.setString(_profileBirthDateKey, birthDate.trim());
  }

  Future<void> signOut() async {
    await _preferences.setBool(_sessionActiveKey, false);
  }

  Future<void> deleteLocalAccount() async {
    await _preferences.setBool(_sessionActiveKey, false);
    await _preferences.remove(_registeredEmailKey);
    await _preferences.remove(_registeredPasswordKey);
    await _preferences.remove(_profileNameKey);
    await _preferences.remove(_profileHandleKey);
    await _preferences.remove(_profileSignatureKey);
    await _preferences.remove(_profileAvatarPathKey);
    await _preferences.remove(_profileGenderKey);
    await _preferences.remove(_profileRegionKey);
    await _preferences.remove(_profileBirthDateKey);
    await _preferences.remove(_appleUserKey);
    await _preferences.remove(_lastProviderKey);
  }
}
