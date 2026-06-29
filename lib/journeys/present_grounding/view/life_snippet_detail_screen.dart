import 'package:flutter/material.dart';
import 'package:morrowly/journeys/present_grounding/data/life_snippet_store.dart';
import 'package:morrowly/journeys/present_grounding/models/life_snippet_models.dart';
import 'package:morrowly/journeys/present_grounding/view/life_snippet_profile_screen.dart';
import 'package:morrowly/journeys/present_grounding/widgets/life_snippet_widgets.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';
import 'package:morrowly/shared/widgets/morrowly_moderation_dialog.dart';

class LifeSnippetDetailScreen extends StatefulWidget {
  const LifeSnippetDetailScreen({
    super.key,
    required this.postKey,
    this.focusComposer = false,
  });

  final String postKey;
  final bool focusComposer;

  @override
  State<LifeSnippetDetailScreen> createState() =>
      _LifeSnippetDetailScreenState();
}

class _LifeSnippetDetailScreenState extends State<LifeSnippetDetailScreen> {
  final LifeSnippetStore _store = LifeSnippetStore.instance;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  String _commentDraft = '';

  @override
  void initState() {
    super.initState();
    if (widget.focusComposer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _commentFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LifeSnippetStage(
      resizeForKeyboard: true,
      child: AnimatedBuilder(
        animation: _store,
        builder: (context, _) {
          final post = _store.postByKey(widget.postKey);
          if (post == null) {
            return const Center(
              child: Text(
                'This snippet is no longer available.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final author = _store.userByKey(post.authorKey);
          final comments = _store.commentsForPost(post.postKey);
          return Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final contentWidth = MorrowlyFrameGuard.contentWidth(
                    constraints.maxWidth,
                    maxWidth: 430,
                    phoneGutter: 16,
                  );
                  final side = (constraints.maxWidth - contentWidth) / 2;
                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      side,
                      MorrowlyFrameGuard.topClearance(
                        context,
                        minimum: 128,
                        extra: 72,
                      ),
                      side,
                      MorrowlyFrameGuard.bottomClearance(
                        context,
                        minimum: 96,
                        extra: 58,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailAuthorHeader(
                          author: author,
                          followStatus: _store.followStatusFor(author.userKey),
                          onAuthor: () => _openProfile(author.userKey),
                          onFollow: () => _requestFollow(author.userKey),
                        ),
                        const SizedBox(height: 12),
                        _HeroSnippetCard(
                          post: post,
                          likeCount: _store.visibleLikeCount(post),
                          liked: _store.isPostLiked(post.postKey),
                          commentCount: _store.visibleCommentCount(post),
                          onLike: () => _store.toggleLike(post.postKey),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          "Let's discuss together",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (comments.isEmpty)
                          const _EmptyComments()
                        else
                          for (final comment in comments) ...[
                            _CommentTile(
                              comment: comment,
                              author: _store.userByKey(comment.authorKey),
                              onAuthor: () => _openProfile(comment.authorKey),
                              onMore: () => _showCommentModeration(comment),
                            ),
                            const SizedBox(height: 10),
                          ],
                      ],
                    ),
                  );
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                    child: _CommentComposer(
                      controller: _commentController,
                      focusNode: _commentFocusNode,
                      draft: _commentDraft,
                      onChanged: (value) {
                        setState(() => _commentDraft = value);
                      },
                      onSend: () => _sendComment(post.postKey),
                    ),
                  ),
                ),
              ),
              _DetailTopBar(
                onBack: () => Navigator.of(context).pop(),
                onMore: () => _showPostModeration(post),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openProfile(String userKey) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => LifeSnippetProfileScreen(userKey: userKey),
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

  Future<void> _sendComment(String postKey) async {
    await _store.addComment(postKey: postKey, body: _commentDraft);
    _commentController.clear();
    setState(() => _commentDraft = '');
    _commentFocusNode.requestFocus();
  }

  Future<void> _showPostModeration(LifeSnippetPost post) async {
    final result = await showMorrowlyModerationFlow(
      context: context,
      target: _store.moderationTargetForPost(post),
      onReport: (reason) => _store.reportPost(post, reason: reason),
      onBlock: () => _store.blockUser(post.authorKey),
    );
    if (result == null || !mounted) {
      return;
    }
    if (_store.shouldHidePost(post)) {
      Navigator.of(context).pop();
    } else {
      setState(() {});
    }
  }

  Future<void> _showCommentModeration(LifeSnippetComment comment) async {
    final result = await showMorrowlyModerationFlow(
      context: context,
      target: _store.moderationTargetForComment(comment),
      onReport: (reason) => _store.reportComment(comment, reason: reason),
      onBlock: () => _store.blockUser(comment.authorKey),
    );
    if (result == null || !mounted) {
      return;
    }
    if (_store.postByKey(widget.postKey) == null) {
      Navigator.of(context).pop();
    } else {
      setState(() {});
    }
  }
}

class _DetailTopBar extends StatelessWidget {
  const _DetailTopBar({required this.onBack, required this.onMore});

  final VoidCallback onBack;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = MorrowlyFrameGuard.contentWidth(
          constraints.maxWidth,
          maxWidth: 430,
          phoneGutter: 16,
        );
        final side = (constraints.maxWidth - contentWidth) / 2;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            side,
            MorrowlyFrameGuard.topClearance(context, minimum: 50, extra: 4),
            side,
            0,
          ),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF4D3658).withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                _DetailTopAction(
                  icon: Icons.chevron_left_rounded,
                  tooltip: 'Back',
                  onTap: onBack,
                ),
                const Expanded(
                  child: Text(
                    'Snippet details',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _DetailTopAction(
                  icon: Icons.more_horiz_rounded,
                  tooltip: 'Report or block',
                  onTap: onMore,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailTopAction extends StatelessWidget {
  const _DetailTopAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 25),
        ),
      ),
    );
  }
}

class _DetailAuthorHeader extends StatelessWidget {
  const _DetailAuthorHeader({
    required this.author,
    required this.followStatus,
    required this.onAuthor,
    required this.onFollow,
  });

  final LifeSnippetUser author;
  final LifeFollowStatus followStatus;
  final VoidCallback onAuthor;
  final VoidCallback onFollow;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LifeAvatar(user: author, radius: 22, onTap: onAuthor),
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
    );
  }
}

class _HeroSnippetCard extends StatelessWidget {
  const _HeroSnippetCard({
    required this.post,
    required this.likeCount,
    required this.liked,
    required this.commentCount,
    required this.onLike,
  });

  final LifeSnippetPost post;
  final int likeCount;
  final bool liked;
  final int commentCount;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final cover = post.media.isEmpty ? null : post.media.first;
    return Container(
      decoration: BoxDecoration(
        color: lifePanel.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (cover != null)
                  LifeMediaImage(media: cover)
                else
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: lifePanelSoft,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          lifePurple.withValues(alpha: 0.44),
                          lifePanelSoft,
                        ],
                      ),
                    ),
                  ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.52),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _dateLabel(post.createdAt),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Image.asset(
                            LifeSnippetAssets.likeFilled,
                            width: 17,
                            height: 17,
                            filterQuality: FilterQuality.high,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        post.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(
              children: [
                _CountInline(
                  asset: LifeSnippetAssets.comment,
                  count: commentCount,
                ),
                const SizedBox(width: 24),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onLike,
                  child: _CountInline(
                    asset: liked
                        ? LifeSnippetAssets.likeFilled
                        : LifeSnippetAssets.likeOutline,
                    count: likeCount,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.author,
    required this.onAuthor,
    required this.onMore,
  });

  final LifeSnippetComment comment;
  final LifeSnippetUser author;
  final VoidCallback onAuthor;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LifeAvatar(user: author, radius: 15, onTap: onAuthor),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onAuthor,
                      child: Text(
                        author.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    _clockLabel(comment.createdAt),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.32),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  LifeIconAssetButton(
                    asset: LifeSnippetAssets.more,
                    onTap: onMore,
                    semanticLabel: 'Comment actions',
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                comment.body,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.74),
                  fontSize: 12,
                  height: 1.32,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentComposer extends StatelessWidget {
  const _CommentComposer({
    required this.controller,
    required this.focusNode,
    required this.draft,
    required this.onChanged,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String draft;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final canSend = draft.trim().isNotEmpty;
    return Container(
      height: 44,
      padding: const EdgeInsets.fromLTRB(14, 0, 6, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF352738).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              onSubmitted: (_) {
                if (canSend) {
                  onSend();
                }
              },
              textInputAction: TextInputAction.send,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: 'Please enter',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.28),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: canSend ? onSend : null,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 140),
              opacity: canSend ? 1 : 0.38,
              child: Image.asset(
                LifeSnippetAssets.send,
                width: 36,
                height: 36,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountInline extends StatelessWidget {
  const _CountInline({required this.asset, required this.count});

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

class _EmptyComments extends StatelessWidget {
  const _EmptyComments();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lifePanel.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'No visible comments yet.',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.58),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _dateLabel(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '${value.year}/$month/$day $hour:$minute';
}

String _clockLabel(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
