import 'dart:io';

import 'package:flutter/material.dart';
import 'package:morrowly/journeys/time_capsule/data/capsule_square_seed.dart';
import 'package:morrowly/journeys/time_capsule/models/capsule_chronicle.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';
import 'package:morrowly/shared/widgets/morrowly_avatar_placeholder.dart';

String capsuleDateStamp(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}.$month.$day';
}

String capsuleClockStamp(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

ImageProvider<Object> capsuleKeeperAvatarProvider(CapsuleKeeper keeper) {
  if (keeper.localPortraitPath.isNotEmpty) {
    return FileImage(File(keeper.localPortraitPath));
  }
  return AssetImage(
    keeper.portraitAsset.isEmpty
        ? 'assets/morrowly_art/ui/morrowly_ui_memoir.png'
        : keeper.portraitAsset,
  );
}

bool capsuleKeeperUsesGeneratedAvatar(CapsuleKeeper keeper) {
  return keeper.localPortraitPath.isEmpty &&
      (keeper.portraitAsset.isEmpty ||
          keeper.portraitAsset ==
              'assets/morrowly_art/ui/morrowly_ui_memoir.png');
}

class CapsuleKeeperAvatar extends StatelessWidget {
  const CapsuleKeeperAvatar({
    super.key,
    required this.keeper,
    required this.radius,
  });

  final CapsuleKeeper keeper;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (capsuleKeeperUsesGeneratedAvatar(keeper)) {
      return MorrowlyAvatarPlaceholder(
        radius: radius,
        label: keeper.publicName,
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white.withValues(alpha: 0.16),
      backgroundImage: capsuleKeeperAvatarProvider(keeper),
    );
  }
}

class CapsuleTopBar extends StatelessWidget {
  const CapsuleTopBar({
    super.key,
    required this.title,
    this.trailing,
    this.onBack,
    this.topMinimum = 48,
    this.topExtra = -6,
    this.height = 44,
  });

  final String title;
  final Widget? trailing;
  final VoidCallback? onBack;
  final double topMinimum;
  final double topExtra;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        MorrowlyFrameGuard.topClearance(
          context,
          minimum: topMinimum,
          extra: topExtra,
        ),
        18,
        0,
      ),
      child: SizedBox(
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (onBack != null)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: onBack,
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 30,
                  ),
                  splashRadius: 22,
                  tooltip: 'Back',
                ),
              ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
            if (trailing != null)
              Align(alignment: Alignment.centerRight, child: trailing),
          ],
        ),
      ),
    );
  }
}

class CapsuleAssetTap extends StatelessWidget {
  const CapsuleAssetTap({
    super.key,
    required this.assetName,
    required this.width,
    required this.height,
    required this.onTap,
    this.semanticLabel,
    this.fit = BoxFit.fill,
  });

  final String assetName;
  final double width;
  final double height;
  final VoidCallback onTap;
  final String? semanticLabel;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Image.asset(
          assetName,
          width: width,
          height: height,
          fit: fit,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

class CapsuleGlowButton extends StatelessWidget {
  const CapsuleGlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width,
    this.icon,
    this.trailing,
  });

  final String label;
  final VoidCallback onPressed;
  final double? width;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 54,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFBC6DFF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}

class CapsuleMediaTile extends StatelessWidget {
  const CapsuleMediaTile({
    super.key,
    required this.snap,
    this.size = 86,
    this.onRemove,
    this.showMotionIndicator = true,
  });

  final CapsuleMemoryFragment snap;
  final double size;
  final VoidCallback? onRemove;
  final bool showMotionIndicator;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _CapsuleMediaCover(snap: snap),
            ),
          ),
          if (showMotionIndicator &&
              snap.fragmentKind == MemoryFragmentKind.motion)
            Center(
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0B6970).withValues(alpha: 0.86),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          if (onRemove != null)
            Positioned(
              top: -7,
              right: -7,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onRemove,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFBC6DFF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF271A2B),
                    size: 15,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CapsuleMediaCover extends StatelessWidget {
  const _CapsuleMediaCover({required this.snap});

  final CapsuleMemoryFragment snap;

  @override
  Widget build(BuildContext context) {
    if (!snap.isLocalFile) {
      return Image.asset(
        snap.sourcePath,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      );
    }

    if (snap.fragmentKind == MemoryFragmentKind.motion) {
      return const ColoredBox(color: Color(0xFF47334E));
    }

    return Image.file(
      File(snap.sourcePath),
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        return const ColoredBox(
          color: Color(0xFF47334E),
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Colors.white54,
              size: 26,
            ),
          ),
        );
      },
    );
  }
}

class CapsuleCoinAmount extends StatelessWidget {
  const CapsuleCoinAmount({super.key, required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          CapsuleArtwork.capsuleCoin,
          width: 18,
          height: 18,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(width: 4),
        Text(
          amount.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class CapsuleConfirmDialog extends StatelessWidget {
  const CapsuleConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 34),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 336),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 26),
          decoration: BoxDecoration(
            color: const Color(0xFF4B3653),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: const Offset(0, -18),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    CapsuleArtwork.dialogPrelude,
                    height: 82,
                    width: 226,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  height: 1.14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontSize: 14,
                  height: 1.36,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 26),
              if (actionLabel == 'Confirm')
                CapsuleAssetTap(
                  assetName: CapsuleArtwork.confirmButton,
                  width: 186,
                  height: 42,
                  semanticLabel: actionLabel,
                  onTap: onAction,
                )
              else
                CapsuleGlowButton(
                  label: actionLabel,
                  width: 186,
                  onPressed: onAction,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
