import 'package:flutter/material.dart';
import 'package:morrowly/journeys/memory_ribbon/view/memory_ribbon_screen.dart';
import 'package:morrowly/journeys/present_grounding/data/keeper_memory_store.dart';
import 'package:morrowly/journeys/present_grounding/models/keeper_memory_thread.dart';
import 'package:morrowly/journeys/present_grounding/view/memory_release_screen.dart';
import 'package:morrowly/journeys/present_grounding/view/memory_seal_detail_screen.dart';
import 'package:morrowly/journeys/present_grounding/view/keeper_home_screen.dart';
import 'package:morrowly/journeys/present_grounding/widgets/keeper_memory_widgets.dart';
import 'package:morrowly/shared/economy/morrowly_wallet_screen.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';
import 'package:morrowly/shared/widgets/morrowly_moderation_dialog.dart';

class PresentGroundingScreen extends StatefulWidget {
  const PresentGroundingScreen({super.key});

  @override
  State<PresentGroundingScreen> createState() => _PresentGroundingScreenState();
}

class _PresentGroundingScreenState extends State<PresentGroundingScreen> {
  final KeeperMemoryStore _store = KeeperMemoryStore.instance;
  late final Future<void> _loadFuture = _store.load();
  MemoryShelfFilter _filter = MemoryShelfFilter.popular;

  @override
  Widget build(BuildContext context) {
    return MorrowlyMemoryStage(
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
              final posts = _store.visiblePosts(_filter);
              return LayoutBuilder(
                builder: (context, constraints) {
                  final side = MorrowlyFrameGuard.sideGutter(
                    constraints.maxWidth,
                    maxWidth: 430,
                    phoneGutter: 18,
                  );
                  return Stack(
                    children: [
                      SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          side,
                          MorrowlyFrameGuard.topClearance(
                            context,
                            minimum: 58,
                            extra: 10,
                          ),
                          side,
                          MorrowlyFrameGuard.bottomClearance(
                            context,
                            minimum: 150,
                            extra: 110,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _MemorySquareHeader(
                              signedInKeeper: _store.signedInKeeper,
                              onProfile: () =>
                                  _openProfile(_store.signedInKeeper),
                              onWallet: _openWallet,
                            ),
                            const SizedBox(height: 16),
                            _FeedFilterBar(
                              value: _filter,
                              onChanged: (value) {
                                setState(() => _filter = value);
                              },
                            ),
                            const SizedBox(height: 12),
                            if (posts.isEmpty)
                              const _EmptyFeedPanel()
                            else
                              for (final post in posts) ...[
                                _MemorySealCard(
                                  post: post,
                                  author: _store.keeperById(
                                    post.authorKeeperId,
                                  ),
                                  liked: _store.isPostLiked(post.sealId),
                                  glowCount: _store.visibleLikeCount(post),
                                  replyCount: _store.visibleReplyCount(post),
                                  followStatus: _store.followStatusFor(
                                    post.authorKeeperId,
                                  ),
                                  onOpen: () => _openPost(post),
                                  onAuthor: () => _openProfile(
                                    _store.keeperById(post.authorKeeperId),
                                  ),
                                  onFollow: () =>
                                      _requestFollow(post.authorKeeperId),
                                  onLike: () => _store.toggleLike(post.sealId),
                                  onComments: () =>
                                      _openPost(post, focusComposer: true),
                                  onMore: () => _showPostModeration(post),
                                ),
                                const SizedBox(height: 14),
                              ],
                          ],
                        ),
                      ),
                      Positioned(
                        right: side,
                        bottom: 136,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _openCompose,
                          child: Image.asset(
                            MorrowlyAssetKit.compose,
                            width: 58,
                            height: 58,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openCompose() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const MemoryReleaseScreen()),
    );
  }

  Future<void> _openPost(MemorySeal post, {bool focusComposer = false}) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MemorySealDetailScreen(
          sealId: post.sealId,
          focusComposer: focusComposer,
        ),
      ),
    );
  }

  Future<void> _openProfile(KeeperProfile user) async {
    if (user.belongsToSignedInKeeper) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (_) => const MemoryRibbonScreen()),
      );
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => KeeperHomeScreen(keeperId: user.keeperId),
      ),
    );
  }

  Future<void> _openWallet() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const MorrowlyWalletScreen()),
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

  Future<void> _showPostModeration(MemorySeal post) async {
    final result = await showMorrowlyModerationFlow(
      context: context,
      target: _store.moderationTargetForPost(post),
      onReport: (reason) => _store.reportPost(post, reason: reason),
      onBlock: () => _store.blockUser(post.authorKeeperId),
    );
    if (result != null && mounted) {
      setState(() {});
    }
  }
}

class _MemorySquareHeader extends StatelessWidget {
  const _MemorySquareHeader({
    required this.signedInKeeper,
    required this.onProfile,
    required this.onWallet,
  });

  final KeeperProfile signedInKeeper;
  final VoidCallback onProfile;
  final VoidCallback onWallet;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              'assets/morrowly_art/ui/morrowly_ui_dam.png',
              width: 117,
              height: 37,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
        MorrowlyCoinBalancePill(
          height: 28,
          iconSize: 15,
          fontSize: 11,
          horizontalPadding: 9,
          onTap: onWallet,
        ),
        const SizedBox(width: 10),
        KeeperAvatar(user: signedInKeeper, radius: 18, onTap: onProfile),
      ],
    );
  }
}

class _FeedFilterBar extends StatelessWidget {
  const _FeedFilterBar({required this.value, required this.onChanged});

  final MemoryShelfFilter value;
  final ValueChanged<MemoryShelfFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 252,
      height: 42,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF432C4D).withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: _FilterPill(
                  label: 'Popular',
                  selected: value == MemoryShelfFilter.popular,
                  onTap: () => onChanged(MemoryShelfFilter.popular),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _FilterPill(
                  label: 'Followed',
                  selected: value == MemoryShelfFilter.followed,
                  onTap: () => onChanged(MemoryShelfFilter.followed),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFC982FF), Color(0xFFAA5EFF)],
                )
              : null,
          color: selected ? null : const Color(0xFF4B3553),
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: lifePurple.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          style: TextStyle(
            color: selected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.44),
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}

class _MemorySealCard extends StatelessWidget {
  const _MemorySealCard({
    required this.post,
    required this.author,
    required this.liked,
    required this.glowCount,
    required this.replyCount,
    required this.followStatus,
    required this.onOpen,
    required this.onAuthor,
    required this.onFollow,
    required this.onLike,
    required this.onComments,
    required this.onMore,
  });

  final MemorySeal post;
  final KeeperProfile author;
  final bool liked;
  final int glowCount;
  final int replyCount;
  final KeeperLinkState followStatus;
  final VoidCallback onOpen;
  final VoidCallback onAuthor;
  final VoidCallback onFollow;
  final VoidCallback onLike;
  final VoidCallback onComments;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
        decoration: BoxDecoration(
          color: lifePanel.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                KeeperAvatar(user: author, radius: 23, onTap: onAuthor),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onAuthor,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFBD78FF),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!author.belongsToSignedInKeeper)
                  KeeperLinkButton(status: followStatus, onPressed: onFollow),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              post.noteLine,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.84),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (post.attachments.isNotEmpty) ...[
              const SizedBox(height: 12),
              _PostMediaGrid(attachments: post.attachments),
            ],
            const SizedBox(height: 11),
            Row(
              children: [
                _CountAction(
                  asset: MorrowlyAssetKit.comment,
                  count: replyCount,
                  onTap: onComments,
                ),
                const SizedBox(width: 24),
                _CountAction(
                  asset: liked
                      ? MorrowlyAssetKit.likeFilled
                      : MorrowlyAssetKit.likeOutline,
                  count: glowCount,
                  onTap: onLike,
                ),
                const Spacer(),
                MemoryGlyphButton(
                  asset: MorrowlyAssetKit.more,
                  onTap: onMore,
                  semanticLabel: 'Post actions',
                  size: 22,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PostMediaGrid extends StatelessWidget {
  const _PostMediaGrid({required this.attachments});

  final List<MemoryAttachment> attachments;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.28,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: MemoryAttachmentImage(attachment: attachments.first),
      ),
    );
  }
}

class _CountAction extends StatelessWidget {
  const _CountAction({
    required this.asset,
    required this.count,
    required this.onTap,
  });

  final String asset;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          Image.asset(
            asset,
            width: 20,
            height: 20,
            fit: BoxFit.contain,
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
      ),
    );
  }
}

class _EmptyFeedPanel extends StatelessWidget {
  const _EmptyFeedPanel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Center(
        child: Image.asset(
          MorrowlyAssetKit.empty,
          width: 188,
          height: 214,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
