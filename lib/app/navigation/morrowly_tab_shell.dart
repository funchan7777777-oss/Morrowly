import 'package:flutter/material.dart';
import 'package:morrowly/journeys/present_grounding/view/present_grounding_screen.dart';
import 'package:morrowly/journeys/time_capsule/view/capsule_home_screen.dart';
import 'package:morrowly/journeys/time_mail/view/time_mail_screen.dart';

class MorrowlyTabShell extends StatefulWidget {
  const MorrowlyTabShell({
    super.key,
    this.onSignedOut,
    this.onLoggedOut,
    this.onAccountDeleted,
  });

  final VoidCallback? onSignedOut;
  final VoidCallback? onLoggedOut;
  final VoidCallback? onAccountDeleted;

  @override
  State<MorrowlyTabShell> createState() => _MorrowlyTabShellState();
}

class _MorrowlyTabShellState extends State<MorrowlyTabShell> {
  int _selectedHarborIndex = 0;

  @override
  Widget build(BuildContext context) {
    final harbors = [
      const _MorrowlyHarbor(
        voiceLabel: 'Tomorrow home',
        restingAsset: 'assets/images/Letter.png',
        litAsset: 'assets/images/Nostalgia.png',
        screen: CapsuleHomeScreen(),
      ),
      const _MorrowlyHarbor(
        voiceLabel: 'Now signal',
        restingAsset: 'assets/images/Journey.png',
        litAsset: 'assets/images/Sealed.png',
        screen: PresentGroundingScreen(),
      ),
      _MorrowlyHarbor(
        voiceLabel: 'Time mail',
        restingAsset: 'assets/images/Milestone.png',
        litAsset: 'assets/images/Anniversary.png',
        screen: TimeMailScreen(
          onGoCheckCapsules: () => setState(() => _selectedHarborIndex = 0),
          onSignedOut: widget.onSignedOut,
          onLoggedOut: widget.onLoggedOut,
          onAccountDeleted: widget.onAccountDeleted,
        ),
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          IndexedStack(
            index: _selectedHarborIndex,
            children: [for (final harbor in harbors) harbor.screen],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: _MorrowlyFloatingDock.bottomOffset,
            child: Center(
              child: _MorrowlyFloatingDock(
                harbors: harbors,
                selectedIndex: _selectedHarborIndex,
                onSelected: (index) {
                  setState(() => _selectedHarborIndex = index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MorrowlyHarbor {
  const _MorrowlyHarbor({
    required this.voiceLabel,
    required this.restingAsset,
    required this.litAsset,
    required this.screen,
  });

  final String voiceLabel;
  final String restingAsset;
  final String litAsset;
  final Widget screen;
}

class _MorrowlyFloatingDock extends StatelessWidget {
  const _MorrowlyFloatingDock({
    required this.harbors,
    required this.selectedIndex,
    required this.onSelected,
  });

  static const double width = 330;
  static const double height = 73;
  static const double bottomOffset = 34;
  static const double buttonExtent = 50;

  final List<_MorrowlyHarbor> harbors;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF3D3141),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF241726).withValues(alpha: 0.24),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var index = 0; index < harbors.length; index++)
                _MorrowlyDockButton(
                  harbor: harbors[index],
                  selected: selectedIndex == index,
                  onPressed: () => onSelected(index),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MorrowlyDockButton extends StatelessWidget {
  const _MorrowlyDockButton({
    required this.harbor,
    required this.selected,
    required this.onPressed,
  });

  final _MorrowlyHarbor harbor;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: harbor.voiceLabel,
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          scale: selected ? 1 : 0.96,
          child: Image.asset(
            selected ? harbor.litAsset : harbor.restingAsset,
            width: _MorrowlyFloatingDock.buttonExtent,
            height: _MorrowlyFloatingDock.buttonExtent,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
