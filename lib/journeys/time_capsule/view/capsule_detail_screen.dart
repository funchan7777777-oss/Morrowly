import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morrowly/journeys/present_grounding/data/keeper_memory_store.dart';
import 'package:morrowly/journeys/present_grounding/view/keeper_home_screen.dart';
import 'package:morrowly/journeys/time_capsule/data/capsule_square_seed.dart';
import 'package:morrowly/journeys/time_capsule/models/capsule_chronicle.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_stage.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_widgets.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';
import 'package:morrowly/shared/moderation/morrowly_content_safety.dart';
import 'package:morrowly/shared/moderation/morrowly_moderation_store.dart';
import 'package:morrowly/shared/widgets/morrowly_moderation_dialog.dart';
import 'package:morrowly/shared/widgets/morrowly_safety_notice.dart';

class CapsuleDetailScreen extends StatefulWidget {
  const CapsuleDetailScreen({
    super.key,
    required this.note,
    this.focusComposer = false,
    this.onNoteChanged,
  });

  final PublicCapsuleSeal note;
  final bool focusComposer;
  final ValueChanged<PublicCapsuleSeal>? onNoteChanged;

  @override
  State<CapsuleDetailScreen> createState() => _CapsuleDetailScreenState();
}

class _CapsuleDetailScreenState extends State<CapsuleDetailScreen> {
  late PublicCapsuleSeal _note = widget.note;
  late List<CapsuleReply> _replyTrail = [...widget.note.replies];
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final MorrowlyModerationStore _moderation = MorrowlyModerationStore.instance;
  final KeeperMemoryStore _lifeStore = KeeperMemoryStore.instance;
  String _commentDraft = '';

  @override
  void initState() {
    super.initState();
    _moderation.addListener(_refreshModeratedContent);
    _lifeStore.addListener(_refreshModeratedContent);
    _moderation.load();
    _lifeStore.load();
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
    _moderation.removeListener(_refreshModeratedContent);
    _lifeStore.removeListener(_refreshModeratedContent);
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleReplies = _visibleReplies;
    final visibleNote = _visibleNote(visibleReplies);
    return CapsuleStage(
      resizeForKeyboard: true,
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final contentWidth = MorrowlyFrameGuard.contentWidth(
                width,
                maxWidth: 430,
                phoneGutter: 18,
              );
              final side = (width - contentWidth) / 2;
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  side,
                  MorrowlyFrameGuard.topBarContentClearance(
                    context,
                    topMinimum: 38,
                    topExtra: -16,
                    topBarHeight: 42,
                    gap: 24,
                  ),
                  side,
                  MorrowlyFrameGuard.bottomClearance(
                    context,
                    minimum: 28,
                    extra: 18,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CapsuleDetailPanel(
                      note: visibleNote,
                      onKeeper: () => _openKeeperProfile(visibleNote.keeper),
                      onModerate: _canModerateKeeper(visibleNote.keeper)
                          ? _showNoteModeration
                          : null,
                    ),
                    const SizedBox(height: 18),
                    _CommentSectionHeader(note: visibleNote),
                    const SizedBox(height: 10),
                    if (visibleReplies.isEmpty)
                      const _EmptyCommentPanel()
                    else
                      for (final comment in visibleReplies) ...[
                        _CommentTile(
                          comment: comment,
                          onAuthor: () => _openKeeperProfile(comment.author),
                          onModerate: _canModerateKeeper(comment.author)
                              ? () => _showCommentModeration(comment)
                              : null,
                        ),
                        const SizedBox(height: 10),
                      ],
                    const SizedBox(height: 6),
                    _CommentComposer(
                      controller: _commentController,
                      focusNode: _commentFocusNode,
                      draft: _commentDraft,
                      currentKeeper: _currentKeeper,
                      onChanged: (value) {
                        setState(() => _commentDraft = value);
                      },
                      onSend: _sendComment,
                    ),
                  ],
                ),
              );
            },
          ),
          CapsuleTopBar(
            title: 'Capsule detail',
            onBack: () => Navigator.of(context).pop(),
            topMinimum: 38,
            topExtra: -16,
            height: 42,
          ),
        ],
      ),
    );
  }

  List<CapsuleReply> get _visibleReplies {
    return [
      for (final comment in _replyTrail)
        if (!_moderation.shouldHide(
          contentKey: comment.replyId,
          authorKeeperId: comment.author.keeperId,
        ))
          comment,
    ];
  }

  PublicCapsuleSeal _visibleNote(List<CapsuleReply> visibleReplies) {
    final hiddenReplyCount = _replyTrail.length - visibleReplies.length;
    final visibleReplyCount = _note.replyTrailCount - hiddenReplyCount;
    return _note.copyWith(
      replies: visibleReplies,
      replyTrailCount: visibleReplyCount < 0 ? 0 : visibleReplyCount,
      visitorTrail: [
        for (final keeper in _note.visitorTrail)
          if (!_moderation.isKeeperBlocked(keeper.keeperId)) keeper,
      ],
    );
  }

  bool _canModerateKeeper(CapsuleKeeper keeper) {
    return keeper.keeperId != CapsuleSquareSeed.currentKeeper.keeperId &&
        keeper.keeperId != _lifeStore.signedInKeeper.keeperId;
  }

  CapsuleKeeper get _currentKeeper {
    final user = _lifeStore.signedInKeeper;
    return CapsuleKeeper(
      keeperId: user.keeperId,
      publicName: user.publicName,
      ageMark: user.ageMark,
      homeRegion: user.homeRegion,
      signalBand: KeeperSignalBand.bloom,
      portraitAsset: user.portraitAsset,
      localPortraitPath: user.localPortraitPath,
    );
  }

  void _refreshModeratedContent() {
    if (mounted) {
      setState(() {});
    }
  }

  void _sendComment() {
    final message = _commentController.text.trim();
    if (message.isEmpty) {
      return;
    }
    try {
      MorrowlyContentSafety.ensureText(
        message,
        surface: MorrowlySafetySurface.comment,
      );
    } on MorrowlyContentSafetyException catch (issue) {
      unawaited(showMorrowlySafetyNotice(context, issue));
      return;
    }

    final comment = CapsuleReply(
      replyId: 'local-comment-${DateTime.now().microsecondsSinceEpoch}',
      author: _currentKeeper,
      sealedMessage: message,
      arrivalLabel: 'Just now',
    );
    final replies = [..._replyTrail, comment];
    final updatedNote = _note.copyWith(
      replies: replies,
      replyTrailCount: _note.replyTrailCount + 1,
    );

    setState(() {
      _replyTrail = replies;
      _note = updatedNote;
      _commentDraft = '';
      _commentController.clear();
    });
    widget.onNoteChanged?.call(updatedNote);
    _commentFocusNode.requestFocus();
  }

  Future<void> _openKeeperProfile(CapsuleKeeper keeper) {
    final keeperId = keeper.keeperId == CapsuleSquareSeed.currentKeeper.keeperId
        ? _lifeStore.signedInKeeper.keeperId
        : keeper.keeperId;
    return Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => KeeperHomeScreen(keeperId: keeperId)),
    );
  }

  Future<void> _showNoteModeration() async {
    final result = await showMorrowlyModerationFlow(
      context: context,
      store: _moderation,
      target: MorrowlyModerationTarget(
        contentKey: _note.sealId,
        authorKeeperId: _note.keeper.keeperId,
        authorName: _note.keeper.publicName,
        sourceKind: MorrowlyModerationKind.capsule,
      ),
    );
    if (result != null &&
        mounted &&
        _moderation.shouldHide(
          contentKey: _note.sealId,
          authorKeeperId: _note.keeper.keeperId,
        )) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _showCommentModeration(CapsuleReply comment) async {
    final result = await showMorrowlyModerationFlow(
      context: context,
      store: _moderation,
      target: MorrowlyModerationTarget(
        contentKey: comment.replyId,
        authorKeeperId: comment.author.keeperId,
        authorName: comment.author.publicName,
        sourceKind: MorrowlyModerationKind.comment,
      ),
    );
    if (result == null || !mounted) {
      return;
    }
    if (_moderation.shouldHide(
      contentKey: _note.sealId,
      authorKeeperId: _note.keeper.keeperId,
    )) {
      Navigator.of(context).pop();
    } else {
      setState(() {});
    }
  }
}

class _CapsuleDetailPanel extends StatelessWidget {
  const _CapsuleDetailPanel({
    required this.note,
    required this.onKeeper,
    this.onModerate,
  });

  final PublicCapsuleSeal note;
  final VoidCallback onKeeper;
  final VoidCallback? onModerate;

  @override
  Widget build(BuildContext context) {
    final previewSnap = note.memoryFragments.isEmpty
        ? null
        : note.memoryFragments.first;
    final openingLabel = note.canOpenNow
        ? 'Ready to open'
        : 'Opens ${capsuleDateStamp(note.unlocksAt)}';
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF4E3D54).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _KeeperHeader(
            keeper: note.keeper,
            onKeeper: onKeeper,
            onModerate: onModerate,
          ),
          const SizedBox(height: 16),
          Text(
            note.sealedMessage,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 15,
              height: 1.38,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (previewSnap != null) ...[
            const SizedBox(height: 16),
            _DetailMediaPreview(snap: previewSnap),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DetailChip(
                label: openingLabel,
                color: note.canOpenNow
                    ? const Color(0xFFFF6A6A)
                    : const Color(0xFFBBCDFF),
              ),
              _DetailChip(
                label: 'Sealed ${capsuleDateStamp(note.sealedAt)}',
                color: const Color(0xFFD6B7FF),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KeeperHeader extends StatelessWidget {
  const _KeeperHeader({
    required this.keeper,
    required this.onKeeper,
    this.onModerate,
  });

  final CapsuleKeeper keeper;
  final VoidCallback onKeeper;
  final VoidCallback? onModerate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onKeeper,
          child: CapsuleKeeperAvatar(keeper: keeper, radius: 25),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onKeeper,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  keeper.publicName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Image.asset(
                      keeper.signalBand == KeeperSignalBand.bloom
                          ? CapsuleArtwork.bloomMark
                          : CapsuleArtwork.museMark,
                      width: 15,
                      height: 15,
                      filterQuality: FilterQuality.high,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        '${keeper.ageMark} · ${keeper.homeRegion}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFBD88FF),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (onModerate != null) ...[
          const SizedBox(width: 10),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onModerate,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.more_horiz_rounded,
                color: Color(0xFF55415A),
                size: 19,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DetailMediaPreview extends StatelessWidget {
  const _DetailMediaPreview({required this.snap});

  final CapsuleMemoryFragment snap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CapsuleMediaTile(
            snap: snap,
            size: constraints.maxWidth,
            showMotionIndicator: false,
          );
        },
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF7557A4),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CommentSectionHeader extends StatelessWidget {
  const _CommentSectionHeader({required this.note});

  final PublicCapsuleSeal note;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Comments',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '${note.replyTrailCount} total',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.74),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.onAuthor,
    this.onModerate,
  });

  final CapsuleReply comment;
  final VoidCallback onAuthor;
  final VoidCallback? onModerate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 13),
      decoration: BoxDecoration(
        color: const Color(0xFF3F3145).withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onAuthor,
            child: CapsuleKeeperAvatar(keeper: comment.author, radius: 18),
          ),
          const SizedBox(width: 10),
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
                          comment.author.publicName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.arrivalLabel,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.36),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.sealedMessage,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 12,
                    height: 1.36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (onModerate != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onModerate,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: Colors.white.withValues(alpha: 0.66),
                  size: 17,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyCommentPanel extends StatelessWidget {
  const _EmptyCommentPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF3F3145).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Text(
        'No capsule notes have landed yet. Leave the first mark for this seal.',
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

class _CommentComposer extends StatelessWidget {
  const _CommentComposer({
    required this.controller,
    required this.focusNode,
    required this.draft,
    required this.currentKeeper,
    required this.onChanged,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String draft;
  final CapsuleKeeper currentKeeper;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final canSend = draft.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF35293A).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: CapsuleKeeperAvatar(keeper: currentKeeper, radius: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              minLines: 1,
              maxLines: 4,
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
                hintText: 'Write a comment...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.34),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: canSend ? onSend : null,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 140),
              opacity: canSend ? 1 : 0.34,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFBC6DFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
