import 'package:flutter/material.dart';

class CredentialModeTabs extends StatelessWidget {
  const CredentialModeTabs({
    super.key,
    required this.isSignupMode,
    required this.onLoginSelected,
    required this.onSignupSelected,
  });

  final bool isSignupMode;
  final VoidCallback onLoginSelected;
  final VoidCallback onSignupSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModeTab(
            label: 'Log in',
            active: !isSignupMode,
            onPressed: onLoginSelected,
          ),
        ),
        Expanded(
          child: _ModeTab(
            label: 'Sign up',
            active: isSignupMode,
            onPressed: onSignupSelected,
          ),
        ),
      ],
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.active,
    required this.onPressed,
  });

  final String label;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: active ? 1 : 0.46,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: active ? 24 : 18,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: active ? 78 : 22,
              height: 4,
              decoration: BoxDecoration(
                color: active ? const Color(0xFFFF49D8) : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFF49D8).withValues(alpha: 0.5),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
