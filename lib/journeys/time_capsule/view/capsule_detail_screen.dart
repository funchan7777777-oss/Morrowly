import 'package:flutter/material.dart';
import 'package:morrowly/journeys/time_capsule/data/capsule_square_seed.dart';
import 'package:morrowly/journeys/time_capsule/models/capsule_chronicle.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_stage.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_widgets.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';
import 'package:morrowly/shared/moderation/morrowly_moderation_store.dart';
import 'package:morrowly/shared/widgets/morrowly_moderation_dialog.dart';

class CapsuleDetailScreen extends StatefulWidget {
  const CapsuleDetailScreen({
    super.key,
    required this.note,
    this.focusComposer = false,
    this.onNoteChanged,
  });

  final CapsuleSquareNote note;
  final bool focusComposer;
  final ValueChanged<CapsuleSquareNote>? onNoteChanged;

  @override
  State<CapsuleDetailScreen> createState() => _CapsuleDetailScreenState();
}

class _CapsuleDetailScreenState extends State<CapsuleDetailScreen> {
  late CapsuleSquareNote _note = widget.note;
  late List<CapsuleSquareComment> _comments = [...widget.note.comments];
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final MorrowlyModerationStore _moderation = MorrowlyModerationStore.instance;
  String _commentDraft = '';

  @override
  void initState() {
    super.initState();
    _moderation.addListener(_refreshModeratedContent);
    _moderation.load();
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
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleComments = _visibleComments;
    final visibleNote = _visibleNote(visibleComments);
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
                  MorrowlyFrameGuard.topClearance(
                    context,
                    minimum: 96,
                    extra: 22,
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
                      onModerate: _canModerateKeeper(visibleNote.keeper)
                          ? _showNoteModeration
                          : null,
                    ),
                    const SizedBox(height: 18),
                    _CommentSectionHeader(note: visibleNote),
                    const SizedBox(height: 10),
                    if (visibleComments.isEmpty)
                      const _EmptyCommentPanel()
                    else
                      for (final comment in visibleComments) ...[
                        _CommentTile(
                          comment: comment,
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
          ),
        ],
      ),
    );
  }

  List<CapsuleSquareComment> get _visibleComments {
    return [
      for (final comment in _comments)
        if (!_moderation.shouldHide(
          contentKey: comment.commentKey,
          authorKey: comment.author.keeperKey,
        ))
          comment,
    ];
  }

  CapsuleSquareNote _visibleNote(List<CapsuleSquareComment> visibleComments) {
    final hiddenCommentCount = _comments.length - visibleComments.length;
    final visibleMessageCount = _note.leftMessageCount - hiddenCommentCount;
    return _note.copyWith(
      comments: visibleComments,
      leftMessageCount: visibleMessageCount < 0 ? 0 : visibleMessageCount,
      visitorTrail: [
        for (final keeper in _note.visitorTrail)
          if (!_moderation.isAuthorBlocked(keeper.keeperKey)) keeper,
      ],
    );
  }

  bool _canModerateKeeper(CapsuleKeeper keeper) {
    return keeper.keeperKey != CapsuleSquareSeed.currentKeeper.keeperKey;
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

    final comment = CapsuleSquareComment(
      commentKey: 'local-comment-${DateTime.now().microsecondsSinceEpoch}',
      author: CapsuleSquareSeed.currentKeeper,
      messageLine: message,
      timeAgoLine: 'Just now',
    );
    final comments = [..._comments, comment];
    final updatedNote = _note.copyWith(
      comments: comments,
      leftMessageCount: _note.leftMessageCount + 1,
    );

    setState(() {
      _comments = comments;
      _note = updatedNote;
      _commentDraft = '';
      _commentController.clear();
    });
    widget.onNoteChanged?.call(updatedNote);
    _commentFocusNode.requestFocus();
  }

  Future<void> _showNoteModeration() async {
    final result = await showMorrowlyModerationFlow(
      context: context,
      store: _moderation,
      target: MorrowlyModerationTarget(
        contentKey: _note.noteKey,
        authorKey: _note.keeper.keeperKey,
        authorName: _note.keeper.displayName,
        kind: MorrowlyModerationKind.capsule,
      ),
    );
    if (result != null &&
        mounted &&
        _moderation.shouldHide(
          contentKey: _note.noteKey,
          authorKey: _note.keeper.keeperKey,
        )) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _showCommentModeration(CapsuleSquareComment comment) async {
    final result = await showMorrowlyModerationFlow(
      context: context,
      store: _moderation,
      target: MorrowlyModerationTarget(
        contentKey: comment.commentKey,
        authorKey: comment.author.keeperKey,
        authorName: comment.author.displayName,
        kind: MorrowlyModerationKind.comment,
      ),
    );
    if (result == null || !mounted) {
      return;
    }
    if (_moderation.shouldHide(
      contentKey: _note.noteKey,
      authorKey: _note.keeper.keeperKey,
    )) {
      Navigator.of(context).pop();
    } else {
      setState(() {});
    }
  }
}

class _CapsuleDetailPanel extends StatelessWidget {
  const _CapsuleDetailPanel({required this.note, this.onModerate});

  final CapsuleSquareNote note;
  final VoidCallback? onModerate;

  @override
  Widget build(BuildContext context) {
    final openingLabel = note.canOpenNow
        ? 'Ready to open'
        : 'Opens ${capsuleDateStamp(note.openingAt)}';
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
          _KeeperHeader(keeper: note.keeper, onModerate: onModerate),
          const SizedBox(height: 16),
          Text(
            note.messageLine,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 15,
              height: 1.38,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (note.mediaSnaps.isNotEmpty) ...[
            const SizedBox(height: 16),
            _DetailMediaGallery(snaps: note.mediaSnaps),
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
  const _KeeperHeader({required this.keeper, this.onModerate});

  final CapsuleKeeper keeper;
  final VoidCallback? onModerate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage(keeper.avatarAsset),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                keeper.displayName,
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
                      '${keeper.ageLine} · ${keeper.placeLine}',
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

class _DetailMediaGallery extends StatelessWidget {
  const _DetailMediaGallery({required this.snaps});

  final List<CapsuleMediaSnap> snaps;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSingle = snaps.length == 1;
        final tileSize = isSingle
            ? constraints.maxWidth
            : ((constraints.maxWidth - 10) / 2).clamp(0.0, 220.0);
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final snap in snaps)
              CapsuleMediaTile(
                snap: snap,
                size: tileSize.toDouble(),
                showMotionIndicator: false,
              ),
          ],
        );
      },
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

  final CapsuleSquareNote note;

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
            '${note.leftMessageCount} total',
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
  const _CommentTile({required this.comment, this.onModerate});

  final CapsuleSquareComment comment;
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
          CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage(comment.author.avatarAsset),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.author.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.timeAgoLine,
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
                  comment.messageLine,
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
        'No comments yet. Leave the first one for this capsule.',
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
            child: CircleAvatar(
              radius: 17,
              backgroundImage: AssetImage(
                CapsuleSquareSeed.currentKeeper.avatarAsset,
              ),
              backgroundColor: Colors.white.withValues(alpha: 0.14),
            ),
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
