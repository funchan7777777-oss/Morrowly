import 'package:flutter/material.dart';
import 'package:morrowly/shared/moderation/morrowly_moderation_store.dart';

enum MorrowlyModerationResult { reported, blocked }

enum _MorrowlyModerationAction { report, block }

const _preludeAsset = 'assets/images/Prelude.png';
const _reportAsset = 'assets/images/Outbox.png';
const _blockAsset = 'assets/images/Confession.png';
const _confirmAsset = 'assets/images/Flashback.png';

Future<MorrowlyModerationResult?> showMorrowlyModerationFlow({
  required BuildContext context,
  required MorrowlyModerationTarget target,
  MorrowlyModerationStore? store,
  Future<void> Function(MorrowlyReportReason reason)? onReport,
  Future<void> Function()? onBlock,
}) async {
  final moderationStore = store ?? MorrowlyModerationStore.instance;
  await moderationStore.load();
  if (!context.mounted) {
    return null;
  }

  final action = await showDialog<_MorrowlyModerationAction>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.62),
    builder: (_) => _ModerationActionDialog(target: target),
  );
  if (action == null || !context.mounted) {
    return null;
  }

  if (action == _MorrowlyModerationAction.report) {
    final reason = await showDialog<MorrowlyReportReason>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.62),
      builder: (_) => _ReportReasonDialog(target: target),
    );
    if (reason == null) {
      return null;
    }

    final reportHandler = onReport;
    if (reportHandler == null) {
      await moderationStore.reportContent(target: target, reason: reason);
    } else {
      await reportHandler(reason);
    }
    if (context.mounted) {
      await showDialog<void>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.62),
        builder: (_) => _ModerationSuccessDialog(
          title: 'Report sent',
          message:
              'Thanks for helping keep Morrowly gentle. This ${target.contentLabel} is now hidden from your local list.',
        ),
      );
    }
    return MorrowlyModerationResult.reported;
  }

  final blockHandler = onBlock;
  if (blockHandler == null) {
    await moderationStore.blockAuthor(target);
  } else {
    await blockHandler();
  }
  if (context.mounted) {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.62),
      builder: (_) => _ModerationSuccessDialog(
        title: 'Blocked',
        message:
            '${target.authorName} and their capsules, messages, and chats are now hidden on this device.',
      ),
    );
  }
  return MorrowlyModerationResult.blocked;
}

class _ModerationActionDialog extends StatefulWidget {
  const _ModerationActionDialog({required this.target});

  final MorrowlyModerationTarget target;

  @override
  State<_ModerationActionDialog> createState() =>
      _ModerationActionDialogState();
}

class _ModerationActionDialogState extends State<_ModerationActionDialog> {
  _MorrowlyModerationAction _selectedAction = _MorrowlyModerationAction.report;

  @override
  Widget build(BuildContext context) {
    return _MorrowlyDialogShell(
      title: 'Please select',
      actionAsset: _confirmAsset,
      actionLabel: 'Confirm',
      onAction: () => Navigator.of(context).pop(_selectedAction),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModerationChoiceTile(
            assetPath: _reportAsset,
            fallbackLabel: 'Report',
            selected: _selectedAction == _MorrowlyModerationAction.report,
            onTap: () {
              setState(
                () => _selectedAction = _MorrowlyModerationAction.report,
              );
            },
          ),
          const SizedBox(height: 14),
          _ModerationChoiceTile(
            assetPath: _blockAsset,
            fallbackLabel: 'Block',
            selected: _selectedAction == _MorrowlyModerationAction.block,
            onTap: () {
              setState(() => _selectedAction = _MorrowlyModerationAction.block);
            },
          ),
        ],
      ),
    );
  }
}

class _ReportReasonDialog extends StatefulWidget {
  const _ReportReasonDialog({required this.target});

  final MorrowlyModerationTarget target;

  @override
  State<_ReportReasonDialog> createState() => _ReportReasonDialogState();
}

class _ReportReasonDialogState extends State<_ReportReasonDialog> {
  MorrowlyReportReason? _selectedReason;

  @override
  Widget build(BuildContext context) {
    return _MorrowlyDialogShell(
      title: 'Report reason',
      message:
          'Choose the reason that best matches this ${widget.target.contentLabel}.',
      actionAsset: _reportAsset,
      actionLabel: 'Report',
      actionEnabled: _selectedReason != null,
      onAction: () {
        final reason = _selectedReason;
        if (reason == null) {
          return;
        }
        Navigator.of(context).pop(reason);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final reason in MorrowlyReportReason.values) ...[
            _ReasonTile(
              reason: reason,
              selected: _selectedReason == reason,
              onTap: () => setState(() => _selectedReason = reason),
            ),
            if (reason != MorrowlyReportReason.values.last)
              const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _ModerationSuccessDialog extends StatelessWidget {
  const _ModerationSuccessDialog({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _MorrowlyDialogShell(
      title: title,
      message: message,
      actionAsset: _confirmAsset,
      actionLabel: 'Confirm',
      onAction: () => Navigator.of(context).pop(),
      child: const SizedBox.shrink(),
    );
  }
}

class _MorrowlyDialogShell extends StatelessWidget {
  const _MorrowlyDialogShell({
    required this.title,
    required this.child,
    required this.actionAsset,
    required this.actionLabel,
    required this.onAction,
    this.message,
    this.actionEnabled = true,
  });

  final String title;
  final String? message;
  final Widget child;
  final String actionAsset;
  final String actionLabel;
  final VoidCallback onAction;
  final bool actionEnabled;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 34),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 336),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 26),
        decoration: BoxDecoration(
          color: const Color(0xFF4B3653),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.34),
              blurRadius: 30,
              offset: const Offset(0, 16),
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
                  _preludeAsset,
                  width: 226,
                  height: 82,
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
                fontSize: 22,
                height: 1.12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 14),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontSize: 14,
                  height: 1.36,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ],
            if (child is! SizedBox) ...[const SizedBox(height: 22), child],
            const SizedBox(height: 26),
            _AssetDialogButton(
              assetPath: actionAsset,
              semanticLabel: actionLabel,
              enabled: actionEnabled,
              onTap: onAction,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModerationChoiceTile extends StatelessWidget {
  const _ModerationChoiceTile({
    required this.assetPath,
    required this.fallbackLabel,
    required this.selected,
    required this.onTap,
  });

  final String assetPath;
  final String fallbackLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: fallbackLabel,
      selected: selected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          scale: selected ? 1 : 0.985,
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              Image.asset(
                assetPath,
                width: double.infinity,
                height: 58,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 160),
                opacity: selected ? 1 : 0,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _SelectionMark(selected: selected),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.reason,
    required this.selected,
    required this.onTap,
  });

  final MorrowlyReportReason reason;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: reason.label,
      selected: selected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF614665)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? const Color(0xFFD853D6).withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.04),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: Colors.white.withValues(alpha: selected ? 0.96 : 0.64),
                size: 19,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  reason.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: selected ? 0.96 : 0.74,
                    ),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _SelectionMark(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionMark extends StatelessWidget {
  const _SelectionMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE646D4) : const Color(0xFF382B3E),
        shape: BoxShape.circle,
      ),
      child: selected
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 23)
          : null,
    );
  }
}

class _AssetDialogButton extends StatelessWidget {
  const _AssetDialogButton({
    required this.assetPath,
    required this.semanticLabel,
    required this.onTap,
    required this.enabled,
  });

  final String assetPath;
  final String semanticLabel;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.45,
          child: Image.asset(
            assetPath,
            width: 186,
            height: 42,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
