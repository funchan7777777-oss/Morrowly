import 'package:flutter/material.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/artwork_tap_target.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/welcome_artwork.dart';

class OnboardingSequenceScreen extends StatefulWidget {
  const OnboardingSequenceScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<OnboardingSequenceScreen> createState() =>
      _OnboardingSequenceScreenState();
}

class _OnboardingSequenceScreenState extends State<OnboardingSequenceScreen> {
  final PageController _controller = PageController();
  int _pageIndex = 0;

  static const _pages = [
    _OnboardingPageSpec(
      background: WelcomeArtwork.credential,
      title: 'Start softer',
      body:
          'Let tomorrow begin with one clear thread instead of a crowded list.',
      accent: Color(0xFFFF48D9),
    ),
    _OnboardingPageSpec(
      background: WelcomeArtwork.profile,
      title: 'Keep the signal',
      body:
          'Save the detail, promise, or pause that still knows where it belongs.',
      accent: Color(0xFFB66CFF),
    ),
    _OnboardingPageSpec(
      background: WelcomeArtwork.invitation,
      title: 'Return ready',
      body:
          'Your profile keeps the small context that makes each handoff feel personal.',
      accent: Color(0xFF78F596),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = _pages[_pageIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF2A2225),
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (index) => setState(() => _pageIndex = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    page.background,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.02),
                          Colors.black.withValues(alpha: 0.12),
                          Colors.black.withValues(alpha: 0.38),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 0, 30, 142),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          page.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            height: 0.98,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          page.body,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 15,
                            height: 1.42,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            left: 30,
            bottom: 96,
            child: Row(
              children: List.generate(_pages.length, (index) {
                final selected = index == _pageIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: selected ? 26 : 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? currentPage.accent
                        : Colors.white.withValues(alpha: 0.38),
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
          ),
          Positioned(
            right: 30,
            bottom: 70,
            child: _pageIndex == _pages.length - 1
                ? ArtworkTapTarget(
                    assetName: WelcomeArtwork.startButton,
                    width: 162,
                    semanticLabel: 'Start',
                    onPressed: widget.onFinished,
                  )
                : FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: currentPage.accent,
                      foregroundColor: Colors.white,
                      fixedSize: const Size(116, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    onPressed: _advance,
                    child: const Text(
                      'Next',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _advance() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }
}

class _OnboardingPageSpec {
  const _OnboardingPageSpec({
    required this.background,
    required this.title,
    required this.body,
    required this.accent,
  });

  final String background;
  final String title;
  final String body;
  final Color accent;
}
