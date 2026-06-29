import 'package:flutter/material.dart';
import 'package:morrowly/journeys/time_capsule/data/capsule_square_seed.dart';
import 'package:morrowly/journeys/time_capsule/models/capsule_chronicle.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_stage.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_widgets.dart';
import 'package:morrowly/shared/economy/morrowly_wallet_screen.dart';
import 'package:morrowly/shared/economy/morrowly_wallet_store.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';
import 'package:morrowly/shared/widgets/morrowly_empty_state.dart';

class MyCapsulesScreen extends StatefulWidget {
  const MyCapsulesScreen({
    super.key,
    required this.capsules,
    required this.coinBalance,
    this.onCoinBalanceChanged,
    this.onCapsulesChanged,
  });

  final List<CapsuleSquareNote> capsules;
  final int coinBalance;
  final ValueChanged<int>? onCoinBalanceChanged;
  final ValueChanged<List<CapsuleSquareNote>>? onCapsulesChanged;

  @override
  State<MyCapsulesScreen> createState() => _MyCapsulesScreenState();
}

class _MyCapsulesScreenState extends State<MyCapsulesScreen> {
  late List<CapsuleSquareNote> _capsules = [...widget.capsules];
  final MorrowlyWalletStore _wallet = MorrowlyWalletStore.instance;

  @override
  void initState() {
    super.initState();
    _wallet.addListener(_refreshWallet);
    _wallet.load();
  }

  @override
  void dispose() {
    _wallet.removeListener(_refreshWallet);
    super.dispose();
  }

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
              final contentPadding = EdgeInsets.fromLTRB(
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
              );
              if (_capsules.isEmpty) {
                return Padding(
                  padding: contentPadding,
                  child: const MorrowlyEmptyState(),
                );
              }
              return GridView.builder(
                padding: contentPadding,
                itemCount: _capsules.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.66,
                ),
                itemBuilder: (context, index) {
                  final capsule = _capsules[index];
                  return _MyCapsuleCard(
                    capsule: capsule,
                    onDelete: () => _confirmDelete(capsule),
                    onCheck: capsule.canOpenNow
                        ? () {
                            _confirmOpen(capsule);
                          }
                        : null,
                  );
                },
              );
            },
          ),
          CapsuleTopBar(
            title: 'My capsules',
            onBack: () => Navigator.of(context).pop(),
            trailing: CapsuleCoinAmount(amount: _wallet.balance),
          ),
        ],
      ),
    );
  }

  void _refreshWallet() {
    if (mounted) {
      setState(() {});
    }
  }

  void _confirmDelete(CapsuleSquareNote capsule) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.62),
      builder: (context) => CapsuleConfirmDialog(
        title: 'Please confirm',
        message:
            'After deletion, all content will be cleared and cannot be restored. Are you sure you want to delete it?',
        actionLabel: 'Confirm',
        onAction: () {
          Navigator.of(context).pop();
          setState(() {
            _capsules = [
              for (final item in _capsules)
                if (item.noteKey != capsule.noteKey) item,
            ];
          });
          widget.onCapsulesChanged?.call(_capsules);
        },
      ),
    );
  }

  Future<void> _confirmOpen(CapsuleSquareNote capsule) async {
    final spent = await confirmAndSpendMorrowlyCoins(
      context,
      cost: MorrowlyCoinCosts.openCapsule,
    );
    if (!spent || !mounted) {
      return;
    }
    _showUnlockedCapsule(capsule);
  }

  void _showUnlockedCapsule(CapsuleSquareNote capsule) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.54),
      builder: (context) => _UnlockedCapsuleSheet(capsule: capsule),
    );
  }
}

class _MyCapsuleCard extends StatelessWidget {
  const _MyCapsuleCard({
    required this.capsule,
    required this.onDelete,
    required this.onCheck,
  });

  final CapsuleSquareNote capsule;
  final VoidCallback onDelete;
  final VoidCallback? onCheck;

  @override
  Widget build(BuildContext context) {
    final canOpen = capsule.canOpenNow;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF514057).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            capsule.visibility == CapsuleVisibility.publicSquare
                ? CapsuleArtwork.publicChip
                : CapsuleArtwork.privateChip,
            width: 72,
            height: 30,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Center(
              child: Image.asset(
                CapsuleArtwork.heroJar,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          Text(
            canOpen
                ? 'Can be opened'
                : 'Opens ${capsuleDateStamp(capsule.openingAt)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: canOpen ? const Color(0xFFFF4444) : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${capsuleDateStamp(capsule.sealedAt)} seal',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.44),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CapsuleAssetTap(
                  assetName: CapsuleArtwork.deleteChip,
                  width: 82,
                  height: 36,
                  semanticLabel: 'Delete capsule',
                  onTap: onDelete,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Opacity(
                  opacity: canOpen ? 1 : 0.38,
                  child: CapsuleAssetTap(
                    assetName: CapsuleArtwork.checkChip,
                    width: 82,
                    height: 36,
                    semanticLabel: 'Check capsule',
                    onTap: onCheck ?? () {},
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnlockedCapsuleSheet extends StatelessWidget {
  const _UnlockedCapsuleSheet({required this.capsule});

  final CapsuleSquareNote capsule;

  @override
  Widget build(BuildContext context) {
    final bottom = MorrowlyFrameGuard.bottomClearance(
      context,
      minimum: 24,
      extra: 18,
    );
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.42,
      maxChildSize: 0.9,
      builder: (context, controller) {
        return Container(
          padding: EdgeInsets.fromLTRB(18, 14, 18, bottom),
          decoration: const BoxDecoration(
            color: Color(0xFF39283F),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: controller,
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
                'Opened capsule',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                capsule.messageLine,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.74),
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final snap in capsule.mediaSnaps)
                    CapsuleMediaTile(snap: snap, size: 92),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
