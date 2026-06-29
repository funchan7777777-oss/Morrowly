import 'package:flutter/material.dart';
import 'package:morrowly/journeys/memory_ribbon/view/memory_ribbon_screen.dart';
import 'package:morrowly/journeys/present_grounding/data/life_snippet_store.dart';
import 'package:morrowly/journeys/present_grounding/models/life_snippet_models.dart';
import 'package:morrowly/journeys/present_grounding/widgets/life_snippet_widgets.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';

class TimeMailScreen extends StatefulWidget {
  const TimeMailScreen({
    super.key,
    this.onGoCheckCapsules,
    this.onSignedOut,
    this.onLoggedOut,
    this.onAccountDeleted,
  });

  final VoidCallback? onGoCheckCapsules;
  final VoidCallback? onSignedOut;
  final VoidCallback? onLoggedOut;
  final VoidCallback? onAccountDeleted;

  @override
  State<TimeMailScreen> createState() => _TimeMailScreenState();
}

class _TimeMailScreenState extends State<TimeMailScreen> {
  final LifeSnippetStore _store = LifeSnippetStore.instance;
  late final Future<void> _loadFuture = _store.load();

  @override
  Widget build(BuildContext context) {
    return LifeSnippetStage(
      child: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          return AnimatedBuilder(
            animation: _store,
            builder: (context, _) {
              final currentUser = _store.currentUser;
              final threads = _mailThreads
                  .where((thread) => !_store.isUserBlocked(thread.userKey))
                  .toList();

              return Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      ProfileCenterAssets.backgroundWash,
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
                        padding: EdgeInsets.fromLTRB(
                          side,
                          MorrowlyFrameGuard.topClearance(
                            context,
                            minimum: 48,
                            extra: 8,
                          ),
                          side,
                          MorrowlyFrameGuard.bottomClearance(
                            context,
                            minimum: 150,
                            extra: 108,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _MailHeader(
                              currentUser: currentUser,
                              onProfile: _openProfileCenter,
                            ),
                            const SizedBox(height: 28),
                            const _MailShortcutRow(),
                            const SizedBox(height: 26),
                            _CapsuleReminderCard(
                              onGoCheck: widget.onGoCheckCapsules,
                            ),
                            const SizedBox(height: 20),
                            for (final thread in threads) ...[
                              _MailThreadTile(thread: thread),
                              if (thread != threads.last)
                                const _MailThreadDivider(),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openProfileCenter() {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MemoryRibbonScreen(
          onSignedOut: widget.onSignedOut,
          onLoggedOut: widget.onLoggedOut,
          onAccountDeleted: widget.onAccountDeleted,
        ),
      ),
    );
  }
}

class _MailHeader extends StatelessWidget {
  const _MailHeader({required this.currentUser, required this.onProfile});

  final LifeSnippetUser currentUser;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 17),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                ProfileCenterAssets.underline,
                width: 117,
                height: 37,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.only(top: 16), child: _CoinPill()),
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: LifeAvatar(user: currentUser, radius: 20, onTap: onProfile),
        ),
      ],
    );
  }
}

class _CoinPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            ProfileCenterAssets.coin,
            width: 22,
            height: 22,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(width: 5),
          const Text(
            '123,45',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _MailShortcutRow extends StatelessWidget {
  const _MailShortcutRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _MailShortcut(
          asset: ProfileCenterAssets.messageStat,
          label: 'Comments',
          badgeLabel: '12',
        ),
        _MailShortcut(asset: ProfileCenterAssets.likeStat, label: 'Likes'),
        _MailShortcut(asset: ProfileCenterAssets.fanStat, label: 'Add friend'),
        _MailShortcut(asset: ProfileCenterAssets.followStat, label: 'Friends'),
      ],
    );
  }
}

class _MailShortcut extends StatelessWidget {
  const _MailShortcut({
    required this.asset,
    required this.label,
    this.badgeLabel,
  });

  final String asset;
  final String label;
  final String? badgeLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Image.asset(
                asset,
                width: 70,
                height: 70,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
              if (badgeLabel != null)
                Positioned(
                  top: 2,
                  right: -1,
                  child: Container(
                    height: 19,
                    constraints: const BoxConstraints(minWidth: 28),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF373C),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badgeLabel!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.46),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _CapsuleReminderCard extends StatelessWidget {
  const _CapsuleReminderCard({required this.onGoCheck});

  final VoidCallback? onGoCheck;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onGoCheck,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E1335).withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: AspectRatio(
          aspectRatio: 700 / 236,
          child: Image.asset(
            ProfileCenterAssets.capsuleBanner,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}

class _MailThreadTile extends StatelessWidget {
  const _MailThreadTile({required this.thread});

  final _MailThread thread;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 66,
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            backgroundImage: AssetImage(thread.avatarAsset),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  thread.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.1,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  thread.preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.34),
                    fontSize: 15,
                    height: 1.1,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                thread.timeLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.24),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              if (thread.unreadCount > 0) ...[
                const SizedBox(height: 18),
                Container(
                  height: 20,
                  constraints: const BoxConstraints(minWidth: 29),
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF373C),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${thread.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MailThreadDivider extends StatelessWidget {
  const _MailThreadDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 66),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.white.withValues(alpha: 0.06),
      ),
    );
  }
}

class _MailThread {
  const _MailThread({
    required this.userKey,
    required this.name,
    required this.avatarAsset,
    required this.preview,
    required this.timeLabel,
    this.unreadCount = 0,
  });

  final String userKey;
  final String name;
  final String avatarAsset;
  final String preview;
  final String timeLabel;
  final int unreadCount;
}

const _mailThreads = [
  _MailThread(
    userKey: 'wayne-walters',
    name: 'Wayne Walters',
    avatarAsset: 'assets/images/head/bloom_cedar_terrace.jpg',
    preview: 'Do you also love turning your thoughts into time capsules?',
    timeLabel: '08:45',
  ),
  _MailThread(
    userKey: 'bessie-parks',
    name: 'Bessie Parks',
    avatarAsset: 'assets/images/head/muse_highland_walk.jpg',
    preview: "Let's wait for time.",
    timeLabel: '08:45',
    unreadCount: 3,
  ),
  _MailThread(
    userKey: 'terry-reynolds',
    name: 'Terry Reynolds',
    avatarAsset: 'assets/images/head/muse_warm_wall.jpg',
    preview: "That's exactly the charm of this time-capsule message.",
    timeLabel: '08:45',
  ),
  _MailThread(
    userKey: 'luella-welch',
    name: 'Luella Welch',
    avatarAsset: 'assets/images/head/muse_pavement_smile.jpg',
    preview: 'Pictures with words will be precious years from now.',
    timeLabel: '08:45',
  ),
];
