enum SocialSignalChoice { female, male }

class ProfileIntakeDraft {
  const ProfileIntakeDraft({
    this.chosenHandle = '',
    this.birthRibbonText = '',
    this.regionLedgerLabel = 'United States',
    this.signatureLine = '',
    this.socialSignalChoice = SocialSignalChoice.female,
  });

  final String chosenHandle;
  final String birthRibbonText;
  final String regionLedgerLabel;
  final String signatureLine;
  final SocialSignalChoice socialSignalChoice;

  ProfileIntakeDraft copyWith({
    String? chosenHandle,
    String? birthRibbonText,
    String? regionLedgerLabel,
    String? signatureLine,
    SocialSignalChoice? socialSignalChoice,
  }) {
    return ProfileIntakeDraft(
      chosenHandle: chosenHandle ?? this.chosenHandle,
      birthRibbonText: birthRibbonText ?? this.birthRibbonText,
      regionLedgerLabel: regionLedgerLabel ?? this.regionLedgerLabel,
      signatureLine: signatureLine ?? this.signatureLine,
      socialSignalChoice: socialSignalChoice ?? this.socialSignalChoice,
    );
  }
}
