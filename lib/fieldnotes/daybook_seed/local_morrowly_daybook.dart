import 'package:morrowly/journeys/memory_ribbon/models/recent_turning_point.dart';
import 'package:morrowly/journeys/present_grounding/models/grounding_rhythm.dart';
import 'package:morrowly/journeys/tomorrow_compass/models/evening_reflection_prompt.dart';
import 'package:morrowly/journeys/tomorrow_compass/models/focus_weight_band.dart';
import 'package:morrowly/journeys/tomorrow_compass/models/intention_pulse.dart';
import 'package:morrowly/journeys/tomorrow_compass/models/morrowly_day_brief.dart';
import 'package:morrowly/journeys/tomorrow_compass/models/quiet_focus_window.dart';
import 'package:morrowly/journeys/tomorrow_compass/models/tomorrow_intention.dart';

abstract final class LocalMorrowlyDaybook {
  static const activeBrief = MorrowlyDayBrief(
    briefKey: 'handoff-quiet-friday',
    calendarFaceLabel: 'Tonight into tomorrow',
    dayToneLine: 'A lighter plan is more likely to reach the morning.',
    openingNudge: 'Choose the first thing tomorrow should protect.',
    energyWeatherLabel: 'Clear, but shallow',
    carryForwardThread:
        'Two loose ends can move forward without becoming a list.',
    softDeadlineHint: 'Before lunch',
    intentions: [
      TomorrowIntention(
        intentionKey: 'reply-before-feed',
        narrativeLabel: 'Send the reply before opening the feed',
        workSurface: 'Inbox handoff',
        whyItMatters: 'It keeps a small promise from fading into the day.',
        firstVisibleStep: 'Open the draft and write the last paragraph.',
        fallbackLanding:
            'Leave a two-line update if the full reply needs more time.',
        weightBand: FocusWeightBand.lightTouch,
        pulse: IntentionPulse.tideMarker,
        focusMinutes: 18,
      ),
      TomorrowIntention(
        intentionKey: 'quiet-spec-pass',
        narrativeLabel: 'Shape one clean version of the notes',
        workSurface: 'Planning shelf',
        whyItMatters:
            'A clear version gives the next conversation a calmer start.',
        firstVisibleStep: 'Move the three useful bullets to the top.',
        fallbackLanding: 'Mark the rough section with one honest question.',
        weightBand: FocusWeightBand.steadyBlock,
        pulse: IntentionPulse.mossThread,
        focusMinutes: 35,
      ),
      TomorrowIntention(
        intentionKey: 'walk-after-submit',
        narrativeLabel: 'Step outside after the first finished block',
        workSurface: 'Recovery margin',
        whyItMatters:
            'A short reset gives the second half of the day softer edges.',
        firstVisibleStep: 'Put shoes near the door before bed.',
        fallbackLanding: 'Stand near a window for five slow breaths.',
        weightBand: FocusWeightBand.lightTouch,
        pulse: IntentionPulse.clayMarker,
        focusMinutes: 12,
      ),
    ],
    quietWindows: [
      QuietFocusWindow(
        windowKey: 'window-morning-landing',
        doorwayLabel: 'Morning landing',
        startsAtMinute: 520,
        closesAtMinute: 560,
        attentionBoundary: 'No inbox refresh until the first draft is touched.',
        recoveryPermission:
            'Tea, window light, and one scratch note are allowed.',
        interruptionPolicy: 'Only calendar alarms break this window.',
      ),
      QuietFocusWindow(
        windowKey: 'window-before-lunch',
        doorwayLabel: 'Before lunch',
        startsAtMinute: 660,
        closesAtMinute: 695,
        attentionBoundary: 'Keep it to one document and one question.',
        recoveryPermission: 'Stop when the clean version is readable.',
        interruptionPolicy: 'Defer anything that can wait twenty minutes.',
      ),
    ],
    reflectionPrompts: [
      EveningReflectionPrompt(
        promptKey: 'prompt-small-relief',
        questionLine: 'What felt easier after you named it?',
        softerFollowUp: 'Was the relief practical, emotional, or both?',
        answerLeadIn: 'It softened when...',
        belongsToMoment: 'Evening close',
      ),
      EveningReflectionPrompt(
        promptKey: 'prompt-tomorrow-kindness',
        questionLine: 'What would make tomorrow kinder by one notch?',
        softerFollowUp: 'Keep the answer small enough to schedule.',
        answerLeadIn: 'Tomorrow gets kinder if...',
        belongsToMoment: 'Tomorrow handoff',
      ),
    ],
  );

  static const groundingRhythms = [
    GroundingRhythm(
      rhythmKey: 'rhythm-countertop-reset',
      rhythmName: 'Countertop reset',
      settlingPhrase:
          'Clear one visible surface before making another decision.',
      minutes: 7,
      bodyCue: 'Hands moving, shoulders down',
      repeatPattern: 'Best after switching contexts',
      colorMood: 'clay',
    ),
    GroundingRhythm(
      rhythmKey: 'rhythm-two-song-sort',
      rhythmName: 'Two-song sort',
      settlingPhrase: 'Let two songs carry one tiny organizing pass.',
      minutes: 9,
      bodyCue: 'Stand, sort, stop',
      repeatPattern: 'Useful when the room feels busier than the plan',
      colorMood: 'moss',
    ),
    GroundingRhythm(
      rhythmKey: 'rhythm-window-note',
      rhythmName: 'Window note',
      settlingPhrase: 'Write one sentence while looking away from the screen.',
      minutes: 4,
      bodyCue: 'Eyes far, jaw loose',
      repeatPattern: 'Good before returning to a draft',
      colorMood: 'blue',
    ),
  ];

  static const memoryRibbon = [
    RecentTurningPoint(
      turningPointKey: 'turning-point-soft-no',
      shortScene: 'You said no before the request became urgent.',
      keptBecause: 'The boundary worked without needing a long explanation.',
      tomorrowUse: 'Use the same short phrasing when a new ask arrives.',
      recordedLabel: 'Kept from Wednesday',
      sentimentMarker: 'steady',
    ),
    RecentTurningPoint(
      turningPointKey: 'turning-point-earlier-draft',
      shortScene: 'The rough draft helped more than the polished outline.',
      keptBecause: 'Starting early reduced the weight of finishing.',
      tomorrowUse: 'Open with rough material instead of a blank page.',
      recordedLabel: 'Kept from last week',
      sentimentMarker: 'useful',
    ),
    RecentTurningPoint(
      turningPointKey: 'turning-point-after-walk',
      shortScene: 'A short walk changed the tone of the next conversation.',
      keptBecause: 'The pause gave the answer more room.',
      tomorrowUse: 'Place movement before the call, not after it.',
      recordedLabel: 'Kept from Sunday',
      sentimentMarker: 'bright',
    ),
  ];
}
