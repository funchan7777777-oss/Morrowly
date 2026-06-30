import 'package:flutter/material.dart';
import 'package:morrowly/journeys/present_grounding/widgets/keeper_memory_widgets.dart';
import 'package:morrowly/journeys/tomorrow_compass/data/tomorrow_compass_store.dart';
import 'package:morrowly/journeys/tomorrow_compass/widgets/tomorrow_compass_mark.dart';
import 'package:morrowly/shared/economy/morrowly_wallet_screen.dart';
import 'package:morrowly/shared/economy/morrowly_wallet_store.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';

class TomorrowCompassScreen extends StatefulWidget {
  const TomorrowCompassScreen({super.key});

  @override
  State<TomorrowCompassScreen> createState() => _TomorrowCompassScreenState();
}

class _TomorrowCompassScreenState extends State<TomorrowCompassScreen> {
  final TomorrowCompassStore _store = TomorrowCompassStore.instance;
  late final Future<void> _loadFuture = _store.load();
  final TextEditingController _anchorController = TextEditingController();
  final TextEditingController _firstStepController = TextEditingController();
  final TextEditingController _quietController = TextEditingController();
  final TextEditingController _recoveryController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  bool _hydrated = false;
  int _focusMinutes = TomorrowCompassDraft.empty.focusMinutes;

  @override
  void dispose() {
    _anchorController.dispose();
    _firstStepController.dispose();
    _quietController.dispose();
    _recoveryController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MorrowlyMemoryStage(
      resizeForKeyboard: true,
      child: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          _hydrateControllers();
          return AnimatedBuilder(
            animation: _store,
            builder: (context, _) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/morrowly_art/ui/morrowly_ui_shareable.png',
                      fit: BoxFit.cover,
                      opacity: const AlwaysStoppedAnimation(0.14),
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final contentWidth = MorrowlyFrameGuard.contentWidth(
                        constraints.maxWidth,
                        maxWidth: 430,
                        phoneGutter: 18,
                      );
                      final side = (constraints.maxWidth - contentWidth) / 2;
                      return SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.fromLTRB(
                          side,
                          MorrowlyFrameGuard.topClearance(
                            context,
                            minimum: 102,
                            extra: 28,
                          ),
                          side,
                          MorrowlyFrameGuard.bottomClearance(
                            context,
                            minimum: 54,
                            extra: 24,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _CompassHero(latestSeal: _store.latestSeal),
                            const SizedBox(height: 16),
                            _CompassDraftPanel(
                              anchorController: _anchorController,
                              firstStepController: _firstStepController,
                              quietController: _quietController,
                              recoveryController: _recoveryController,
                              questionController: _questionController,
                              focusMinutes: _focusMinutes,
                              onFocusChanged: (value) {
                                setState(() => _focusMinutes = value);
                              },
                              onSave: _saveDraft,
                              onSeal: _sealCompass,
                              onReset: _resetDraft,
                            ),
                            const SizedBox(height: 16),
                            _CompassHistory(seals: _store.seals),
                          ],
                        ),
                      );
                    },
                  ),
                  MorrowlyMemoryTopBar(
                    title: 'Tomorrow Compass',
                    topMinimum: 52,
                    topExtra: 2,
                    onBack: () => Navigator.of(context).pop(),
                    trailing: MorrowlyCoinBalancePill(
                      height: 28,
                      iconSize: 15,
                      fontSize: 11,
                      horizontalPadding: 8,
                      onTap: _openWallet,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _hydrateControllers() {
    if (_hydrated) {
      return;
    }
    final draft = _store.draft;
    _anchorController.text = draft.anchorLine;
    _firstStepController.text = draft.firstStep;
    _quietController.text = draft.quietBoundary;
    _recoveryController.text = draft.recoveryPlan;
    _questionController.text = draft.eveningQuestion;
    _focusMinutes = draft.focusMinutes;
    _hydrated = true;
  }

  TomorrowCompassDraft _readDraft() {
    return TomorrowCompassDraft(
      anchorLine: _anchorController.text.trim(),
      firstStep: _firstStepController.text.trim(),
      quietBoundary: _quietController.text.trim(),
      recoveryPlan: _recoveryController.text.trim(),
      eveningQuestion: _questionController.text.trim(),
      focusMinutes: _focusMinutes,
    );
  }

  Future<void> _saveDraft() async {
    await _store.saveDraft(_readDraft());
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tomorrow Compass draft saved locally.'),
        backgroundColor: lifePanel,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Future<void> _sealCompass() async {
    final draft = _readDraft();
    if (!draft.hasMeaningfulPlan) {
      await showDialog<void>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.62),
        builder: (context) => const _CompassNoticeDialog(
          title: 'Two signals needed',
          message:
              'Add tomorrow\'s main anchor and the first visible step before sealing the compass.',
          actionLabel: 'Continue editing',
        ),
      );
      return;
    }

    await _store.saveDraft(draft);
    if (!mounted) {
      return;
    }

    final spent = await confirmAndSpendMorrowlyCoins(
      context,
      cost: MorrowlyCoinCosts.sealTomorrowCompass,
    );
    if (!spent) {
      return;
    }

    await _store.sealCurrentDraft();
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.66),
      builder: (context) => const _CompassNoticeDialog(
        title: 'Compass sealed',
        message:
            'Your tomorrow guide is stored locally. Open it when the morning gets noisy.',
        actionLabel: 'Done',
        celebratory: true,
      ),
    );
  }

  Future<void> _resetDraft() async {
    _anchorController.clear();
    _firstStepController.clear();
    _quietController.clear();
    _recoveryController.clear();
    _questionController.clear();
    setState(() => _focusMinutes = TomorrowCompassDraft.empty.focusMinutes);
    await _store.resetDraft();
  }

  Future<void> _openWallet() {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const MorrowlyWalletScreen()),
    );
  }
}

class _CompassHero extends StatelessWidget {
  const _CompassHero({required this.latestSeal});

  final TomorrowCompassSeal? latestSeal;

  @override
  Widget build(BuildContext context) {
    final seal = latestSeal;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: lifePanel.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: Row(
        children: [
          const TomorrowCompassMark(size: 72),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seal == null ? 'Shape tomorrow' : 'Last sealed compass',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  seal == null
                      ? 'Turn one future intention into a calm, local guide.'
                      : seal.draft.anchorLine,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.64),
                    fontSize: 12,
                    height: 1.32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassDraftPanel extends StatelessWidget {
  const _CompassDraftPanel({
    required this.anchorController,
    required this.firstStepController,
    required this.quietController,
    required this.recoveryController,
    required this.questionController,
    required this.focusMinutes,
    required this.onFocusChanged,
    required this.onSave,
    required this.onSeal,
    required this.onReset,
  });

  final TextEditingController anchorController;
  final TextEditingController firstStepController;
  final TextEditingController quietController;
  final TextEditingController recoveryController;
  final TextEditingController questionController;
  final int focusMinutes;
  final ValueChanged<int> onFocusChanged;
  final VoidCallback onSave;
  final VoidCallback onSeal;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: lifePanel.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tomorrow signals',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
              _TinyTextButton(label: 'Reset', onTap: onReset),
            ],
          ),
          const SizedBox(height: 14),
          _CompassField(
            label: 'Main anchor',
            hint: 'What should tomorrow protect first?',
            controller: anchorController,
            maxLength: 80,
          ),
          const SizedBox(height: 12),
          _CompassField(
            label: 'First visible step',
            hint: 'Make it small enough to start.',
            controller: firstStepController,
            maxLength: 90,
          ),
          const SizedBox(height: 12),
          _CompassField(
            label: 'Quiet boundary',
            hint: 'What will stay outside this focus window?',
            controller: quietController,
            maxLength: 90,
          ),
          const SizedBox(height: 12),
          _CompassField(
            label: 'Recovery fallback',
            hint: 'If the day bends, where can it land?',
            controller: recoveryController,
            maxLength: 90,
          ),
          const SizedBox(height: 12),
          _CompassField(
            label: 'Evening question',
            hint: 'What should future you ask tonight?',
            controller: questionController,
            maxLength: 100,
          ),
          const SizedBox(height: 16),
          _FocusMinuteSlider(minutes: focusMinutes, onChanged: onFocusChanged),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _CompassActionButton(
                  label: 'Save draft',
                  filled: false,
                  onTap: onSave,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CompassActionButton(
                  label: 'Seal ${MorrowlyCoinCosts.sealTomorrowCompass.amount}',
                  filled: true,
                  onTap: onSeal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompassField extends StatelessWidget {
  const _CompassField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.maxLength,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          maxLength: maxLength,
          minLines: 1,
          maxLines: 3,
          cursorColor: Colors.white,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            height: 1.28,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.32),
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.07),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: lifePurple.withValues(alpha: 0.7),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FocusMinuteSlider extends StatelessWidget {
  const _FocusMinuteSlider({required this.minutes, required this.onChanged});

  final int minutes;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Focus window',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Text(
                '$minutes min',
                style: const TextStyle(
                  color: Color(0xFFFFD986),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          Slider(
            value: minutes.toDouble(),
            min: 10,
            max: 90,
            divisions: 16,
            activeColor: lifePurple,
            inactiveColor: Colors.white.withValues(alpha: 0.16),
            onChanged: (value) => onChanged(value.round()),
          ),
        ],
      ),
    );
  }
}

class _CompassHistory extends StatelessWidget {
  const _CompassHistory({required this.seals});

  final List<TomorrowCompassSeal> seals;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: lifePanel.withValues(alpha: 0.44),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sealed guides',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 12),
          if (seals.isEmpty)
            const _CompassEmptyHistory()
          else
            for (final seal in seals.take(3)) ...[
              _CompassSealTile(seal: seal),
              if (seal != seals.take(3).last) const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _CompassEmptyHistory extends StatelessWidget {
  const _CompassEmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/morrowly_art/ui/morrowly_ui_reminder.png',
          width: 74,
          height: 58,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'No sealed compass yet. Save a draft for free, then seal it when tomorrow feels clear enough.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.58),
              fontSize: 12,
              height: 1.32,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompassSealTile extends StatelessWidget {
  const _CompassSealTile({required this.seal});

  final TomorrowCompassSeal seal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/morrowly_art/ui/morrowly_ui_timelock.png',
            width: 34,
            height: 34,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seal.draft.anchorLine,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${seal.draft.focusMinutes} min focus · ${_shortDate(seal.sealedAt)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _shortDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month/$day';
  }
}

class _CompassActionButton extends StatelessWidget {
  const _CompassActionButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? lifePurple : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: lifePurple.withValues(alpha: 0.22),
                    blurRadius: 16,
                    offset: const Offset(0, 7),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _TinyTextButton extends StatelessWidget {
  const _TinyTextButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.56),
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _CompassNoticeDialog extends StatelessWidget {
  const _CompassNoticeDialog({
    required this.title,
    required this.message,
    required this.actionLabel,
    this.celebratory = false,
  });

  final String title;
  final String message;
  final String actionLabel;
  final bool celebratory;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 336),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            color: const Color(0xFF4D3657),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 126,
                height: 86,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 118,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          begin: celebratory
                              ? Alignment.topLeft
                              : Alignment.bottomLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            lifePurple.withValues(alpha: 0.18),
                            const Color(0xFFFFD6F6).withValues(alpha: 0.1),
                            Colors.white.withValues(alpha: 0.04),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    const TomorrowCompassMark(size: 66),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.64),
                  fontSize: 13,
                  height: 1.36,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 19),
              _CompassActionButton(
                label: actionLabel,
                filled: true,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
