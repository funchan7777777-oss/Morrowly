import 'package:flutter/material.dart';
import 'package:morrowly/journeys/time_capsule/data/capsule_square_seed.dart';
import 'package:morrowly/journeys/time_capsule/models/capsule_chronicle.dart';
import 'package:morrowly/journeys/time_capsule/view/capsule_composer_screen.dart';
import 'package:morrowly/journeys/time_capsule/view/my_capsules_screen.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_stage.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_widgets.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';

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
            maxWidth: 430,
            phoneGutter: 24,
          );
          final side = (width - contentWidth) / 2;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              side,
              MorrowlyFrameGuard.topClearance(context, minimum: 64, extra: 12),
              side,
              MorrowlyFrameGuard.bottomClearance(
                context,
                minimum: 132,
                extra: 110,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HomeHeader(
                  coinBalance: _coinBalance,
                  onMyCapsules: _openMyCapsules,
                ),
                const SizedBox(height: 14),
                Center(
                  child: Image.asset(
                    CapsuleArtwork.heroJar,
                    width: contentWidth * 0.82,
                    height: contentWidth * 0.6,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: CapsuleAssetTap(
                    assetName: CapsuleArtwork.actionOrbit,
                    width: contentWidth,
                    height: 74,
                    semanticLabel: 'Making time capsules',
                    onTap: _openComposer,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Open Capsule Square',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                for (final note in _squareNotes) ...[
                  _SquareNoteCard(
                    note: note,
                    onVisitors: () => _showVisitors(note.visitorTrail),
                    onSay: () => _showSaySheet(note),
                  ),
                  const SizedBox(height: 16),
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
              const Text(
                'Time Capsule',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Image.asset(
                CapsuleArtwork.threadUnderline,
                width: 118,
                height: 18,
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
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 10),
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
            radius: 19,
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF514057).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage(note.keeper.avatarAsset),
              ),
              const SizedBox(width: 12),
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
                        fontSize: 16,
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
                            fontSize: 12,
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
          const SizedBox(height: 14),
          Text(
            note.messageLine,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 14,
              height: 1.34,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final snap in note.mediaSnaps.take(2)) ...[
                Expanded(child: CapsuleMediaTile(snap: snap, size: 116)),
                if (snap != note.mediaSnaps.take(2).last)
                  const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onVisitors,
                child: SizedBox(
                  height: 30,
                  width: 142,
                  child: Stack(
                    children: [
                      for (var index = 0; index < 4; index++)
                        Positioned(
                          left: index * 18,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            backgroundImage: AssetImage(
                              note.visitorTrail[index].avatarAsset,
                            ),
                          ),
                        ),
                      Positioned(
                        left: 82,
                        top: 7,
                        child: Text(
                          '${note.leftMessageCount} people left messages',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 10,
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
                width: 84,
                height: 34,
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

class _SoftCapsuleChip extends StatelessWidget {
  const _SoftCapsuleChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
          fontSize: 11,
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
