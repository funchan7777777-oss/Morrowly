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
                    const Text(
                      'Write down the content you want to publish ..',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ComposeField(
                      controller: _controller,
                      draft: _draft,
                      onChanged: (value) => setState(() => _draft = value),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Add photos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _PhotoPickerRow(
                      media: _media,
                      onAdd: _pickPhotos,
                      onRemove: (media) {
                        setState(() => _media.remove(media));
                      },
                    ),
                    const SizedBox(height: 142),
                    Center(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _submitting ? null : _submit,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 140),
                          opacity: _canSubmit && !_submitting ? 1 : 0.44,
                          child: Image.asset(
                            LifeSnippetAssets.release,
                            width: contentWidth * 0.78,
                            height: contentWidth * 0.78 * 108 / 568,
                            fit: BoxFit.fill,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          LifeTopBar(title: 'Post', onBack: () => Navigator.of(context).pop()),
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
    setState(() => _media.addAll(saved.take(4 - _media.length)));
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add text or at least one photo before posting.'),
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
      height: 222,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF4B3A50).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: 'Please enter',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.22),
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
                color: Colors.white.withValues(alpha: 0.28),
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
            width: 82,
            height: 82,
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
        if (media.length < 4)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onAdd,
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.18),
                  style: BorderStyle.solid,
                ),
              ),
              child: Icon(
                Icons.add_rounded,
                color: Colors.white.withValues(alpha: 0.32),
                size: 34,
              ),
            ),
          ),
      ],
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
              'Post submitted',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your snippet is waiting for background review. It will become visible only after approval.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.66),
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
