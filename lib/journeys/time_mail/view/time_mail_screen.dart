import 'package:flutter/material.dart';
import 'package:morrowly/journeys/memory_ribbon/view/memory_ribbon_screen.dart';
import 'package:morrowly/journeys/present_grounding/data/life_snippet_store.dart';
import 'package:morrowly/journeys/present_grounding/models/life_snippet_models.dart';
import 'package:morrowly/journeys/present_grounding/view/life_snippet_chat_screen.dart';
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
              final threads = [
                for (final userKey in _store.chatThreadUserKeys)
                  _MailThread(
                    user: _store.userByKey(userKey),
                    message: _store.chatMessagesFor(userKey).last,
                  ),
              ];

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
                            if (threads.isEmpty)
                              const _EmptyMailThreads()
                            else
                              for (final thread in threads) ...[
                                _MailThreadTile(
                                  thread: thread,
                                  onTap: () => _openChat(thread.user.userKey),
                                ),
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

  Future<void> _openChat(String userKey) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => LifeSnippetChatScreen(userKey: userKey),
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
  const _MailThreadTile({required this.thread, required this.onTap});

  final _MailThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 66,
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              backgroundImage: lifeAvatarProvider(thread.user),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thread.user.displayName,
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
                    thread.message.body,
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
                  _clockLabel(thread.message.createdAt),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.24),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
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
  const _MailThread({required this.user, required this.message});

  final LifeSnippetUser user;
  final LifeChatMessage message;
}

class _EmptyMailThreads extends StatelessWidget {
  const _EmptyMailThreads();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
      decoration: BoxDecoration(
        color: lifePanel.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: [
          Image.asset(
            ProfileCenterAssets.messageStat,
            width: 58,
            height: 58,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(height: 10),
          const Text(
            'No conversations yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Real chats will appear here after you message someone.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
              height: 1.34,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

String _clockLabel(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
