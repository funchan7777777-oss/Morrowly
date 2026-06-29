import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morrowly/journeys/time_capsule/data/capsule_square_seed.dart';
import 'package:morrowly/journeys/time_capsule/data/local_capsule_store.dart';
import 'package:morrowly/journeys/time_capsule/models/capsule_chronicle.dart';
import 'package:morrowly/journeys/time_capsule/view/capsule_composer_screen.dart';
import 'package:morrowly/journeys/time_capsule/view/capsule_detail_screen.dart';
import 'package:morrowly/journeys/time_capsule/view/my_capsules_screen.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_stage.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_widgets.dart';
import 'package:morrowly/shared/economy/morrowly_wallet_screen.dart';
import 'package:morrowly/shared/economy/morrowly_wallet_store.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';
import 'package:morrowly/shared/moderation/morrowly_moderation_store.dart';
import 'package:morrowly/shared/widgets/morrowly_moderation_dialog.dart';

const _designCanvasWidth = 375.0;
const _homeHorizontalInset = 18.0;
const _heroJarAspectRatio = 780 / 764;
const _heroHorizontalBleed = 48.0;
const _heroBannerOverlap = 108.0;
const _bannerAspectRatio = 700 / 154;

class CapsuleHomeScreen extends StatefulWidget {
  const CapsuleHomeScreen({super.key});

  @override
  State<CapsuleHomeScreen> createState() => _CapsuleHomeScreenState();
}

class _CapsuleHomeScreenState extends State<CapsuleHomeScreen> {
  late final List<CapsuleSquareNote> _squareNotes =
      CapsuleSquareSeed.squareNotes()
          .where((note) => note.visibility == CapsuleVisibility.publicSquare)
          .toList();
  final MorrowlyModerationStore _moderation = MorrowlyModerationStore.instance;
  final MorrowlyWalletStore _wallet = MorrowlyWalletStore.instance;
  final LocalCapsuleStore _capsules = LocalCapsuleStore.instance;

  @override
  void initState() {
    super.initState();
    _moderation.addListener(_refreshModeratedContent);
    _wallet.addListener(_refreshModeratedContent);
    _capsules.addListener(_refreshModeratedContent);
    _moderation.load();
    _wallet.load();
    _capsules.load();
  }

  @override
  void dispose() {
    _moderation.removeListener(_refreshModeratedContent);
    _wallet.removeListener(_refreshModeratedContent);
    _capsules.removeListener(_refreshModeratedContent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CapsuleStage(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final contentWidth = MorrowlyFrameGuard.contentWidth(
            width,
            maxWidth: _designCanvasWidth,
            phoneGutter: _homeHorizontalInset,
          );
          final side = (width - contentWidth) / 2;
          final heroWidth = (width + _heroHorizontalBleed)
              .clamp(0.0, 456.0)
              .toDouble();
          final heroHeight = heroWidth / _heroJarAspectRatio;
          final heroBannerTop = (heroHeight - _heroBannerOverlap)
              .clamp(0.0, heroHeight)
              .toDouble();
          final bannerWidth = (contentWidth - 24).clamp(0.0, 336.0).toDouble();
          final bannerHeight = bannerWidth / _bannerAspectRatio;
          final heroBlockHeight = heroBannerTop + bannerHeight;
          final visibleNotes = _visibleSquareNotes;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              side,
              MorrowlyFrameGuard.topClearance(context, minimum: 42, extra: 8),
              side,
              MorrowlyFrameGuard.bottomClearance(
                context,
                minimum: 120,
                extra: 92,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HomeHeader(
                  coinBalance: _wallet.balance,
                  onWallet: _openWallet,
                  onMyCapsules: _openMyCapsules,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: heroBlockHeight,
                  child: Center(
                    child: OverflowBox(
                      minWidth: width,
                      maxWidth: width,
                      child: SizedBox(
                        width: width,
                        height: heroBlockHeight,
                        child: Stack(
                          clipBehavior: Clip.hardEdge,
                          children: [
                            Positioned(
                              top: 0,
                              left: (width - heroWidth) / 2,
                              child: Image.asset(
                                CapsuleArtwork.heroJar,
                                width: heroWidth,
                                height: heroHeight,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                            Positioned(
                              top: heroBannerTop,
                              left: (width - bannerWidth) / 2,
                              child: _MakingCapsuleBanner(
                                width: bannerWidth,
                                onTap: _openComposer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Public Capsule Square',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                if (visibleNotes.isEmpty)
                  const _ModeratedEmptyState()
                else
                  for (final note in visibleNotes) ...[
                    _SquareNoteCard(
                      note: note,
                      onOpen: () => _openCapsuleDetail(_sourceNoteFor(note)),
                      onVisitors: () => _showVisitors(note.visitorTrail),
                      onSay: () => _openCapsuleDetail(
                        _sourceNoteFor(note),
                        focusComposer: true,
                      ),
                      onModerate: note.isLocalDraft
                          ? null
                          : () => _showNoteModeration(note),
                    ),
                    const SizedBox(height: 14),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }

  List<CapsuleSquareNote> get _visibleSquareNotes {
    return [
      for (final note in _capsules.publicCapsules)
        if (!_moderation.shouldHide(
          contentKey: note.noteKey,
          authorKey: note.keeper.keeperKey,
        ))
          note.copyWith(
            visitorTrail: [
              for (final keeper in note.visitorTrail)
                if (!_moderation.isAuthorBlocked(keeper.keeperKey)) keeper,
            ],
            comments: [
              for (final comment in note.comments)
                if (!_moderation.shouldHide(
                  contentKey: comment.commentKey,
                  authorKey: comment.author.keeperKey,
                ))
                  comment,
            ],
          ),
      for (final note in _squareNotes)
        if (!_moderation.shouldHide(
          contentKey: note.noteKey,
          authorKey: note.keeper.keeperKey,
        ))
          note.copyWith(
            visitorTrail: [
              for (final keeper in note.visitorTrail)
                if (!_moderation.isAuthorBlocked(keeper.keeperKey)) keeper,
            ],
            comments: [
              for (final comment in note.comments)
                if (!_moderation.shouldHide(
                  contentKey: comment.commentKey,
                  authorKey: comment.author.keeperKey,
                ))
                  comment,
            ],
          ),
    ];
  }

  CapsuleSquareNote _sourceNoteFor(CapsuleSquareNote visibleNote) {
    for (final note in _capsules.capsules) {
      if (note.noteKey == visibleNote.noteKey) {
        return note;
      }
    }
    for (final note in _squareNotes) {
      if (note.noteKey == visibleNote.noteKey) {
        return note;
      }
    }
    return visibleNote;
  }

  void _refreshModeratedContent() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openComposer() async {
    final sealed = await Navigator.of(context).push<CapsuleSquareNote>(
      MaterialPageRoute(
        builder: (_) => CapsuleComposerScreen(
          coinBalance: _wallet.balance,
          capsules: _capsules.capsules,
          onCapsulesChanged: (value) {
            unawaited(_capsules.replaceAll(value));
          },
        ),
      ),
    );
    if (sealed == null || !mounted) {
      return;
    }
    await _capsules.add(sealed);
  }

  Future<void> _openWallet() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const MorrowlyWalletScreen()),
    );
  }

  Future<void> _openCapsuleDetail(
    CapsuleSquareNote note, {
    bool focusComposer = false,
  }) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => CapsuleDetailScreen(
          note: note,
          focusComposer: focusComposer,
          onNoteChanged: _replaceCapsuleNote,
        ),
      ),
    );
  }

  void _replaceCapsuleNote(CapsuleSquareNote updated) {
    if (!mounted) {
      return;
    }
    setState(() {
      for (var index = 0; index < _squareNotes.length; index++) {
        if (_squareNotes[index].noteKey == updated.noteKey) {
          _squareNotes[index] = updated;
          return;
        }
      }
    });
    unawaited(_capsules.replace(updated));
  }

  Future<void> _openMyCapsules() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MyCapsulesScreen(
          capsules: _capsules.capsules,
          coinBalance: _wallet.balance,
          onCapsulesChanged: (value) {
            unawaited(_capsules.replaceAll(value));
          },
        ),
      ),
    );
  }

  void _showVisitors(List<CapsuleKeeper> keepers) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.52),
      builder: (context) {
        return _VisitorsSheet(keepers: keepers);
      },
    );
  }

  Future<void> _showNoteModeration(CapsuleSquareNote note) async {
    await showMorrowlyModerationFlow(
      context: context,
      store: _moderation,
      target: MorrowlyModerationTarget(
        contentKey: note.noteKey,
        authorKey: note.keeper.keeperKey,
        authorName: note.keeper.displayName,
        kind: MorrowlyModerationKind.capsule,
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.coinBalance,
    required this.onWallet,
    required this.onMyCapsules,
  });

  final int coinBalance;
  final VoidCallback onWallet;
  final VoidCallback onMyCapsules;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                CapsuleArtwork.threadUnderline,
                width: 117,
                height: 37,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
              ),
            ],
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onWallet,
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(999),
            ),
            child: CapsuleCoinAmount(amount: coinBalance),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onMyCapsules,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            backgroundImage: const AssetImage(
              'assets/images/head/bloom_arch_window.jpg',
            ),
          ),
        ),
      ],
    );
  }
}

class _MakingCapsuleBanner extends StatelessWidget {
  const _MakingCapsuleBanner({required this.width, required this.onTap});

  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Making time capsules',
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: width,
          height: width / _bannerAspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                CapsuleArtwork.actionOrbit,
                width: width,
                height: width / _bannerAspectRatio,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
              ),
              Positioned(
                right: 15,
                child: Image.asset(
                  CapsuleArtwork.actionFeather,
                  width: 46,
                  height: 46,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SquareNoteCard extends StatelessWidget {
  const _SquareNoteCard({
    required this.note,
    required this.onOpen,
    required this.onVisitors,
    required this.onSay,
    this.onModerate,
  });

  final CapsuleSquareNote note;
  final VoidCallback onOpen;
  final VoidCallback onVisitors;
  final VoidCallback onSay;
  final VoidCallback? onModerate;

  @override
  Widget build(BuildContext context) {
    final previewSnap = note.mediaSnaps.isEmpty ? null : note.mediaSnaps.first;
    final openingLabel = note.canOpenNow
        ? 'Ready to open'
        : 'Opens ${capsuleDateStamp(note.openingAt)}';

    return Semantics(
      button: true,
      label: 'Open ${note.keeper.displayName} capsule detail',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onOpen,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          decoration: BoxDecoration(
            color: const Color(0xFF4E3D54).withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 23,
                    backgroundImage: AssetImage(note.keeper.avatarAsset),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.keeper.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Image.asset(
                              note.keeper.signalBand == KeeperSignalBand.bloom
                                  ? CapsuleArtwork.bloomMark
                                  : CapsuleArtwork.museMark,
                              width: 14,
                              height: 14,
                              filterQuality: FilterQuality.high,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${note.keeper.ageLine}  · ${note.keeper.placeLine}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFFBD88FF),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (onModerate != null)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onModerate,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.more_horiz_rounded,
                          color: Color(0xFF55415A),
                          size: 17,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 13),
              Text(
                note.messageLine,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.86),
                  fontSize: 13,
                  height: 1.34,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 13),
              if (previewSnap != null) ...[
                _SquareMediaTile(snap: previewSnap),
                const SizedBox(height: 10),
              ],
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _SoftCapsuleChip(
                    label: openingLabel,
                    color: note.canOpenNow
                        ? const Color(0xFFFF4747)
                        : const Color(0xFFBBCDFF),
                  ),
                  _SoftCapsuleChip(
                    label: 'Sealed ${capsuleDateStamp(note.sealedAt)}',
                    color: const Color(0xFFD6B7FF),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onVisitors,
                      child: _SquareVisitorSummary(note: note),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CapsuleAssetTap(
                    assetName: CapsuleArtwork.sayButton,
                    width: 82,
                    height: 33,
                    semanticLabel: 'Say something',
                    onTap: onSay,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SquareVisitorSummary extends StatelessWidget {
  const _SquareVisitorSummary({required this.note});

  final CapsuleSquareNote note;

  @override
  Widget build(BuildContext context) {
    final visibleVisitors = note.visitorTrail.take(4).toList();
    return Row(
      children: [
        SizedBox(
          height: 30,
          width: 82,
          child: Stack(
            children: [
              for (var index = 0; index < visibleVisitors.length; index++)
                Positioned(
                  left: index * 17,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: const Color(0xFF4E3D54),
                    child: CircleAvatar(
                      radius: 13.5,
                      backgroundImage: AssetImage(
                        visibleVisitors[index].avatarAsset,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '${note.leftMessageCount} comments',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.52),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeratedEmptyState extends StatelessWidget {
  const _ModeratedEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF4E3D54).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              CapsuleArtwork.dialogPrelude,
              width: 156,
              height: 86,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Nothing to show here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reported capsules and blocked people stay hidden on this device.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.58),
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

class _SquareMediaTile extends StatelessWidget {
  const _SquareMediaTile({required this.snap});

  final CapsuleMediaSnap snap;

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

class _SoftCapsuleChip extends StatelessWidget {
  const _SoftCapsuleChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color == const Color(0xFFFF4747)
              ? const Color(0xFF791111)
              : const Color(0xFF7557A4),
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _VisitorsSheet extends StatelessWidget {
  const _VisitorsSheet({required this.keepers});

  final List<CapsuleKeeper> keepers;

  @override
  Widget build(BuildContext context) {
    final bottom = MorrowlyFrameGuard.bottomClearance(
      context,
      minimum: 24,
      extra: 18,
    );
    return DraggableScrollableSheet(
      initialChildSize: 0.68,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      builder: (context, controller) {
        return Container(
          padding: EdgeInsets.fromLTRB(18, 14, 18, bottom),
          decoration: const BoxDecoration(
            color: Color(0xFF38283D),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'People waiting with this capsule',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: GridView.builder(
                  controller: controller,
                  itemCount: keepers.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (context, index) {
                    final keeper = keepers[index];
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 31,
                          backgroundImage: AssetImage(keeper.avatarAsset),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          keeper.displayName.split(' ').first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
