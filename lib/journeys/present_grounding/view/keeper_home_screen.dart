import 'package:flutter/material.dart';
import 'package:morrowly/journeys/present_grounding/data/keeper_memory_store.dart';
import 'package:morrowly/journeys/present_grounding/models/keeper_memory_thread.dart';
import 'package:morrowly/journeys/present_grounding/view/keeper_letter_thread_screen.dart';
import 'package:morrowly/journeys/present_grounding/view/memory_seal_detail_screen.dart';
import 'package:morrowly/journeys/present_grounding/widgets/keeper_memory_widgets.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';
import 'package:morrowly/shared/widgets/morrowly_moderation_dialog.dart';

class KeeperHomeScreen extends StatefulWidget {
  const KeeperHomeScreen({super.key, required this.keeperId});

  final String keeperId;

  @override
  State<KeeperHomeScreen> createState() => _KeeperHomeScreenState();
}

class _KeeperHomeScreenState extends State<KeeperHomeScreen> {
  final KeeperMemoryStore _store = KeeperMemoryStore.instance;

  @override
  Widget build(BuildContext context) {
    return MorrowlyMemoryStage(
      child: AnimatedBuilder(
        animation: _store,
        builder: (context, _) {
          final user = _store.keeperById(widget.keeperId);
          final profileHidden =
              !user.belongsToSignedInKeeper &&
              _store.shouldHideUserProfile(user.keeperId);
          if (profileHidden) {
            return Stack(
              children: [
                const _HiddenProfilePanel(),
                MorrowlyMemoryTopBar(
                  title: 'User home',
                  onBack: () => Navigator.of(context).pop(),
                  topMinimum: 40,
                  topExtra: -8,
                ),
              ],
            );
          }
          final posts = _store.postsForUser(user.keeperId);
          return Stack(
            children: [
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
                      MorrowlyFrameGuard.topBarContentClearance(
                        context,
                        topMinimum: 40,
                        topExtra: -8,
                        gap: 20,
                      ),
                      side,
                      MorrowlyFrameGuard.bottomClearance(
                        context,
                        minimum: 34,
                        extra: 18,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileHeader(
                          user: user,
                          stats: _ProfileStatsData(
                            followingCount: _store.profileFollowCountFor(
                              user.keeperId,
                            ),
                            followerCount: _store.profileFansCountFor(
                              user.keeperId,
                            ),
                            glowCount: _store.profileLikeCountFor(
                              user.keeperId,
                            ),
                            keptCapsuleCount: _store.profileCapsuleCountFor(
                              user.keeperId,
                            ),
                          ),
                          followStatus: _store.followStatusFor(user.keeperId),
                          onFollow: () => _requestFollow(user.keeperId),
                          onChat:
                              user.belongsToSignedInKeeper ||
                                  _store.isUserBlocked(user.keeperId) ||
                                  !_store.isMutualFollow(user.keeperId)
                              ? null
                              : () => _openChat(user.keeperId),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Their Posts',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (posts.isEmpty)
                          _EmptyProfilePosts(
                            belongsToSignedInKeeper:
                                user.belongsToSignedInKeeper,
                          )
                        else
                          for (final post in posts) ...[
                            _ProfilePostCard(
                              post: post,
                              author: user,
                              replyCount: _store.visibleReplyCount(post),
                              glowCount: _store.visibleLikeCount(post),
                              liked: _store.isPostLiked(post.sealId),
                              followStatus: _store.followStatusFor(
                                user.keeperId,
                              ),
                              onOpen: () => _openPost(post.sealId),
                              onAuthor: () => _openProfile(user.keeperId),
                              onFollow: () => _requestFollow(user.keeperId),
                              onLike: () => _store.toggleLike(post.sealId),
                            ),
                            const SizedBox(height: 14),
                          ],
                      ],
                    ),
                  );
                },
              ),
              MorrowlyMemoryTopBar(
                title: 'User home',
                onBack: () => Navigator.of(context).pop(),
                topMinimum: 40,
                topExtra: -8,
                trailing: IconButton(
                  onPressed: user.belongsToSignedInKeeper
                      ? null
                      : () => _showUserModeration(user.keeperId),
                  icon: Icon(
                    Icons.info_rounded,
                    color: user.belongsToSignedInKeeper
                        ? Colors.transparent
                        : Colors.white,
                    size: 22,
                  ),
                  tooltip: 'Report or block',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _requestFollow(String keeperId) async {
    await _store.requestFollow(keeperId);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Follow request sent. Waiting for approval.'),
        backgroundColor: lifePanel,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Future<void> _openChat(String keeperId) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => KeeperLetterThreadScreen(keeperId: keeperId),
      ),
    );
  }

  Future<void> _openPost(String sealId) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => MemorySealDetailScreen(sealId: sealId)),
    );
  }

  Future<void> _openProfile(String keeperId) {
    if (keeperId == widget.keeperId) {
      return Future.value();
    }
    return Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => KeeperHomeScreen(keeperId: keeperId)),
    );
  }

  Future<void> _showUserModeration(String keeperId) async {
    final result = await showMorrowlyModerationFlow(
      context: context,
      target: _store.moderationTargetForUser(keeperId),
      onReport: (reason) => _store.reportUser(keeperId, reason: reason),
      onBlock: () => _store.blockUser(keeperId),
    );
    if (result == null || !mounted) {
      return;
    }
    if (_store.shouldHideUserProfile(keeperId)) {
      Navigator.of(context).pop();
    } else {
      setState(() {});
    }
  }
}

class _HiddenProfilePanel extends StatelessWidget {
  const _HiddenProfilePanel();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
          decoration: BoxDecoration(
            color: lifePanel.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Text(
            'This profile is hidden on this device.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
              height: 1.34,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileStatsData {
  const _ProfileStatsData({
    required this.followingCount,
    required this.followerCount,
    required this.glowCount,
    required this.keptCapsuleCount,
  });

  final int followingCount;
  final int followerCount;
  final int glowCount;
  final int keptCapsuleCount;
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.stats,
    required this.followStatus,
    required this.onFollow,
    required this.onChat,
  });

  final KeeperProfile user;
  final _ProfileStatsData stats;
  final KeeperLinkState followStatus;
  final VoidCallback onFollow;
  final VoidCallback? onChat;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KeeperAvatar(user: user, radius: 38),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.publicName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (!user.belongsToSignedInKeeper)
                        KeeperLinkButton(
                          status: followStatus,
                          onPressed: onFollow,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.female_rounded,
                        color: Color(0xFFFF78C8),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          user.profileTrail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFBD78FF),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user.morrowLine,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 12,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ProfileStat(value: stats.followingCount, label: 'Follow'),
            _ProfileStat(value: stats.followerCount, label: 'Fans'),
            _ProfileStat(value: stats.glowCount, label: 'Get likes'),
            _ProfileStat(value: stats.keptCapsuleCount, label: 'Capsule'),
          ],
        ),
        if (onChat != null) ...[
          const SizedBox(height: 18),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onChat,
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: lifePurple,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: lifePurple.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Text(
                'Chat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.28),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ProfilePostCard extends StatelessWidget {
  const _ProfilePostCard({
    required this.post,
    required this.author,
    required this.replyCount,
    required this.glowCount,
    required this.liked,
    required this.followStatus,
    required this.onOpen,
    required this.onAuthor,
    required this.onFollow,
    required this.onLike,
  });

  final MemorySeal post;
  final KeeperProfile author;
  final int replyCount;
  final int glowCount;
  final bool liked;
  final KeeperLinkState followStatus;
  final VoidCallback onOpen;
  final VoidCallback onAuthor;
  final VoidCallback onFollow;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.fromLTRB(13, 12, 13, 11),
        decoration: BoxDecoration(
          color: lifePanel.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                KeeperAvatar(user: author, radius: 22, onTap: onAuthor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author.publicName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        author.profileTrail,
                        style: const TextStyle(
                          color: Color(0xFFBD78FF),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!author.belongsToSignedInKeeper)
                  KeeperLinkButton(status: followStatus, onPressed: onFollow),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.noteLine,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (post.attachments.isNotEmpty) ...[
              const SizedBox(height: 12),
              AspectRatio(
                aspectRatio: 1.44,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MemoryAttachmentImage(
                    attachment: post.attachments.first,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                _ActionCount(
                  asset: MorrowlyAssetKit.comment,
                  count: replyCount,
                ),
                const SizedBox(width: 24),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onLike,
                  child: _ActionCount(
                    asset: liked
                        ? MorrowlyAssetKit.likeFilled
                        : MorrowlyAssetKit.likeOutline,
                    count: glowCount,
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

class _ActionCount extends StatelessWidget {
  const _ActionCount({required this.asset, required this.count});

  final String asset;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          asset,
          width: 19,
          height: 19,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(width: 5),
        Text(
          '$count',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.32),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _EmptyProfilePosts extends StatelessWidget {
  const _EmptyProfilePosts({required this.belongsToSignedInKeeper});

  final bool belongsToSignedInKeeper;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: lifePanel.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        belongsToSignedInKeeper
            ? 'Your submitted memory seals wait for moderation before they appear here.'
            : 'No approved posts from this user yet.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.58),
          fontSize: 12,
          height: 1.35,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
