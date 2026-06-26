import 'package:morrowly/journeys/tomorrow_compass/models/evening_reflection_prompt.dart';
import 'package:morrowly/journeys/tomorrow_compass/models/quiet_focus_window.dart';
import 'package:morrowly/journeys/tomorrow_compass/models/tomorrow_intention.dart';

class MorrowlyDayBrief {
  const MorrowlyDayBrief({
    required this.briefKey,
    required this.calendarFaceLabel,
    required this.dayToneLine,
    required this.openingNudge,
    required this.energyWeatherLabel,
    required this.carryForwardThread,
    required this.softDeadlineHint,
    required this.intentions,
    required this.quietWindows,
    required this.reflectionPrompts,
  });

  final String briefKey;
  final String calendarFaceLabel;
  final String dayToneLine;
  final String openingNudge;
  final String energyWeatherLabel;
  final String carryForwardThread;
  final String softDeadlineHint;
  final List<TomorrowIntention> intentions;
  final List<QuietFocusWindow> quietWindows;
  final List<EveningReflectionPrompt> reflectionPrompts;
}
