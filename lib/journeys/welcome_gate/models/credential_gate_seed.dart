enum CredentialGateIntent { localSignIn, localRegistration, appleProfile }

class PendingCredentialSeed {
  const PendingCredentialSeed({
    required this.intent,
    this.emailAddress = '',
    this.passwordText = '',
    this.appleUserIdentifier = '',
    this.profileName = '',
  });

  final CredentialGateIntent intent;
  final String emailAddress;
  final String passwordText;
  final String appleUserIdentifier;
  final String profileName;

  bool get isApple => intent == CredentialGateIntent.appleProfile;
  bool get isRegistration => intent == CredentialGateIntent.localRegistration;
}
