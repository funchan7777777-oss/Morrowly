import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:morrowly/journeys/time_capsule/data/capsule_square_seed.dart';
import 'package:morrowly/journeys/time_capsule/models/capsule_chronicle.dart';
import 'package:morrowly/journeys/time_capsule/view/capsule_preview_screen.dart';
import 'package:morrowly/journeys/time_capsule/view/custom_opening_time_screen.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_stage.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_widgets.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';
import 'package:morrowly/shared/moderation/morrowly_content_safety.dart';
import 'package:morrowly/shared/widgets/morrowly_safety_notice.dart';
import 'package:path_provider/path_provider.dart';

class CapsuleEditorScreen extends StatefulWidget {
  const CapsuleEditorScreen({
    super.key,
    required this.sealFormat,
    required this.coinBalance,
  });

  final CapsuleSealFormat sealFormat;
  final int coinBalance;

  @override
  State<CapsuleEditorScreen> createState() => _CapsuleEditorScreenState();
}

class _CapsuleEditorScreenState extends State<CapsuleEditorScreen> {
  final ImagePicker _mediaPicker = ImagePicker();
  final TextEditingController _messageController = TextEditingController();
  late CapsuleDraftLedger _draft;
  String _selectedPresetKey = 'one-year';
  bool _pickingMedia = false;

  @override
  void initState() {
    super.initState();
    final presets = CapsuleSquareSeed.openingPresets(DateTime.now());
    _draft = CapsuleDraftLedger(
      sealFormat: widget.sealFormat,
      sealedMessage: '',
      memoryFragments: const [],
      unlocksAt: presets[3].unlocksAt,
      shelfScope: CapsuleShelfScope.publicSquare,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CapsuleStage(
      resizeForKeyboard: true,
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
                    minimum: 102,
                    extra: 36,
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
                      'Write down the content you want to seal ..',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _MessageField(
                      controller: _messageController,
                      onChanged: (value) {
                        setState(() {
                          _draft = _draft.copyWith(sealedMessage: value);
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Add photos/videos (optional)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _MediaStrip(
                      selected: _draft.memoryFragments,
                      picking: _pickingMedia,
                      onAdd: _showMediaPicker,
                      onRemove: (snap) {
                        setState(() {
                          _draft = _draft.copyWith(
                            memoryFragments: [
                              for (final item in _draft.memoryFragments)
                                if (item.fragmentId != snap.fragmentId) item,
                            ],
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Select opening time',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Automatically turn on when the time is up.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.28),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _PresetGrid(
                      selectedKey: _selectedPresetKey,
                      unlocksAt: _draft.unlocksAt,
                      onPreset: _selectPreset,
                      onCustom: _openCustomTime,
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: CapsuleAssetTap(
                        assetName: CapsuleArtwork.sealedCapsules,
                        width: contentWidth * 0.84,
                        height: 54,
                        semanticLabel: 'Sealed capsules',
                        onTap: _openPreview,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: Text(
                        'After sealing, the content will be encrypted and protected, and can only be viewed at the opening time.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.34),
                          fontSize: 11,
                          height: 1.28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          CapsuleTopBar(
            title: 'Edit Capsule',
            onBack: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _selectPreset(CapsuleOpeningPreset preset) {
    setState(() {
      _selectedPresetKey = preset.presetId;
      _draft = _draft.copyWith(unlocksAt: preset.unlocksAt);
    });
  }

  Future<void> _openCustomTime() async {
    final selected = await Navigator.of(context).push<DateTime>(
      MaterialPageRoute(
        builder: (_) => CustomOpeningTimeScreen(initialTime: _draft.unlocksAt),
      ),
    );
    if (selected == null || !mounted) {
      return;
    }
    setState(() {
      _selectedPresetKey = 'custom';
      _draft = _draft.copyWith(unlocksAt: selected);
    });
  }

  Future<void> _showMediaPicker() async {
    if (_pickingMedia || _draft.memoryFragments.length >= 6) {
      return;
    }

    FocusScope.of(context).unfocus();
    final action = await showModalBottomSheet<_MediaPickAction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.52),
      builder: (context) =>
          _MediaPickerSheet(remainingSlots: 6 - _draft.memoryFragments.length),
    );
    if (action == null || !mounted) {
      return;
    }

    await _pickMedia(action);
  }

  Future<void> _pickMedia(_MediaPickAction action) async {
    final remainingSlots = 6 - _draft.memoryFragments.length;
    if (remainingSlots <= 0) {
      return;
    }

    setState(() => _pickingMedia = true);
    try {
      final pickedFiles = await _pickFilesForAction(action, remainingSlots);
      if (pickedFiles.isEmpty) {
        return;
      }

      final kind = _kindForAction(action);
      final snaps = <CapsuleMemoryFragment>[];
      for (final pickedFile in pickedFiles.take(remainingSlots)) {
        final savedPath = await _copyMediaIntoLocalShelf(
          sourcePath: pickedFile.path,
          fragmentKind: kind,
        );
        final stamp = DateTime.now().microsecondsSinceEpoch;
        snaps.add(
          CapsuleMemoryFragment(
            fragmentId: 'local-${kind.name}-$stamp-${snaps.length}',
            sourcePath: savedPath,
            fragmentKind: kind,
            captionTrace: kind == MemoryFragmentKind.motion
                ? 'Local video'
                : 'Local photo',
            isLocalFile: true,
          ),
        );
      }

      if (!mounted || snaps.isEmpty) {
        return;
      }
      setState(() {
        _draft = _draft.copyWith(
          memoryFragments: [
            ..._draft.memoryFragments,
            ...snaps,
          ].take(6).toList(),
        );
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showNotice(
        title: 'Media unavailable',
        message:
            'Morrowly could not open this photo/video source. Check photo, camera, or microphone access, then try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _pickingMedia = false);
      }
    }
  }

  Future<List<XFile>> _pickFilesForAction(
    _MediaPickAction action,
    int limit,
  ) async {
    switch (action) {
      case _MediaPickAction.galleryPhotos:
        return _mediaPicker.pickMultiImage(
          maxWidth: 2000,
          imageQuality: 88,
          limit: limit,
        );
      case _MediaPickAction.galleryVideos:
        return _mediaPicker.pickMultiVideo(limit: limit);
      case _MediaPickAction.cameraPhoto:
        final picked = await _mediaPicker.pickImage(
          source: ImageSource.camera,
          maxWidth: 2000,
          imageQuality: 88,
        );
        return picked == null ? const [] : [picked];
      case _MediaPickAction.cameraVideo:
        final picked = await _mediaPicker.pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(minutes: 5),
        );
        return picked == null ? const [] : [picked];
    }
  }

  MemoryFragmentKind _kindForAction(_MediaPickAction action) {
    switch (action) {
      case _MediaPickAction.galleryPhotos:
      case _MediaPickAction.cameraPhoto:
        return MemoryFragmentKind.still;
      case _MediaPickAction.galleryVideos:
      case _MediaPickAction.cameraVideo:
        return MemoryFragmentKind.motion;
    }
  }

  Future<String> _copyMediaIntoLocalShelf({
    required String sourcePath,
    required MemoryFragmentKind fragmentKind,
  }) async {
    final directory = await getApplicationSupportDirectory();
    final fragmentShelf = Directory(
      '${directory.path}/morrowly_capsule_fragments',
    );
    if (!fragmentShelf.existsSync()) {
      fragmentShelf.createSync(recursive: true);
    }

    final extension = _extensionFor(sourcePath, fragmentKind);
    final prefix = fragmentKind == MemoryFragmentKind.motion
        ? 'video'
        : 'photo';
    final filename =
        'morrowly_capsule_${prefix}_${DateTime.now().microsecondsSinceEpoch}.$extension';
    final copiedFile = await File(
      sourcePath,
    ).copy('${fragmentShelf.path}/$filename');
    return copiedFile.path;
  }

  String _extensionFor(String sourcePath, MemoryFragmentKind kind) {
    final filename = sourcePath.split(Platform.pathSeparator).last;
    final dotIndex = filename.lastIndexOf('.');
    if (dotIndex >= 0 && dotIndex < filename.length - 1) {
      return filename.substring(dotIndex + 1).toLowerCase();
    }
    return kind == MemoryFragmentKind.motion ? 'mov' : 'jpg';
  }

  Future<void> _openPreview() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      _showNotice(
        title: 'Write a few words',
        message: 'A capsule needs at least one line before it can be sealed.',
      );
      return;
    }
    try {
      MorrowlyContentSafety.ensureText(
        message,
        surface: MorrowlySafetySurface.publicCapsule,
      );
    } on MorrowlyContentSafetyException catch (issue) {
      await showMorrowlySafetyNotice(context, issue);
      return;
    }
    if (!mounted) {
      return;
    }
    final result = await Navigator.of(context).push<PublicCapsuleSeal>(
      MaterialPageRoute(
        builder: (_) => CapsulePreviewScreen(
          draft: _draft.copyWith(sealedMessage: message),
          coinBalance: widget.coinBalance,
        ),
      ),
    );
    if (result != null && mounted) {
      Navigator.of(context).pop(result);
    }
  }

  void _showNotice({required String title, required String message}) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.48),
      builder: (context) => CapsuleConfirmDialog(
        title: title,
        message: message,
        actionLabel: 'Keep editing',
        onAction: () => Navigator.of(context).pop(),
      ),
    );
  }
}

enum _MediaPickAction { galleryPhotos, galleryVideos, cameraPhoto, cameraVideo }

class _MessageField extends StatelessWidget {
  const _MessageField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 188,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF4E4053),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF8E5CA2).withValues(alpha: 0.7),
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLength: 100,
        maxLines: null,
        expands: true,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          height: 1.35,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: 'Write the line future you should find',
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          border: InputBorder.none,
          counterStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.42),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _MediaStrip extends StatelessWidget {
  const _MediaStrip({
    required this.selected,
    required this.picking,
    required this.onAdd,
    required this.onRemove,
  });

  final List<CapsuleMemoryFragment> selected;
  final bool picking;
  final VoidCallback onAdd;
  final ValueChanged<CapsuleMemoryFragment> onRemove;

  @override
  Widget build(BuildContext context) {
    const tileSize = 76.0;
    return SizedBox(
      height: tileSize + 8,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final snap in selected) ...[
            CapsuleMediaTile(
              snap: snap,
              size: tileSize,
              onRemove: () => onRemove(snap),
            ),
            const SizedBox(width: 10),
          ],
          if (selected.length < 6)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: picking ? null : onAdd,
              child: Container(
                width: tileSize,
                height: tileSize,
                decoration: BoxDecoration(
                  color: const Color(0xFF4D3A53),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                    width: 1.2,
                  ),
                ),
                child: picking
                    ? const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Color(0xFFB96CFF),
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.add_rounded,
                        color: Color(0xFF8F7596),
                        size: 34,
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PresetGrid extends StatelessWidget {
  const _PresetGrid({
    required this.selectedKey,
    required this.unlocksAt,
    required this.onPreset,
    required this.onCustom,
  });

  final String selectedKey;
  final DateTime unlocksAt;
  final ValueChanged<CapsuleOpeningPreset> onPreset;
  final VoidCallback onCustom;

  @override
  Widget build(BuildContext context) {
    final presets = CapsuleSquareSeed.openingPresets(DateTime.now());
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        const tileHeight = 72.0;
        final tileWidth = ((constraints.maxWidth - gap * 2) / 3)
            .clamp(0.0, double.infinity)
            .toDouble();
        final customWidth = tileWidth * 2 + gap;

        Widget presetTile(CapsuleOpeningPreset preset, {double? width}) {
          return _PresetTile(
            width: width ?? tileWidth,
            height: tileHeight,
            title: preset.label,
            date: capsuleDateStamp(preset.unlocksAt),
            selected: selectedKey == preset.presetId,
            onTap: () => onPreset(preset),
          );
        }

        return Column(
          children: [
            Row(
              children: [
                for (final preset in presets.take(3)) ...[
                  presetTile(preset),
                  if (preset != presets.take(3).last)
                    const SizedBox(width: gap),
                ],
              ],
            ),
            const SizedBox(height: gap),
            Row(
              children: [
                for (final preset in presets.skip(3).take(3)) ...[
                  presetTile(preset),
                  if (preset != presets.skip(3).take(3).last)
                    const SizedBox(width: gap),
                ],
              ],
            ),
            const SizedBox(height: gap),
            Row(
              children: [
                presetTile(presets[6]),
                const SizedBox(width: gap),
                _PresetTile(
                  width: customWidth,
                  height: tileHeight,
                  title: 'Custom Time',
                  date: selectedKey == 'custom'
                      ? '${capsuleDateStamp(unlocksAt)} ${capsuleClockStamp(unlocksAt)}'
                      : 'Choose a specific time',
                  selected: selectedKey == 'custom',
                  onTap: onCustom,
                  customIcon: true,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.width,
    required this.height,
    required this.title,
    required this.date,
    required this.selected,
    required this.onTap,
    this.customIcon = false,
  });

  final double width;
  final double height;
  final String title;
  final String date;
  final bool selected;
  final VoidCallback onTap;
  final bool customIcon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title $date',
      button: true,
      selected: selected,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFBF73FF) : const Color(0xFF4C3752),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (customIcon)
                    Image.asset(
                      CapsuleArtwork.customTimeGlyph,
                      width: 18,
                      height: 18,
                      filterQuality: FilterQuality.high,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                date,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: selected ? 0.82 : 0.34),
                  fontSize: 11,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaPickerSheet extends StatelessWidget {
  const _MediaPickerSheet({required this.remainingSlots});

  final int remainingSlots;

  @override
  Widget build(BuildContext context) {
    final bottom = MorrowlyFrameGuard.bottomClearance(
      context,
      minimum: 24,
      extra: 18,
    );
    final slotLabel = remainingSlots == 1
        ? '1 attachment slot left'
        : '$remainingSlots attachment slots left';

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Padding(
          padding: EdgeInsets.fromLTRB(18, 0, 18, bottom),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF37273C),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    'Add photos/videos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    slotLabel,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.44),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _MediaSourceRow(
                    icon: Icons.photo_library_outlined,
                    title: 'Choose photos',
                    subtitle: 'Select local photos from your library.',
                    action: _MediaPickAction.galleryPhotos,
                  ),
                  const SizedBox(height: 10),
                  _MediaSourceRow(
                    icon: Icons.video_library_outlined,
                    title: 'Choose videos',
                    subtitle: 'Select local videos from your library.',
                    action: _MediaPickAction.galleryVideos,
                  ),
                  const SizedBox(height: 10),
                  _MediaSourceRow(
                    icon: Icons.photo_camera_outlined,
                    title: 'Take a photo',
                    subtitle: 'Open the camera and add a new photo.',
                    action: _MediaPickAction.cameraPhoto,
                  ),
                  const SizedBox(height: 10),
                  _MediaSourceRow(
                    icon: Icons.videocam_outlined,
                    title: 'Record a video',
                    subtitle: 'Open the camera and add a new video.',
                    action: _MediaPickAction.cameraVideo,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MediaSourceRow extends StatelessWidget {
  const _MediaSourceRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final _MediaPickAction action;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(action),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFB96CFF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.54),
                      fontSize: 11,
                      height: 1.28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
