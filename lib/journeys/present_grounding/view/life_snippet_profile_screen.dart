import 'package:flutter/material.dart';
import 'package:morrowly/journeys/present_grounding/data/life_snippet_store.dart';
import 'package:morrowly/journeys/present_grounding/models/life_snippet_models.dart';
import 'package:morrowly/journeys/present_grounding/view/life_snippet_chat_screen.dart';
import 'package:morrowly/journeys/present_grounding/view/life_snippet_detail_screen.dart';
import 'package:morrowly/journeys/present_grounding/widgets/life_snippet_widgets.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';

class LifeSnippetProfileScreen extends StatefulWidget {
  const LifeSnippetProfileScreen({super.key, required this.userKey});

  final String userKey;

  @override
  State<LifeSnippetProfileScreen> createState() =>
      _LifeSnippetProfileScreenState();
}

class _LifeSnippetProfileScreenState extends State<LifeSnippetProfileScreen> {
  final LifeSnippetStore _store = LifeSnippetStore.instance;

  @override
  Widget build(BuildContext context) {
    return LifeSnippetStage(
      child: AnimatedBuilder(
        animation: _store,
        builder: (context, _) {
          final user = _store.userByKey(widget.userKey);
          final posts = _store.postsForUser(user.userKey);
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
                      MorrowlyFrameGuard.topClearance(
                        context,
                        minimum: 94,
                        extra: 26,
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
                          followStatus: _store.followStatusFor(user.userKey),
                          onFollow: () => _requestFollow(user.userKey),
                          onChat: user.isCurrentUser
                              ? null
                              : () => _openChat(user.userKey),
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
                          _EmptyProfilePosts(isCurrentUser: user.isCurrentUser)
                        else
                          for (final post in posts) ...[
                            _ProfilePostCard(
                              post: post,
                              author: user,
                              commentCount: _store.visibleCommentCount(post),
                              likeCount: _store.visibleLikeCount(post),
                              liked: _store.isPostLiked(post.postKey),
                              followStatus: _store.followStatusFor(
                                user.userKey,
                              ),
                              onOpen: () => _openPost(post.postKey),
                              onFollow: () => _requestFollow(user.userKey),
                              onLike: () => _store.toggleLike(post.postKey),
                            ),
                            const SizedBox(height: 14),
                          ],
                      ],
                    ),
                  );
                },
              ),
              LifeTopBar(
                title: 'User home',
                onBack: () => Navigator.of(context).pop(),
                trailing: IconButton(
                  onPressed: user.isCurrentUser
                      ? null
                      : () => _showUserModeration(user.userKey),
                  icon: Icon(
                    Icons.info_rounded,
                    color: user.isCurrentUser
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

  Future<void> _openChat(String userKey) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => LifeSnippetChatScreen(userKey: userKey),
      ),
    );
  }

  Future<void> _openPost(String postKey) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => LifeSnippetDetailScreen(postKey: postKey),
      ),
    );
  }

  Future<void> _showUserModeration(String userKey) {
    return showLifeModerationSheet(
      context: context,
      onReport: () => _store.reportUser(userKey),
      onBlock: () => _store.blockUser(userKey),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.followStatus,
    required this.onFollow,
    required this.onChat,
  });

  final LifeSnippetUser user;
  final LifeFollowStatus followStatus;
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
            LifeAvatar(user: user, radius: 36),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (!user.isCurrentUser)
                        LifeFollowButton(
                          status: followStatus,
                          onPressed: onFollow,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.regionLine,
                    style: const TextStyle(
                      color: Color(0xFFBD78FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user.signatureLine,
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
            _ProfileStat(value: user.followCount, label: 'Follow'),
            _ProfileStat(value: user.fansCount, label: 'Fans'),
            _ProfileStat(value: user.likeCount, label: 'Get likes'),
            _ProfileStat(value: user.capsuleCount, label: 'Capsule'),
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
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.28),
            fontSize: 10,
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
    required this.commentCount,
    required this.likeCount,
    required this.liked,
    required this.followStatus,
    required this.onOpen,
    required this.onFollow,
    required this.onLike,
  });

  final LifeSnippetPost post;
  final LifeSnippetUser author;
  final int commentCount;
  final int likeCount;
  final bool liked;
  final LifeFollowStatus followStatus;
  final VoidCallback onOpen;
  final VoidCallback onFollow;
  final VoidCallback onLike;

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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                LifeAvatar(user: author, radius: 22),
                const SizedBox(width: 10),
                Expanded(
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
                        style: const TextStyle(
                          color: Color(0xFFBD78FF),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!author.isCurrentUser)
                  LifeFollowButton(status: followStatus, onPressed: onFollow),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (post.media.isNotEmpty) ...[
              const SizedBox(height: 12),
              AspectRatio(
                aspectRatio: 1.28,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LifeMediaImage(media: post.media.first),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                _ActionCount(
                  asset: LifeSnippetAssets.comment,
                  count: commentCount,
                ),
                const SizedBox(width: 24),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onLike,
                  child: _ActionCount(
                    asset: liked
                        ? LifeSnippetAssets.likeFilled
                        : LifeSnippetAssets.likeOutline,
                    count: likeCount,
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
  const _EmptyProfilePosts({required this.isCurrentUser});

  final bool isCurrentUser;

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
        isCurrentUser
            ? 'Your submitted snippets wait for moderation before they appear here.'
            : 'No visible posts from this user.',
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
