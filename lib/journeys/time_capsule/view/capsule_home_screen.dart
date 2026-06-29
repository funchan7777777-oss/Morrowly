import 'package:flutter/material.dart';
import 'package:morrowly/journeys/time_capsule/data/capsule_square_seed.dart';
import 'package:morrowly/journeys/time_capsule/models/capsule_chronicle.dart';
import 'package:morrowly/journeys/time_capsule/view/capsule_composer_screen.dart';
import 'package:morrowly/journeys/time_capsule/view/my_capsules_screen.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_stage.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_widgets.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';

const _designCanvasWidth = 375.0;
const _homeHorizontalInset = 18.0;
const _heroJarAspectRatio = 780 / 764;
const _bannerAspectRatio = 700 / 154;

class CapsuleHomeScreen extends StatefulWidget {
  const CapsuleHomeScreen({super.key});

  @override
  State<CapsuleHomeScreen> createState() => _CapsuleHomeScreenState();
}

class _CapsuleHomeScreenState extends State<CapsuleHomeScreen> {
  late final List<CapsuleSquareNote> _squareNotes =
      CapsuleSquareSeed.squareNotes();
  late final List<CapsuleSquareNote> _myCapsules = _squareNotes
      .take(4)
      .map(
        (note) => CapsuleSquareNote(
          noteKey: 'mine-${note.noteKey}',
          keeper: CapsuleSquareSeed.currentKeeper,
          messageLine: note.messageLine,
          mediaSnaps: note.mediaSnaps,
          sealedAt: note.sealedAt,
          openingAt: note.openingAt,
          visibility: note.visibility,
          visitorTrail: note.visitorTrail,
          leftMessageCount: note.leftMessageCount,
          isLocalDraft: true,
        ),
      )
      .toList();
  int _coinBalance = 999;

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
          final heroWidth = (contentWidth + 22).clamp(0.0, 408.0).toDouble();
          final heroHeight = heroWidth / _heroJarAspectRatio;
          final bannerWidth = (contentWidth - 24)
              .clamp(0.0, 336.0)
              .toDouble();

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
                  coinBalance: _coinBalance,
                  onMyCapsules: _openMyCapsules,
                ),
                const SizedBox(height: 8),
                Center(
                  child: SizedBox(
                    width: contentWidth,
                    height: heroHeight - 26,
                    child: OverflowBox(
                      minWidth: heroWidth,
                      maxWidth: heroWidth,
                      minHeight: heroHeight,
                      maxHeight: heroHeight,
                      child: Image.asset(
                        CapsuleArtwork.heroJar,
                        width: heroWidth,
                        height: heroHeight,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 0),
                Center(
                  child: _MakingCapsuleBanner(
                    width: bannerWidth,
                    onTap: _openComposer,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Open Capsule Square',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                for (final note in _squareNotes) ...[
                  _SquareNoteCard(
                    note: note,
                    onVisitors: () => _showVisitors(note.visitorTrail),
                    onSay: () => _showSaySheet(note),
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

  Future<void> _openComposer() async {
    final sealed = await Navigator.of(context).push<CapsuleSquareNote>(
      MaterialPageRoute(
        builder: (_) => CapsuleComposerScreen(coinBalance: _coinBalance),
      ),
    );
    if (sealed == null || !mounted) {
      return;
    }
    setState(() {
      _myCapsules.insert(0, sealed);
      _squareNotes.insert(0, sealed);
      _coinBalance = (_coinBalance - 50).clamp(0, 99999);
    });
  }

  Future<void> _openMyCapsules() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MyCapsulesScreen(
          capsules: _myCapsules,
          coinBalance: _coinBalance,
          onCoinBalanceChanged: (value) {
            if (mounted) {
              setState(() => _coinBalance = value);
            }
          },
          onCapsulesChanged: (value) {
            if (mounted) {
              setState(() {
                _myCapsules
                  ..clear()
                  ..addAll(value);
              });
            }
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

  void _showSaySheet(CapsuleSquareNote note) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        final bottom = MorrowlyFrameGuard.bottomClearance(
          context,
          minimum: 24,
          extra: 16,
        );
        return Padding(
          padding: EdgeInsets.fromLTRB(18, 0, 18, bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            decoration: BoxDecoration(
              color: const Color(0xFF4A3550),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leave a small echo for ${note.keeper.displayName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your words will wait beside this capsule until it opens.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.62),
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                CapsuleGlowButton(
                  label: 'Send echo',
                  width: double.infinity,
                  icon: Icons.chat_bubble_outline_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.coinBalance, required this.onMyCapsules});

  final int coinBalance;
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
          onTap: onMyCapsules,
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
    required this.onVisitors,
    required this.onSay,
  });

  final CapsuleSquareNote note;
  final VoidCallback onVisitors;
  final VoidCallback onSay;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                        Text(
                          '${note.keeper.ageLine}  · ${note.keeper.placeLine}',
                          style: const TextStyle(
                            color: Color(0xFFBD88FF),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.more_horiz_rounded,
                  color: Color(0xFF55415A),
                  size: 16,
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
          Row(
            children: [
              for (final snap in note.mediaSnaps.take(2)) ...[
                Expanded(child: _SquareMediaTile(snap: snap)),
                if (snap != note.mediaSnaps.take(2).last)
                  const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _SoftCapsuleChip(
                label: note.canOpenNow ? 'Can be opened' : 'Open in 1 year',
                color: note.canOpenNow
                    ? const Color(0xFFFF4747)
                    : const Color(0xFFBBCDFF),
              ),
              _SoftCapsuleChip(
                label: '${capsuleDateStamp(note.sealedAt)} seal',
                color: const Color(0xFFD6B7FF),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onVisitors,
                child: SizedBox(
                  height: 27,
                  width: 160,
                  child: Stack(
                    children: [
                      for (var index = 0; index < 4; index++)
                        Positioned(
                          left: index * 16,
                          child: CircleAvatar(
                            radius: 13.5,
                            backgroundColor: Colors.white,
                            backgroundImage: AssetImage(
                              note.visitorTrail[index].avatarAsset,
                            ),
                          ),
                        ),
                      Positioned(
                        left: 72,
                        top: 6,
                        child: Text(
                          '${note.leftMessageCount} people left messages',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
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
