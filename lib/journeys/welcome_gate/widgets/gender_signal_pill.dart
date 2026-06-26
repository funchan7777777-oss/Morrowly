import 'package:flutter/material.dart';
import 'package:morrowly/journeys/welcome_gate/models/profile_intake_draft.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/welcome_artwork.dart';

class GenderSignalPill extends StatelessWidget {
  const GenderSignalPill({
    super.key,
    required this.choice,
    required this.selectedChoice,
    required this.onSelected,
  });

  final SocialSignalChoice choice;
  final SocialSignalChoice selectedChoice;
  final ValueChanged<SocialSignalChoice> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = choice == selectedChoice;
    final isFemale = choice == SocialSignalChoice.female;
    final tone = isFemale ? const Color(0xFFF154BC) : const Color(0xFF35A9F6);

    return GestureDetector(
      onTap: () => onSelected(choice),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: selected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.24),
            width: selected ? 1.2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: tone.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              _assetForChoice(isFemale: isFemale, selected: selected),
              width: 22,
              height: 22,
              filterQuality: FilterQuality.high,
            ),
            const SizedBox(width: 8),
            Text(
              isFemale ? 'Female' : 'Male',
              style: TextStyle(
                color: selected ? tone : const Color(0xFF928698),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _assetForChoice({required bool isFemale, required bool selected}) {
    if (isFemale) {
      return selected ? WelcomeArtwork.female : WelcomeArtwork.femaleMuted;
    }
    return selected ? WelcomeArtwork.male : WelcomeArtwork.maleMuted;
  }
}
