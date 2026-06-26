class EveningReflectionPrompt {
  const EveningReflectionPrompt({
    required this.promptKey,
    required this.questionLine,
    required this.softerFollowUp,
    required this.answerLeadIn,
    required this.belongsToMoment,
  });

  final String promptKey;
  final String questionLine;
  final String softerFollowUp;
  final String answerLeadIn;
  final String belongsToMoment;
}
