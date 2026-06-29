import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:morrowly/journeys/present_grounding/data/life_snippet_store.dart';
import 'package:morrowly/journeys/present_grounding/models/life_snippet_models.dart';
import 'package:morrowly/journeys/present_grounding/widgets/life_snippet_widgets.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';
import 'package:path_provider/path_provider.dart';

class LifeSnippetComposeScreen extends StatefulWidget {
  const LifeSnippetComposeScreen({super.key});

  @override
  State<LifeSnippetComposeScreen> createState() =>
      _LifeSnippetComposeScreenState();
}

class _LifeSnippetComposeScreenState extends State<LifeSnippetComposeScreen> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<LifeSnippetMedia> _media = [];
  String _draft = '';
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LifeSnippetStage(
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
                    minimum: 94,
                    extra: 26,
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
                      meta: '${_media.length}/1 added',
                    ),
                    const SizedBox(height: 12),
                    _PhotoPickerRow(
                      media: _media,
                      onAdd: _pickPhotos,
                      onRemove: (media) {
                        setState(() => _media.remove(media));
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
          LifeTopBar(
            title: 'New snippet',
            onBack: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  bool get _canSubmit => _draft.trim().isNotEmpty || _media.isNotEmpty;

  Future<void> _pickPhotos() async {
    final picked = await _picker.pickMultiImage(imageQuality: 88);
    if (picked.isEmpty) {
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    final saved = <LifeSnippetMedia>[];
    for (var index = 0; index < picked.length; index++) {
      final source = File(picked[index].path);
      final extension = picked[index].path.split('.').last;
      final fileName =
          'life-snippet-${DateTime.now().microsecondsSinceEpoch}-$index.$extension';
      final target = File('${directory.path}/$fileName');
      await source.copy(target.path);
      saved.add(
        LifeSnippetMedia(
          mediaKey:
              'local-photo-${DateTime.now().microsecondsSinceEpoch}-$index',
          path: target.path,
          kind: LifeSnippetMediaKind.localFile,
        ),
      );
    }

    if (!mounted) {
      return;
    }
    setState(() => _media.addAll(saved.take(1 - _media.length)));
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

    setState(() => _submitting = true);
    await LifeSnippetStore.instance.submitPostForReview(
      body: _draft,
      media: List.of(_media),
    );
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
                  'Release a Life Snippet',
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
    required this.media,
    required this.onAdd,
    required this.onRemove,
  });

  final List<LifeSnippetMedia> media;
  final VoidCallback onAdd;
  final ValueChanged<LifeSnippetMedia> onRemove;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final item in media)
          SizedBox(
            width: 92,
            height: 92,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: LifeMediaImage(media: item),
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
        if (media.isEmpty)
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7442A0), Color(0xFF3F3045)],
          ),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFBC6DFF).withValues(alpha: 0.28),
              blurRadius: 34,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 138,
              height: 96,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    LifeSnippetAssets.titleUnderline,
                    width: 126,
                    height: 44,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                  ),
                  Image.asset(
                    LifeSnippetAssets.compose,
                    width: 74,
                    height: 74,
                    filterQuality: FilterQuality.high,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sent for review',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your Life Snippet was saved locally and will appear in the feed only after approval.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.66),
                fontSize: 13,
                height: 1.36,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
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
                  'Done',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
