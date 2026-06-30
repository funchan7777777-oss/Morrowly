import 'package:flutter/material.dart';
import 'package:morrowly/journeys/present_grounding/widgets/keeper_memory_widgets.dart';
import 'package:morrowly/shared/economy/morrowly_wallet_store.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';

const _walletCoinAsset = 'assets/morrowly_art/ui/morrowly_ui_timelock.png';
const _walletWashAsset = 'assets/morrowly_art/ui/morrowly_ui_shareable.png';
const _walletEmptyAsset = 'assets/morrowly_art/ui/morrowly_ui_reminder.png';

class MorrowlyCoinBalancePill extends StatefulWidget {
  const MorrowlyCoinBalancePill({
    super.key,
    this.height = 28,
    this.iconSize = 18,
    this.fontSize = 12,
    this.horizontalPadding = 9,
    this.onTap,
  });

  final double height;
  final double iconSize;
  final double fontSize;
  final double horizontalPadding;
  final VoidCallback? onTap;

  @override
  State<MorrowlyCoinBalancePill> createState() =>
      _MorrowlyCoinBalancePillState();
}

class _MorrowlyCoinBalancePillState extends State<MorrowlyCoinBalancePill> {
  late final Future<void> _loadFuture = MorrowlyWalletStore.instance.load();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, _) {
        return AnimatedBuilder(
          animation: MorrowlyWalletStore.instance,
          builder: (context, _) {
            final label = MorrowlyWalletStore.formatCoins(
              MorrowlyWalletStore.instance.balance,
            );
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTap,
              child: Container(
                height: widget.height,
                padding: EdgeInsets.symmetric(
                  horizontal: widget.horizontalPadding,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      _walletCoinAsset,
                      width: widget.iconSize,
                      height: widget.iconSize,
                      filterQuality: FilterQuality.high,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widget.fontSize,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class MorrowlyWalletScreen extends StatefulWidget {
  const MorrowlyWalletScreen({super.key});

  @override
  State<MorrowlyWalletScreen> createState() => _MorrowlyWalletScreenState();
}

class _MorrowlyWalletScreenState extends State<MorrowlyWalletScreen> {
  final MorrowlyWalletStore _wallet = MorrowlyWalletStore.instance;
  late final Future<void> _loadFuture = _wallet.load();

  @override
  Widget build(BuildContext context) {
    return MorrowlyMemoryStage(
      child: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          return AnimatedBuilder(
            animation: _wallet,
            builder: (context, _) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      _walletWashAsset,
                      fit: BoxFit.cover,
                      opacity: const AlwaysStoppedAnimation(0.16),
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final contentWidth = MorrowlyFrameGuard.contentWidth(
                        constraints.maxWidth,
                        maxWidth: 430,
                        phoneGutter: 20,
                      );
                      final side = (constraints.maxWidth - contentWidth) / 2;
                      return SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          side,
                          MorrowlyFrameGuard.topClearance(
                            context,
                            minimum: 112,
                            extra: 38,
                          ),
                          side,
                          34,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _WalletHero(balance: _wallet.balance),
                            const SizedBox(height: 24),
                            const _UsagePanel(),
                            const SizedBox(height: 22),
                            const Text(
                              'Recharge',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.72,
                                  ),
                              itemCount: MorrowlyCoinPacks.all.length,
                              itemBuilder: (context, index) {
                                final pack = MorrowlyCoinPacks.all[index];
                                return _CoinPackCard(
                                  pack: pack,
                                  buying:
                                      _wallet.purchasingProductId ==
                                      pack.productId,
                                  onBuy: () => _buyPack(pack),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  MorrowlyMemoryTopBar(
                    title: 'Wallet',
                    onBack: () => Navigator.of(context).pop(),
                    trailing: IconButton(
                      onPressed: _showWalletHelp,
                      icon: const Icon(
                        Icons.help_outline_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      tooltip: 'Wallet help',
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _buyPack(MorrowlyCoinPack pack) async {
    final result = await _wallet.purchasePack(pack);
    if (!mounted) {
      return;
    }

    if (result.started) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Apple purchase started for ${pack.coinsLabel} coins.'),
          backgroundColor: lifePanel,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.62),
      builder: (context) => _WalletNoticeDialog(
        title: 'Purchase unavailable',
        message: result.message,
        actionLabel: 'Back to wallet',
      ),
    );
  }

  void _showWalletHelp() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.62),
      builder: (context) => const _WalletNoticeDialog(
        title: 'Apple products',
        message:
            'Morrowly fetches the selected consumable from Apple only after you tap a recharge pack. Coins are credited after Apple confirms the purchase.',
        actionLabel: 'Understood',
      ),
    );
  }
}

Future<bool> confirmAndSpendMorrowlyCoins(
  BuildContext context, {
  required MorrowlyCoinCost cost,
}) async {
  final wallet = MorrowlyWalletStore.instance;
  await wallet.load();
  if (!context.mounted) {
    return false;
  }

  if (wallet.balance < cost.amount) {
    await showMorrowlyInsufficientCoinsDialog(context, cost: cost);
    return false;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.62),
    builder: (context) => _CoinSpendDialog(cost: cost),
  );
  if (confirmed != true) {
    return false;
  }

  final spent = await wallet.spend(cost);
  if (!context.mounted) {
    return false;
  }

  if (!spent) {
    await showMorrowlyInsufficientCoinsDialog(context, cost: cost);
    return false;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('${cost.amount} coins used for ${cost.title}.'),
      backgroundColor: lifePanel,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
  return true;
}

Future<void> showMorrowlyInsufficientCoinsDialog(
  BuildContext context, {
  required MorrowlyCoinCost cost,
}) async {
  final goWallet = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.62),
    builder: (context) => _WalletNoticeDialog(
      title: 'Coins are not enough',
      message:
          '${cost.title} needs ${cost.amount} coins. Recharge now to continue.',
      actionLabel: 'Recharge',
      icon: Icons.lock_clock_rounded,
    ),
  );
  if (goWallet == true && context.mounted) {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const MorrowlyWalletScreen()),
    );
  }
}

Future<void> showMorrowlyWelcomeGiftDialog(
  BuildContext context, {
  required int amount,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.66),
    builder: (context) => _WelcomeGiftDialog(amount: amount),
  );
}

class _WalletHero extends StatelessWidget {
  const _WalletHero({required this.balance});

  final int balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: lifePanel.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My wallet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  MorrowlyWalletStore.formatCoins(balance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'real-time coin balance',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.54),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            _walletCoinAsset,
            width: 104,
            height: 104,
            filterQuality: FilterQuality.high,
          ),
        ],
      ),
    );
  }
}

class _UsagePanel extends StatelessWidget {
  const _UsagePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: lifePanel.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Coin usage',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 12),
          for (final cost in MorrowlyCoinCosts.paidFeatures) ...[
            _UsageRow(cost: cost),
            if (cost != MorrowlyCoinCosts.paidFeatures.last)
              const SizedBox(height: 10),
          ],
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Free: editing drafts, viewing your saved compass, profile changes, chat and video chat. Chat features stay available only after mutual follow.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                height: 1.28,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageRow extends StatelessWidget {
  const _UsageRow({required this.cost});

  final MorrowlyCoinCost cost;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: lifePurple.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Image.asset(
              _walletCoinAsset,
              width: 20,
              height: 20,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cost.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                cost.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.48),
                  fontSize: 10,
                  height: 1.22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${cost.amount}',
          style: const TextStyle(
            color: Color(0xFFFFD986),
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _CoinPackCard extends StatelessWidget {
  const _CoinPackCard({
    required this.pack,
    required this.buying,
    required this.onBuy,
  });

  final MorrowlyCoinPack pack;
  final bool buying;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: buying ? null : onBuy,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: buying ? 0.62 : 1,
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 9),
          decoration: BoxDecoration(
            color: lifePanel.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: buying
                      ? const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Image.asset(
                          _walletCoinAsset,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                pack.coinsLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.62),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: lifePurple,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: lifePurple.withValues(alpha: 0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  pack.priceLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoinSpendDialog extends StatelessWidget {
  const _CoinSpendDialog({required this.cost});

  final MorrowlyCoinCost cost;

  @override
  Widget build(BuildContext context) {
    return _WalletDialogFrame(
      icon: Icons.auto_awesome_rounded,
      title: 'Use time coins',
      message:
          '${cost.title} will use ${cost.amount} coins. The balance updates everywhere after confirmation.',
      actionLabel: 'Use ${cost.amount}',
      cancelLabel: 'Cancel',
      onAction: () => Navigator.of(context).pop(true),
    );
  }
}

class _WalletNoticeDialog extends StatelessWidget {
  const _WalletNoticeDialog({
    required this.title,
    required this.message,
    required this.actionLabel,
    this.icon = Icons.hourglass_bottom_rounded,
  });

  final String title;
  final String message;
  final String actionLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _WalletDialogFrame(
      icon: icon,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: () => Navigator.of(context).pop(true),
    );
  }
}

class _WelcomeGiftDialog extends StatelessWidget {
  const _WelcomeGiftDialog({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.92, end: 1),
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
          decoration: BoxDecoration(
            color: const Color(0xFF4D3657),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: lifePurple.withValues(alpha: 0.28),
                blurRadius: 32,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    _walletEmptyAsset,
                    width: 132,
                    height: 112,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    opacity: const AlwaysStoppedAnimation(0.22),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: -0.08, end: 0.08),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeInOut,
                    builder: (context, turn, child) {
                      return Transform.rotate(angle: turn, child: child);
                    },
                    child: Image.asset(
                      _walletCoinAsset,
                      width: 88,
                      height: 88,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'A time coin spark arrived',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '+${MorrowlyWalletStore.formatCoins(amount)} coins have been placed in your wallet for your first future capsule.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontSize: 13,
                  height: 1.36,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: lifePurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'Start Morrowly',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletDialogFrame extends StatelessWidget {
  const _WalletDialogFrame({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.cancelLabel,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final String? cancelLabel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        decoration: BoxDecoration(
          color: const Color(0xFF4D3657),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 30,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: lifePurple.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    _walletCoinAsset,
                    width: 54,
                    height: 54,
                    filterQuality: FilterQuality.high,
                    opacity: const AlwaysStoppedAnimation(0.36),
                  ),
                  Icon(icon, color: Colors.white, size: 30),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                height: 1.1,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.64),
                fontSize: 13,
                height: 1.38,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (cancelLabel != null) ...[
                  Expanded(
                    child: _DialogButton(
                      label: cancelLabel!,
                      filled: false,
                      onTap: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: _DialogButton(
                    label: actionLabel,
                    filled: true,
                    onTap: onAction,
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

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? lifePurple : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: filled ? 1 : 0.76),
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
