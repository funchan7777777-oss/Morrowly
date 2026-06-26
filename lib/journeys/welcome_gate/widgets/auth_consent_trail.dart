import 'package:flutter/material.dart';

class AuthConsentTrail extends StatelessWidget {
  const AuthConsentTrail({
    super.key,
    required this.accepted,
    required this.onChanged,
    required this.onUserAgreement,
    required this.onPrivacyPolicy,
  });

  final bool accepted;
  final ValueChanged<bool> onChanged;
  final VoidCallback onUserAgreement;
  final VoidCallback onPrivacyPolicy;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(!accepted),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 17,
            height: 17,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: accepted
                  ? const LinearGradient(
                      colors: [Color(0xFFFF49D8), Color(0xFFB568FF)],
                    )
                  : null,
              border: Border.all(
                color: accepted
                    ? Colors.white.withValues(alpha: 0.58)
                    : Colors.white.withValues(alpha: 0.48),
                width: 1.2,
              ),
              boxShadow: accepted
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFF49D8).withValues(alpha: 0.28),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: accepted
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _ConsentCopy(
                text: 'I have read and agree to the ',
                muted: true,
                onTap: () => onChanged(!accepted),
              ),
              _ConsentCopy(text: 'User Agreement', onTap: onUserAgreement),
              _ConsentCopy(
                text: ' and ',
                muted: true,
                onTap: () => onChanged(!accepted),
              ),
              _ConsentCopy(text: 'Privacy Policy', onTap: onPrivacyPolicy),
              _ConsentCopy(
                text: '.',
                muted: true,
                onTap: () => onChanged(!accepted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConsentCopy extends StatelessWidget {
  const _ConsentCopy({
    required this.text,
    required this.onTap,
    this.muted = false,
  });

  final String text;
  final VoidCallback onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: muted
              ? Colors.white.withValues(alpha: 0.48)
              : const Color(0xFFFF6AE8),
          fontSize: 10,
          height: 1.35,
          fontWeight: muted ? FontWeight.w600 : FontWeight.w900,
          decoration: muted ? TextDecoration.none : TextDecoration.underline,
          decorationColor: const Color(0xFFFF6AE8),
          decorationThickness: 1.2,
        ),
      ),
    );
  }
}
