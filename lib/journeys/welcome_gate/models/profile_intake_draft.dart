enum SocialSignalChoice { female, male }

class ProfileIntakeDraft {
  const ProfileIntakeDraft({
    this.displayName = '',
    this.chosenHandle = '',
    this.regionLedgerLabel = 'United States',
    this.signatureLine = '',
    this.avatarLocalPath = '',
    this.socialSignalChoice = SocialSignalChoice.female,
  });

  final String displayName;
  final String chosenHandle;
  final String regionLedgerLabel;
  final String signatureLine;
  final String avatarLocalPath;
  final SocialSignalChoice socialSignalChoice;

  ProfileIntakeDraft copyWith({
    String? displayName,
    String? chosenHandle,
    String? regionLedgerLabel,
    String? signatureLine,
    String? avatarLocalPath,
    SocialSignalChoice? socialSignalChoice,
  }) {
    return ProfileIntakeDraft(
      displayName: displayName ?? this.displayName,
      chosenHandle: chosenHandle ?? this.chosenHandle,
      regionLedgerLabel: regionLedgerLabel ?? this.regionLedgerLabel,
      signatureLine: signatureLine ?? this.signatureLine,
      avatarLocalPath: avatarLocalPath ?? this.avatarLocalPath,
      socialSignalChoice: socialSignalChoice ?? this.socialSignalChoice,
    );
  }
}
