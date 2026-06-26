import 'package:flutter/material.dart';
import 'package:morrowly/journeys/welcome_gate/models/profile_intake_draft.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/artwork_tap_target.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/full_bleed_stage.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/gate_back_button.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/gender_signal_pill.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/soft_entry_field.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/welcome_artwork.dart';

class ProfileIntakeScreen extends StatefulWidget {
  const ProfileIntakeScreen({
    super.key,
    required this.onBack,
    required this.onStart,
  });

  final VoidCallback onBack;
  final VoidCallback onStart;

  @override
  State<ProfileIntakeScreen> createState() => _ProfileIntakeScreenState();
}

class _ProfileIntakeScreenState extends State<ProfileIntakeScreen> {
  ProfileIntakeDraft _draft = const ProfileIntakeDraft();

  @override
  Widget build(BuildContext context) {
    return FullBleedStage(
      backgroundAsset: WelcomeArtwork.profile,
      resizeForKeyboard: true,
      child: Stack(
        children: [
          GateBackButton(onBack: widget.onBack),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final contentWidth = width.clamp(320.0, 430.0).toDouble() * 0.82;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  (width - contentWidth) / 2,
                  104,
                  (width - contentWidth) / 2,
                  28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fill in your\ninformation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        height: 0.92,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'View all content after logging in',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.62),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const _AvatarCameraSpot(),
                    const SizedBox(height: 16),
                    const SoftEntryField(
                      label: 'Nickname',
                      placeholder: 'Please enter...',
                      trailingKind: FieldTrailingKind.clear,
                    ),
                    const SizedBox(height: 16),
                    const SoftEntryField(
                      label: 'Date of Birth',
                      placeholder: '2000  00  00',
                      trailingKind: FieldTrailingKind.chevron,
                      keyboardType: TextInputType.datetime,
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'Gender selection',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.28),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GenderSignalPill(
                            choice: SocialSignalChoice.female,
                            selectedChoice: _draft.socialSignalChoice,
                            onSelected: _chooseSignal,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GenderSignalPill(
                            choice: SocialSignalChoice.male,
                            selectedChoice: _draft.socialSignalChoice,
                            onSelected: _chooseSignal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const SoftEntryField(
                      label: 'Select country',
                      placeholder: 'United States',
                      trailingKind: FieldTrailingKind.chevron,
                    ),
                    const SizedBox(height: 16),
                    const SoftEntryField(
                      label: 'Signature',
                      placeholder: 'Please enter...',
                      maxLines: 4,
                      height: 102,
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: ArtworkTapTarget(
                        assetName: WelcomeArtwork.startButton,
                        width: contentWidth * 0.92,
                        semanticLabel: 'Start',
                        onPressed: widget.onStart,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _chooseSignal(SocialSignalChoice choice) {
    setState(() {
      _draft = _draft.copyWith(socialSignalChoice: choice);
    });
  }
}

class _AvatarCameraSpot extends StatelessWidget {
  const _AvatarCameraSpot();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Center(
            child: Image.asset(
              WelcomeArtwork.camera,
              width: 64,
              height: 64,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
        Positioned(
          top: -1,
          right: 4,
          child: Image.asset(
            WelcomeArtwork.fieldClear,
            width: 18,
            height: 18,
            filterQuality: FilterQuality.high,
          ),
        ),
      ],
    );
  }
}
