import 'package:flutter/material.dart';
import 'package:morrowly/journeys/present_grounding/data/keeper_memory_store.dart';
import 'package:morrowly/journeys/present_grounding/models/keeper_memory_thread.dart';
import 'package:morrowly/journeys/present_grounding/view/keeper_home_screen.dart';
import 'package:morrowly/journeys/present_grounding/widgets/keeper_memory_widgets.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';
import 'package:morrowly/shared/moderation/morrowly_content_safety.dart';
import 'package:morrowly/shared/widgets/morrowly_moderation_dialog.dart';
import 'package:morrowly/shared/widgets/morrowly_safety_notice.dart';

class MemorySealDetailScreen extends StatefulWidget {
  const MemorySealDetailScreen({
    super.key,
    required this.sealId,
    this.focusComposer = false,
  });

  final String sealId;
  final bool focusComposer;

  @override
  State<MemorySealDetailScreen> createState() => _MemorySealDetailScreenState();
}

class _MemorySealDetailScreenState extends State<MemorySealDetailScreen> {
  final KeeperMemoryStore _store = KeeperMemoryStore.instance;
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
    return MorrowlyMemoryStage(
      resizeForKeyboard: true,
      child: AnimatedBuilder(
        animation: _store,
        builder: (context, _) {
          final post = _store.sealById(widget.sealId);
          if (post == null) {
            return const Center(
              child: Text(
                'This memory seal is no longer available.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final author = _store.keeperById(post.authorKeeperId);
          final replies = _store.repliesForSeal(post.sealId);
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
                      MorrowlyFrameGuard.topBarContentClearance(
                        context,
                        topMinimum: 50,
                        topExtra: 4,
                        topBarHeight: 52,
                        gap: 20,
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
                          followStatus: _store.followStatusFor(author.keeperId),
                          onAuthor: () => _openProfile(author.keeperId),
                          onFollow: () => _requestFollow(author.keeperId),
                        ),
                        const SizedBox(height: 12),
                        _MemorySealHeroCard(
                          post: post,
                          glowCount: _store.visibleLikeCount(post),
                          liked: _store.isPostLiked(post.sealId),
                          replyCount: _store.visibleReplyCount(post),
                          onLike: () => _store.toggleLike(post.sealId),
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
                        if (replies.isEmpty)
                          const _EmptyComments()
                        else
                          for (final reply in replies) ...[
                            _CommentTile(
                              comment: reply,
                              author: _store.keeperById(reply.authorKeeperId),
                              onAuthor: () =>
                                  _openProfile(reply.authorKeeperId),
                              onMore: () => _showCommentModeration(reply),
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
                      onSend: () => _sendComment(post.sealId),
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

  Future<void> _openProfile(String keeperId) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => KeeperHomeScreen(keeperId: keeperId)),
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

  Future<void> _sendComment(String sealId) async {
    try {
      await _store.addComment(sealId: sealId, replyText: _commentDraft);
    } on MorrowlyContentSafetyException catch (issue) {
      if (mounted) {
        await showMorrowlySafetyNotice(context, issue);
      }
      return;
    }
    _commentController.clear();
    setState(() => _commentDraft = '');
    _commentFocusNode.requestFocus();
  }

  Future<void> _showPostModeration(MemorySeal post) async {
    final result = await showMorrowlyModerationFlow(
      context: context,
      target: _store.moderationTargetForPost(post),
      onReport: (reason) => _store.reportPost(post, reason: reason),
      onBlock: () => _store.blockUser(post.authorKeeperId),
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

  Future<void> _showCommentModeration(MemoryReplyNote comment) async {
    final result = await showMorrowlyModerationFlow(
      context: context,
      target: _store.moderationTargetForComment(comment),
      onReport: (reason) => _store.reportComment(comment, reason: reason),
      onBlock: () => _store.blockUser(comment.authorKeeperId),
    );
    if (result == null || !mounted) {
      return;
    }
    if (_store.sealById(widget.sealId) == null) {
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
                    'Memory seal',
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

  final KeeperProfile author;
  final KeeperLinkState followStatus;
  final VoidCallback onAuthor;
  final VoidCallback onFollow;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        KeeperAvatar(user: author, radius: 22, onTap: onAuthor),
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
    );
  }
}

class _MemorySealHeroCard extends StatelessWidget {
  const _MemorySealHeroCard({
    required this.post,
    required this.glowCount,
    required this.liked,
    required this.replyCount,
    required this.onLike,
  });

  final MemorySeal post;
  final int glowCount;
  final bool liked;
  final int replyCount;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final cover = post.attachments.isEmpty ? null : post.attachments.first;
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
                  MemoryAttachmentImage(attachment: cover)
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
                            _dateLabel(post.sealedAt),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Image.asset(
                            MorrowlyAssetKit.likeFilled,
                            width: 17,
                            height: 17,
                            filterQuality: FilterQuality.high,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        post.noteLine,
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
                  asset: MorrowlyAssetKit.comment,
                  count: replyCount,
                ),
                const SizedBox(width: 24),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onLike,
                  child: _CountInline(
                    asset: liked
                        ? MorrowlyAssetKit.likeFilled
                        : MorrowlyAssetKit.likeOutline,
                    count: glowCount,
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

  final MemoryReplyNote comment;
  final KeeperProfile author;
  final VoidCallback onAuthor;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KeeperAvatar(user: author, radius: 15, onTap: onAuthor),
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
                        author.publicName,
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
                    _clockLabel(comment.pennedAt),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.32),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  MemoryGlyphButton(
                    asset: MorrowlyAssetKit.more,
                    onTap: onMore,
                    semanticLabel: 'Comment actions',
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                comment.noteLine,
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
                hintText: 'Leave a capsule note',
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
                MorrowlyAssetKit.send,
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
        'No capsule notes have settled here yet.',
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
