import 'package:flutter/material.dart';
import 'package:morrowly/journeys/memory_ribbon/view/memory_ribbon_screen.dart';
import 'package:morrowly/journeys/present_grounding/view/present_grounding_screen.dart';
import 'package:morrowly/journeys/tomorrow_compass/view/tomorrow_compass_screen.dart';

class MorrowlyTabShell extends StatefulWidget {
  const MorrowlyTabShell({super.key});

  @override
  State<MorrowlyTabShell> createState() => _MorrowlyTabShellState();
}

class _MorrowlyTabShellState extends State<MorrowlyTabShell> {
  int _selectedHarborIndex = 0;

  static const List<_MorrowlyHarbor> _harbors = [
    _MorrowlyHarbor(
      label: 'Tomorrow',
      icon: Icons.calendar_today_outlined,
      selectedIcon: Icons.calendar_today,
      screen: TomorrowCompassScreen(),
    ),
    _MorrowlyHarbor(
      label: 'Now',
      icon: Icons.spa_outlined,
      selectedIcon: Icons.spa,
      screen: PresentGroundingScreen(),
    ),
    _MorrowlyHarbor(
      label: 'Ribbon',
      icon: Icons.bookmark_border,
      selectedIcon: Icons.bookmark,
      screen: MemoryRibbonScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedHarborIndex,
        children: [for (final harbor in _harbors) harbor.screen],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedHarborIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedHarborIndex = index);
        },
        destinations: [
          for (final harbor in _harbors)
            NavigationDestination(
              icon: Icon(harbor.icon),
              selectedIcon: Icon(harbor.selectedIcon),
              label: harbor.label,
            ),
        ],
      ),
    );
  }
}

class _MorrowlyHarbor {
  const _MorrowlyHarbor({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.screen,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget screen;
}
