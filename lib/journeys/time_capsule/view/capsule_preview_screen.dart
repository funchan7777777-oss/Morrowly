import 'package:flutter/material.dart';
import 'package:morrowly/journeys/time_capsule/data/capsule_square_seed.dart';
import 'package:morrowly/journeys/time_capsule/models/capsule_chronicle.dart';
import 'package:morrowly/journeys/time_capsule/view/capsule_success_screen.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_stage.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_widgets.dart';
import 'package:morrowly/shared/economy/morrowly_wallet_screen.dart';
import 'package:morrowly/shared/economy/morrowly_wallet_store.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';

class CapsulePreviewScreen extends StatefulWidget {
  const CapsulePreviewScreen({
    super.key,
    required this.draft,
    required this.coinBalance,
  });

  final CapsuleDraftLedger draft;
  final int coinBalance;

  @override
  State<CapsulePreviewScreen> createState() => _CapsulePreviewScreenState();
}

class _CapsulePreviewScreenState extends State<CapsulePreviewScreen> {
  late CapsuleVisibility _visibility = widget.draft.visibility;

  @override
  Widget build(BuildContext context) {
    return CapsuleStage(
      child: Stack(
        children: [
          LayoutBuilder(
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
                  MorrowlyFrameGuard.topClearance(
                    context,
                    minimum: 104,
                    extra: 38,
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        CapsuleArtwork.previewWash,
                        width: contentWidth,
                        height: 146,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'A letter to the future',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${capsuleDateStamp(widget.draft.openingAt)} open',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.28),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.draft.messageLine,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.66),
                        fontSize: 14,
                        height: 1.36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (widget.draft.mediaSnaps.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 88,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.draft.mediaSnaps.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            return CapsuleMediaTile(
                              snap: widget.draft.mediaSnaps[index],
                              size: 88,
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    _PreviewInfoRow(
                      title: 'Start time',
                      value:
                          '${capsuleDateStamp(widget.draft.openingAt)} ${capsuleClockStamp(widget.draft.openingAt)}',
                    ),
                    const SizedBox(height: 12),
                    _VisibilityRow(
                      value: _visibility,
                      onChanged: (value) {
                        setState(() => _visibility = value);
                      },
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: CapsuleAssetTap(
                        assetName: CapsuleArtwork.confirmSeal,
                        width: contentWidth * 0.76,
                        height: 44,
                        semanticLabel: 'Confirm sealing',
                        onTap: _confirmSealing,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          CapsuleTopBar(
            title: 'Preview Capsule',
            onBack: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSealing() async {
    final spent = await confirmAndSpendMorrowlyCoins(
      context,
      cost: MorrowlyCoinCosts.sealCapsule,
    );
    if (!spent || !mounted) {
      return;
    }
    _sealCapsule();
  }

  void _sealCapsule() {
    final sealed = CapsuleSquareNote(
      noteKey: 'local-${DateTime.now().microsecondsSinceEpoch}',
      keeper: CapsuleSquareSeed.currentKeeper,
      messageLine: widget.draft.messageLine,
      mediaSnaps: widget.draft.mediaSnaps,
      sealedAt: DateTime.now(),
      openingAt: widget.draft.openingAt,
      visibility: _visibility,
      visitorTrail: CapsuleSquareSeed.allKeepers,
      leftMessageCount: 0,
      isLocalDraft: true,
    );
    Navigator.of(context).pushReplacement<CapsuleSquareNote, void>(
      MaterialPageRoute(builder: (_) => CapsuleSuccessScreen(capsule: sealed)),
    );
  }
}

class _PreviewInfoRow extends StatelessWidget {
  const _PreviewInfoRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF583F5F),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.34),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _VisibilityRow extends StatelessWidget {
  const _VisibilityRow({required this.value, required this.onChanged});

  final CapsuleVisibility value;
  final ValueChanged<CapsuleVisibility> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onChanged(
          value == CapsuleVisibility.publicSquare
              ? CapsuleVisibility.privateShelf
              : CapsuleVisibility.publicSquare,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF583F5F),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Text(
              'Who can see',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              value == CapsuleVisibility.publicSquare
                  ? 'Public (visible to everyone)'
                  : 'Private (only you)',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.34),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.32),
            ),
          ],
        ),
      ),
    );
  }
}
