import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:morrowly/journeys/present_grounding/data/keeper_memory_store.dart';
import 'package:morrowly/journeys/present_grounding/models/keeper_memory_thread.dart';
import 'package:morrowly/journeys/present_grounding/widgets/keeper_memory_widgets.dart';
import 'package:morrowly/shared/economy/morrowly_wallet_screen.dart';
import 'package:morrowly/shared/economy/morrowly_wallet_store.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';
import 'package:morrowly/shared/moderation/morrowly_content_safety.dart';
import 'package:morrowly/shared/widgets/morrowly_safety_notice.dart';
import 'package:path_provider/path_provider.dart';

class MemoryReleaseScreen extends StatefulWidget {
  const MemoryReleaseScreen({super.key});

  @override
  State<MemoryReleaseScreen> createState() => _MemoryReleaseScreenState();
}

class _MemoryReleaseScreenState extends State<MemoryReleaseScreen> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<MemoryAttachment> _attachments = [];
  String _draft = '';
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MorrowlyMemoryStage(
      resizeForKeyboard: true,
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = MorrowlyFrameGuard.contentWidth(
                constraints.maxWidth,
                maxWidth: 430,
                phoneGutter: 18,
              );
              final side = (constraints.maxWidth - contentWidth) / 2;
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  side,
                  MorrowlyFrameGuard.topClearance(
                    context,
                    minimum: 86,
                    extra: 18,
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
                    const _ComposeHeader(),
                    const SizedBox(height: 16),
                    _ComposeField(
                      controller: _controller,
                      draft: _draft,
                      onChanged: (value) => setState(() => _draft = value),
                    ),
                    const SizedBox(height: 20),
                    _ComposeSectionHeader(
                      title: 'Photos',
                      meta: '${_attachments.length}/1 added',
                    ),
                    const SizedBox(height: 12),
                    _PhotoPickerRow(
                      attachments: _attachments,
                      onAdd: _pickPhotos,
                      onRemove: (attachment) {
                        setState(() => _attachments.remove(attachment));
                      },
                    ),
                    const SizedBox(height: 76),
                    _SubmitReviewButton(
                      enabled: _canSubmit && !_submitting,
                      loading: _submitting,
                      onTap: _submit,
                    ),
                  ],
                ),
              );
            },
          ),
          _ComposeTopBar(onBack: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }

  bool get _canSubmit => _draft.trim().isNotEmpty || _attachments.isNotEmpty;

  Future<void> _pickPhotos() async {
    if (_attachments.isNotEmpty) {
      return;
    }

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.58),
      builder: (_) => const _PhotoSourceSheet(),
    );
    if (source == null || !mounted) {
      return;
    }

    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (picked == null) {
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    final sourceFile = File(picked.path);
    final extension = picked.path.contains('.')
        ? picked.path.split('.').last
        : 'jpg';
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final fileName = 'memory-seal-$timestamp.$extension';
    final target = File('${directory.path}/$fileName');
    await sourceFile.copy(target.path);
    final saved = MemoryAttachment(
      attachmentId: 'local-photo-$timestamp',
      sourcePath: target.path,
      sourceKind: MemoryAttachmentSource.localShelfFile,
    );

    if (!mounted) {
      return;
    }
    setState(() => _attachments.add(saved));
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Write a note or add a photo before submitting.'),
          backgroundColor: lifePanel,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
      return;
    }

    try {
      if (_draft.trim().isNotEmpty) {
        MorrowlyContentSafety.ensureText(
          _draft,
          surface: MorrowlySafetySurface.publicMemorySeal,
        );
      }
    } on MorrowlyContentSafetyException catch (issue) {
      await showMorrowlySafetyNotice(context, issue);
      return;
    }
    if (!mounted) {
      return;
    }

    final canSpend = await confirmAndSpendMorrowlyCoins(
      context,
      cost: MorrowlyCoinCosts.releaseMemorySeal,
    );
    if (!canSpend || !mounted) {
      return;
    }

    setState(() => _submitting = true);
    try {
      await KeeperMemoryStore.instance.submitPostForReview(
        noteLine: _draft,
        attachments: List.of(_attachments),
      );
    } on MorrowlyContentSafetyException catch (issue) {
      if (mounted) {
        setState(() => _submitting = false);
        await showMorrowlySafetyNotice(context, issue);
      }
      return;
    }
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.62),
      builder: (_) => const _ReviewSubmittedDialog(),
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _ComposeTopBar extends StatelessWidget {
  const _ComposeTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = MorrowlyFrameGuard.contentWidth(
          constraints.maxWidth,
          maxWidth: 430,
          phoneGutter: 18,
        );
        final side = (constraints.maxWidth - contentWidth) / 2;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            side,
            MorrowlyFrameGuard.topClearance(context, minimum: 42, extra: -10),
            side,
            0,
          ),
          child: SizedBox(
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: onBack,
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    tooltip: 'Back',
                  ),
                ),
                const Text(
                  'New memory',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
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
  }
}

class _ComposeHeader extends StatelessWidget {
  const _ComposeHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: lifePanel.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: lifePurple.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Release a Memory Seal',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Shared moments appear after review.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.58),
                    fontSize: 12,
                    height: 1.28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComposeSectionHeader extends StatelessWidget {
  const _ComposeSectionHeader({required this.title, required this.meta});

  final String title;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          meta,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.42),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ComposeField extends StatelessWidget {
  const _ComposeField({
    required this.controller,
    required this.draft,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String draft;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF4A3852).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: null,
            expands: true,
            inputFormatters: [LengthLimitingTextInputFormatter(100)],
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.42,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: 'Share a small moment, wish, or memory...',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.32),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              border: InputBorder.none,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Text(
              '${draft.length}/100',
              style: TextStyle(
                color: draft.length >= 90
                    ? const Color(0xFFFFC7E5)
                    : Colors.white.withValues(alpha: 0.34),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoPickerRow extends StatelessWidget {
  const _PhotoPickerRow({
    required this.attachments,
    required this.onAdd,
    required this.onRemove,
  });

  final List<MemoryAttachment> attachments;
  final VoidCallback onAdd;
  final ValueChanged<MemoryAttachment> onRemove;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final item in attachments)
          SizedBox(
            width: 92,
            height: 92,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: MemoryAttachmentImage(attachment: item),
                  ),
                ),
                Positioned(
                  top: -7,
                  right: -7,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onRemove(item),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Color(0xFF9E55E8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (attachments.isEmpty)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onAdd,
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.16),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_rounded,
                    color: Colors.white.withValues(alpha: 0.42),
                    size: 30,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.42),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _PhotoSourceSheet extends StatelessWidget {
  const _PhotoSourceSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF4D3A55),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add photo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _PhotoSourceTile(
                      icon: Icons.photo_camera_rounded,
                      label: 'Camera',
                      onTap: () =>
                          Navigator.of(context).pop(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PhotoSourceTile(
                      icon: Icons.photo_library_rounded,
                      label: 'Album',
                      onTap: () =>
                          Navigator.of(context).pop(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
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

class _PhotoSourceTile extends StatelessWidget {
  const _PhotoSourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          color: lifePurple.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitReviewButton extends StatelessWidget {
  const _SubmitReviewButton({
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 58,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFFC776FF), Color(0xFFA960FF)],
                )
              : null,
          color: enabled ? null : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: enabled
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.08),
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: lifePurple.withValues(alpha: 0.24),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ]
              : null,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: loading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.6,
                    color: Colors.white,
                  ),
                )
              : Row(
                  key: const ValueKey('label'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.task_alt_rounded,
                      color: enabled
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.34),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      enabled ? 'Submit for review' : 'Add text or photos',
                      style: TextStyle(
                        color: enabled
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.34),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ReviewSubmittedDialog extends StatelessWidget {
  const _ReviewSubmittedDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 26),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7A42A7), Color(0xFF51385D), Color(0xFF342637)],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A0D1F).withValues(alpha: 0.38),
              blurRadius: 38,
              offset: const Offset(0, 22),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 13),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB66DFF).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          MorrowlyAssetKit.titleUnderline,
                          width: 54,
                          height: 25,
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.high,
                        ),
                        Image.asset(
                          MorrowlyAssetKit.compose,
                          width: 38,
                          height: 38,
                          filterQuality: FilterQuality.high,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFFD6F6,
                            ).withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: const Color(
                                0xFFFFD6F6,
                              ).withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Text(
                            'UNDER REVIEW',
                            style: TextStyle(
                              color: Color(0xFFFFD6F6),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Memory seal submitted',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Your memory seal is waiting for review. It will enter the public shelf only after approval.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.74),
                fontSize: 13,
                height: 1.42,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 18),
            const _ReviewStageRail(),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2E2432).withValues(alpha: 0.58),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_clock_rounded,
                    color: Colors.white.withValues(alpha: 0.72),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'It is saved locally for now and will not appear in public feeds until review passes.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.62),
                        fontSize: 12,
                        height: 1.34,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                height: 50,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFFC776FF), Color(0xFF9E5CFF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: lifePurple.withValues(alpha: 0.22),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Text(
                  'Return to Morrowly',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewStageRail extends StatelessWidget {
  const _ReviewStageRail();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const _ReviewStageDot(
            icon: Icons.check_rounded,
            label: 'Released',
            active: true,
          ),
          _ReviewStageLine(color: lifePurple.withValues(alpha: 0.65)),
          const _ReviewStageDot(
            icon: Icons.policy_rounded,
            label: 'Reviewing',
            active: true,
          ),
          _ReviewStageLine(color: Colors.white.withValues(alpha: 0.18)),
          const _ReviewStageDot(
            icon: Icons.visibility_rounded,
            label: 'Visible',
            active: false,
          ),
        ],
      ),
    );
  }
}

class _ReviewStageDot extends StatelessWidget {
  const _ReviewStageDot({
    required this.icon,
    required this.label,
    required this.active,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active
                  ? lifePurple.withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: Colors.white.withValues(alpha: active ? 1 : 0.46),
              size: 18,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: active ? 0.82 : 0.42),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewStageLine extends StatelessWidget {
  const _ReviewStageLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 22),
        color: color,
      ),
    );
  }
}
