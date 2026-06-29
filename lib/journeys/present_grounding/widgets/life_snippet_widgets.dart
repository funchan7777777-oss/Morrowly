import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:morrowly/journeys/present_grounding/models/life_snippet_models.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';

abstract final class LifeSnippetAssets {
  static const release = 'assets/images/Daybreak.png';
  static const popular = 'assets/images/Heirloom.png';
  static const followed = 'assets/images/Friendship.png';
  static const followIcon = 'assets/images/Portal.png';
  static const followPlain = 'assets/images/Snapshot.png';
  static const send = 'assets/images/Comet.png';
  static const more = 'assets/images/Calendar.png';
  static const comment = 'assets/images/Treasure.png';
  static const likeOutline = 'assets/images/Starlight.png';
  static const likeFilled = 'assets/images/Skylink.png';
  static const compose = 'assets/images/Nova.png';
  static const block = 'assets/images/Confession.png';
  static const confirm = 'assets/images/Flashback.png';
  static const report = 'assets/images/Outbox.png';
  static const goNow = 'assets/images/Sundial.png';
  static const titleUnderline = 'assets/images/Thread.png';
}

const lifePurple = Color(0xFFB66DFF);
const lifeDeep = Color(0xFF342637);
const lifePanel = Color(0xFF514058);
const lifePanelSoft = Color(0xFF60446A);

class LifeSnippetStage extends StatelessWidget {
  const LifeSnippetStage({
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

class LifeTopBar extends StatelessWidget {
  const LifeTopBar({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        MorrowlyFrameGuard.topClearance(context, minimum: 48),
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

ImageProvider<Object> lifeAvatarProvider(LifeSnippetUser user) {
  if (user.avatarLocalPath.isNotEmpty) {
    return FileImage(File(user.avatarLocalPath));
  }
  return AssetImage(user.avatarAsset);
}

class LifeAvatar extends StatelessWidget {
  const LifeAvatar({
    super.key,
    required this.user,
    required this.radius,
    this.onTap,
  });

  final LifeSnippetUser user;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white.withValues(alpha: 0.16),
      backgroundImage: lifeAvatarProvider(user),
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

class LifeFollowButton extends StatelessWidget {
  const LifeFollowButton({
    super.key,
    required this.status,
    required this.onPressed,
    this.compact = true,
  });

  final LifeFollowStatus status;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (status == LifeFollowStatus.requested) {
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
      LifeFollowStatus.following => LifeSnippetAssets.followed,
      LifeFollowStatus.none =>
        compact ? LifeSnippetAssets.followIcon : LifeSnippetAssets.followPlain,
      LifeFollowStatus.requested => LifeSnippetAssets.followIcon,
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

class LifeMediaImage extends StatelessWidget {
  const LifeMediaImage({
    super.key,
    required this.media,
    this.fit = BoxFit.cover,
  });

  final LifeSnippetMedia media;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (media.kind == LifeSnippetMediaKind.localFile) {
      return Image.file(File(media.path), fit: fit);
    }
    return Image.asset(media.path, fit: fit, filterQuality: FilterQuality.high);
  }
}

class LifeIconAssetButton extends StatelessWidget {
  const LifeIconAssetButton({
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

Future<void> showLifeRelationshipGateDialog(BuildContext context) {
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
              LifeSnippetAssets.compose,
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
                LifeSnippetAssets.goNow,
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
