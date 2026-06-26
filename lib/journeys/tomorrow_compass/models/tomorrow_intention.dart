import 'package:morrowly/journeys/tomorrow_compass/models/focus_weight_band.dart';
import 'package:morrowly/journeys/tomorrow_compass/models/intention_pulse.dart';

class TomorrowIntention {
  const TomorrowIntention({
    required this.intentionKey,
    required this.narrativeLabel,
    required this.workSurface,
    required this.whyItMatters,
    required this.firstVisibleStep,
    required this.fallbackLanding,
    required this.weightBand,
    required this.pulse,
    required this.focusMinutes,
  });

  final String intentionKey;
  final String narrativeLabel;
  final String workSurface;
  final String whyItMatters;
  final String firstVisibleStep;
  final String fallbackLanding;
  final FocusWeightBand weightBand;
  final IntentionPulse pulse;
  final int focusMinutes;
}
