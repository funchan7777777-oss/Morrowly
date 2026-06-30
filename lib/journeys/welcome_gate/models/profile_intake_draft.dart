enum SocialSignalChoice { female, male }

class ProfileIntakeDraft {
  const ProfileIntakeDraft({
    this.keeperName = '',
    this.chosenHandle = '',
    this.regionLedgerLabel = 'United States',
    this.morrowLine = '',
    this.localPortraitPath = '',
    this.socialSignalChoice = SocialSignalChoice.female,
  });

  final String keeperName;
  final String chosenHandle;
  final String regionLedgerLabel;
  final String morrowLine;
  final String localPortraitPath;
  final SocialSignalChoice socialSignalChoice;

  ProfileIntakeDraft copyWith({
    String? keeperName,
    String? chosenHandle,
    String? regionLedgerLabel,
    String? morrowLine,
    String? localPortraitPath,
    SocialSignalChoice? socialSignalChoice,
  }) {
    return ProfileIntakeDraft(
      keeperName: keeperName ?? this.keeperName,
      chosenHandle: chosenHandle ?? this.chosenHandle,
      regionLedgerLabel: regionLedgerLabel ?? this.regionLedgerLabel,
      morrowLine: morrowLine ?? this.morrowLine,
      localPortraitPath: localPortraitPath ?? this.localPortraitPath,
      socialSignalChoice: socialSignalChoice ?? this.socialSignalChoice,
    );
  }
}
