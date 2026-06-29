import 'package:flutter/material.dart';
import 'package:morrowly/journeys/present_grounding/data/life_snippet_store.dart';
import 'package:morrowly/journeys/present_grounding/models/life_snippet_models.dart';
import 'package:morrowly/journeys/present_grounding/view/life_snippet_compose_screen.dart';
import 'package:morrowly/journeys/present_grounding/view/life_snippet_detail_screen.dart';
import 'package:morrowly/journeys/present_grounding/view/life_snippet_profile_screen.dart';
import 'package:morrowly/journeys/present_grounding/widgets/life_snippet_widgets.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';
import 'package:morrowly/shared/widgets/morrowly_moderation_dialog.dart';

class PresentGroundingScreen extends StatefulWidget {
  const PresentGroundingScreen({super.key});

  @override
  State<PresentGroundingScreen> createState() => _PresentGroundingScreenState();
}

class _PresentGroundingScreenState extends State<PresentGroundingScreen> {
  final LifeSnippetStore _store = LifeSnippetStore.instance;
  late final Future<void> _loadFuture = _store.load();
  LifeSnippetFeedFilter _filter = LifeSnippetFeedFilter.popular;

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
              final posts = _store.visiblePosts(_filter);
              return Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final side = MorrowlyFrameGuard.sideGutter(
                        constraints.maxWidth,
                        maxWidth: 430,
                        phoneGutter: 18,
                      );
                      return SingleChildScrollView(
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
                            _LifeHeader(
                              currentUser: _store.currentUser,
                              onProfile: () => _openProfile(_store.currentUser),
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
                              _EmptyFeedPanel(filter: _filter)
                            else
                              for (final post in posts) ...[
                                _LifePostCard(
                                  post: post,
                                  author: _store.userByKey(post.authorKey),
                                  liked: _store.isPostLiked(post.postKey),
                                  likeCount: _store.visibleLikeCount(post),
                                  commentCount: _store.visibleCommentCount(
                                    post,
                                  ),
                                  followStatus: _store.followStatusFor(
                                    post.authorKey,
                                  ),
                                  onOpen: () => _openPost(post),
                                  onAuthor: () => _openProfile(
                                    _store.userByKey(post.authorKey),
                                  ),
                                  onFollow: () =>
                                      _requestFollow(post.authorKey),
                                  onLike: () => _store.toggleLike(post.postKey),
                                  onComments: () =>
                                      _openPost(post, focusComposer: true),
                                  onMore: () => _showPostModeration(post),
                                ),
                                const SizedBox(height: 14),
                              ],
                          ],
                        ),
                      );
                    },
                  ),
                  Positioned(
                    right: 18,
                    bottom: 136,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _openCompose,
                      child: Image.asset(
                        LifeSnippetAssets.compose,
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
      ),
    );
  }

  Future<void> _openCompose() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const LifeSnippetComposeScreen()),
    );
  }

  Future<void> _openPost(
    LifeSnippetPost post, {
    bool focusComposer = false,
  }) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => LifeSnippetDetailScreen(
          postKey: post.postKey,
          focusComposer: focusComposer,
        ),
      ),
    );
  }

  Future<void> _openProfile(LifeSnippetUser user) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => LifeSnippetProfileScreen(userKey: user.userKey),
      ),
    );
  }

  Future<void> _requestFollow(String userKey) async {
    await _store.requestFollow(userKey);
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

  Future<void> _showPostModeration(LifeSnippetPost post) async {
    final result = await showMorrowlyModerationFlow(
      context: context,
      target: _store.moderationTargetForPost(post),
      onReport: (reason) => _store.reportPost(post, reason: reason),
      onBlock: () => _store.blockUser(post.authorKey),
    );
    if (result != null && mounted) {
      setState(() {});
    }
  }
}

class _LifeHeader extends StatelessWidget {
  const _LifeHeader({required this.currentUser, required this.onProfile});

  final LifeSnippetUser currentUser;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              'assets/images/Dam.png',
              width: 117,
              height: 37,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
        Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/images/Capsule.png',
                width: 15,
                height: 15,
                filterQuality: FilterQuality.high,
              ),
              const SizedBox(width: 4),
              const Text(
                '123,45',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        LifeAvatar(user: currentUser, radius: 18, onTap: onProfile),
      ],
    );
  }
}

class _FeedFilterBar extends StatelessWidget {
  const _FeedFilterBar({required this.value, required this.onChanged});

  final LifeSnippetFeedFilter value;
  final ValueChanged<LifeSnippetFeedFilter> onChanged;

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
                  selected: value == LifeSnippetFeedFilter.popular,
                  onTap: () => onChanged(LifeSnippetFeedFilter.popular),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _FilterPill(
                  label: 'Followed',
                  selected: value == LifeSnippetFeedFilter.followed,
                  onTap: () => onChanged(LifeSnippetFeedFilter.followed),
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

class _LifePostCard extends StatelessWidget {
  const _LifePostCard({
    required this.post,
    required this.author,
    required this.liked,
    required this.likeCount,
    required this.commentCount,
    required this.followStatus,
    required this.onOpen,
    required this.onAuthor,
    required this.onFollow,
    required this.onLike,
    required this.onComments,
    required this.onMore,
  });

  final LifeSnippetPost post;
  final LifeSnippetUser author;
  final bool liked;
  final int likeCount;
  final int commentCount;
  final LifeFollowStatus followStatus;
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
                LifeAvatar(user: author, radius: 23, onTap: onAuthor),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onAuthor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          author.displayName,
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
                          author.regionLine,
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
                if (!author.isCurrentUser)
                  LifeFollowButton(status: followStatus, onPressed: onFollow),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              post.body,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.84),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (post.media.isNotEmpty) ...[
              const SizedBox(height: 12),
              _PostMediaGrid(media: post.media),
            ],
            const SizedBox(height: 11),
            Row(
              children: [
                _CountAction(
                  asset: LifeSnippetAssets.comment,
                  count: commentCount,
                  onTap: onComments,
                ),
                const SizedBox(width: 24),
                _CountAction(
                  asset: liked
                      ? LifeSnippetAssets.likeFilled
                      : LifeSnippetAssets.likeOutline,
                  count: likeCount,
                  onTap: onLike,
                ),
                const Spacer(),
                LifeIconAssetButton(
                  asset: LifeSnippetAssets.more,
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
  const _PostMediaGrid({required this.media});

  final List<LifeSnippetMedia> media;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.28,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: LifeMediaImage(media: media.first),
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
  const _EmptyFeedPanel({required this.filter});

  final LifeSnippetFeedFilter filter;

  @override
  Widget build(BuildContext context) {
    final followed = filter == LifeSnippetFeedFilter.followed;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
      decoration: BoxDecoration(
        color: lifePanel.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Image.asset(
            followed ? LifeSnippetAssets.followIcon : LifeSnippetAssets.compose,
            width: 62,
            height: 62,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(height: 12),
          Text(
            followed
                ? 'No approved follows yet'
                : 'No visible snippets right now',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            followed
                ? 'Follow requests wait for the other person to approve before their posts move here.'
                : 'New posts appear only after moderation approves them.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.56),
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
