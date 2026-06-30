import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:morrowly/journeys/present_grounding/models/keeper_memory_thread.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';
import 'package:morrowly/shared/widgets/morrowly_avatar_placeholder.dart';

abstract final class MorrowlyAssetKit {
  static const placeholderAvatar =
      'assets/morrowly_art/ui/morrowly_ui_memoir.png';
  static const release = 'assets/morrowly_art/ui/morrowly_ui_daybreak.png';
  static const popular = 'assets/morrowly_art/ui/morrowly_ui_heirloom.png';
  static const followed = 'assets/morrowly_art/ui/morrowly_ui_friendship.png';
  static const followIcon = 'assets/morrowly_art/ui/morrowly_ui_portal.png';
  static const followPlain = 'assets/morrowly_art/ui/morrowly_ui_snapshot.png';
  static const send = 'assets/morrowly_art/ui/morrowly_ui_comet.png';
  static const more = 'assets/morrowly_art/ui/morrowly_ui_calendar.png';
  static const comment = 'assets/morrowly_art/ui/morrowly_ui_treasure.png';
  static const likeOutline = 'assets/morrowly_art/ui/morrowly_ui_starlight.png';
  static const likeFilled = 'assets/morrowly_art/ui/morrowly_ui_skylink.png';
  static const compose = 'assets/morrowly_art/ui/morrowly_ui_nova.png';
  static const block = 'assets/morrowly_art/ui/morrowly_ui_confession.png';
  static const confirm = 'assets/morrowly_art/ui/morrowly_ui_flashback.png';
  static const report = 'assets/morrowly_art/ui/morrowly_ui_outbox.png';
  static const goNow = 'assets/morrowly_art/ui/morrowly_ui_sundial.png';
  static const titleUnderline = 'assets/morrowly_art/ui/morrowly_ui_thread.png';
  static const empty = 'assets/morrowly_art/ui/morrowly_ui_reminder.png';
}

const lifePurple = Color(0xFFB66DFF);
const lifeDeep = Color(0xFF342637);
const lifePanel = Color(0xFF514058);
const lifePanelSoft = Color(0xFF60446A);

class MorrowlyMemoryStage extends StatelessWidget {
  const MorrowlyMemoryStage({
    super.key,
    required this.child,
    this.resizeForKeyboard = false,
  });

  final Widget child;
  final bool resizeForKeyboard;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        resizeToAvoidBottomInset: resizeForKeyboard,
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: lifeDeep,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF8442B1), Color(0xFF5B3C66), lifeDeep],
              stops: [0, 0.48, 1],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class MorrowlyMemoryTopBar extends StatelessWidget {
  const MorrowlyMemoryTopBar({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
    this.topMinimum = 48,
    this.topExtra = 0,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final double topMinimum;
  final double topExtra;

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
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (onBack != null)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: onBack,
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                  tooltip: 'Back',
                ),
              ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
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

ImageProvider<Object> keeperAvatarProvider(KeeperProfile user) {
  if (user.localPortraitPath.isNotEmpty) {
    return FileImage(File(user.localPortraitPath));
  }
  return AssetImage(
    user.portraitAsset.isEmpty
        ? MorrowlyAssetKit.placeholderAvatar
        : user.portraitAsset,
  );
}

bool usesKeeperPlaceholderAvatar(KeeperProfile user) {
  return user.localPortraitPath.isEmpty &&
      (user.portraitAsset.isEmpty ||
          user.portraitAsset == MorrowlyAssetKit.placeholderAvatar);
}

class KeeperAvatar extends StatelessWidget {
  const KeeperAvatar({
    super.key,
    required this.user,
    required this.radius,
    this.onTap,
  });

  final KeeperProfile user;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final avatar = usesKeeperPlaceholderAvatar(user)
        ? MorrowlyAvatarPlaceholder(radius: radius, label: user.publicName)
        : CircleAvatar(
            radius: radius,
            backgroundColor: Colors.white.withValues(alpha: 0.16),
            backgroundImage: keeperAvatarProvider(user),
          );

    if (onTap == null) {
      return avatar;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: avatar,
    );
  }
}

class KeeperLinkButton extends StatelessWidget {
  const KeeperLinkButton({
    super.key,
    required this.status,
    required this.onPressed,
    this.compact = true,
  });

  final KeeperLinkState status;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (status == KeeperLinkState.requested) {
      return _TextPill(
        label: 'Requested',
        width: compact ? 102 : 128,
        height: compact ? 34 : 44,
        foreground: Colors.white.withValues(alpha: 0.78),
        background: Colors.white.withValues(alpha: 0.13),
        border: Colors.white.withValues(alpha: 0.16),
      );
    }

    final asset = switch (status) {
      KeeperLinkState.following => MorrowlyAssetKit.followed,
      KeeperLinkState.none =>
        compact ? MorrowlyAssetKit.followIcon : MorrowlyAssetKit.followPlain,
      KeeperLinkState.requested => MorrowlyAssetKit.followIcon,
    };
    final width = compact ? 88.0 : 132.0;
    final height = compact ? 35.0 : 48.0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Image.asset(
        asset,
        width: width,
        height: height,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class MemoryAttachmentImage extends StatelessWidget {
  const MemoryAttachmentImage({
    super.key,
    required this.attachment,
    this.fit = BoxFit.cover,
  });

  final MemoryAttachment attachment;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (attachment.sourceKind == MemoryAttachmentSource.localShelfFile) {
      return Image.file(File(attachment.sourcePath), fit: fit);
    }
    return Image.asset(
      attachment.sourcePath,
      fit: fit,
      filterQuality: FilterQuality.high,
    );
  }
}

class MemoryGlyphButton extends StatelessWidget {
  const MemoryGlyphButton({
    super.key,
    required this.asset,
    required this.onTap,
    required this.semanticLabel,
    this.size = 24,
  });

  final String asset;
  final VoidCallback onTap;
  final String semanticLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Image.asset(
          asset,
          width: size,
          height: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

Future<void> showMutualKeeperGateDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.58),
    builder: (context) => const _RelationshipGateDialog(),
  );
}

class _TextPill extends StatelessWidget {
  const _TextPill({
    required this.label,
    required this.width,
    required this.height,
    required this.foreground,
    required this.background,
    required this.border,
  });

  final String label;
  final double width;
  final double height;
  final Color foreground;
  final Color background;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _RelationshipGateDialog extends StatelessWidget {
  const _RelationshipGateDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        decoration: BoxDecoration(
          color: const Color(0xFF4A3852),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.32),
              blurRadius: 34,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              MorrowlyAssetKit.compose,
              width: 72,
              height: 72,
              filterQuality: FilterQuality.high,
            ),
            const SizedBox(height: 12),
            const Text(
              'Mutual follow required',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'For safety, chat and video calls are only available after both people have accepted each other.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.64),
                fontSize: 13,
                height: 1.36,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: Image.asset(
                MorrowlyAssetKit.goNow,
                width: 178,
                height: 40,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
