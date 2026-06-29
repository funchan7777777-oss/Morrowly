import 'package:flutter/material.dart';
import 'package:morrowly/journeys/time_capsule/data/capsule_square_seed.dart';
import 'package:morrowly/journeys/time_capsule/models/capsule_chronicle.dart';
import 'package:morrowly/journeys/time_capsule/view/capsule_preview_screen.dart';
import 'package:morrowly/journeys/time_capsule/view/custom_opening_time_screen.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_stage.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_widgets.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';

class CapsuleEditorScreen extends StatefulWidget {
  const CapsuleEditorScreen({
    super.key,
    required this.craftKind,
    required this.coinBalance,
  });

  final CapsuleCraftKind craftKind;
  final int coinBalance;

  @override
  State<CapsuleEditorScreen> createState() => _CapsuleEditorScreenState();
}

class _CapsuleEditorScreenState extends State<CapsuleEditorScreen> {
  final TextEditingController _messageController = TextEditingController();
  late CapsuleDraftLedger _draft;
  String _selectedPresetKey = 'one-year';

  @override
  void initState() {
    super.initState();
    final presets = CapsuleSquareSeed.openingPresets(DateTime.now());
    final seededMedia = widget.craftKind == CapsuleCraftKind.videoMemory
        ? [
            CapsuleSquareSeed.memorySnaps.firstWhere(
              (snap) => snap.kind == CapsuleMediaKind.motion,
            ),
          ]
        : [
            CapsuleSquareSeed.memorySnaps[13],
            CapsuleSquareSeed.memorySnaps[19],
          ];
    _draft = CapsuleDraftLedger(
      craftKind: widget.craftKind,
      messageLine: '',
      mediaSnaps: seededMedia,
      openingAt: presets[3].openingAt,
      visibility: CapsuleVisibility.publicSquare,
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
          CapsuleTopBar(
            title: 'Edit Capsule',
            onBack: () => Navigator.of(context).pop(),
          ),
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
                    minimum: 116,
                    extra: 48,
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
                    const SizedBox(height: 14),
                    _MessageField(
                      controller: _messageController,
                      onChanged: (value) {
                        setState(() {
                          _draft = _draft.copyWith(messageLine: value);
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Add photos/videos (optional)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _MediaStrip(
                      selected: _draft.mediaSnaps,
                      onAdd: _showMediaPicker,
                      onRemove: (snap) {
                        setState(() {
                          _draft = _draft.copyWith(
                            mediaSnaps: [
                              for (final item in _draft.mediaSnaps)
                                if (item.snapKey != snap.snapKey) item,
                            ],
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 24),
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
                    const SizedBox(height: 18),
                    _PresetGrid(
                      selectedKey: _selectedPresetKey,
                      openingAt: _draft.openingAt,
                      onPreset: _selectPreset,
                      onCustom: _openCustomTime,
                    ),
                    const SizedBox(height: 34),
                    Center(
                      child: CapsuleAssetTap(
                        assetName: CapsuleArtwork.sealedCapsules,
                        width: contentWidth * 0.84,
                        height: 50,
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
        ],
      ),
    );
  }

  void _selectPreset(CapsuleOpeningPreset preset) {
    setState(() {
      _selectedPresetKey = preset.presetKey;
      _draft = _draft.copyWith(openingAt: preset.openingAt);
    });
  }

  Future<void> _openCustomTime() async {
    final selected = await Navigator.of(context).push<DateTime>(
      MaterialPageRoute(
        builder: (_) => CustomOpeningTimeScreen(initialTime: _draft.openingAt),
      ),
    );
    if (selected == null || !mounted) {
      return;
    }
    setState(() {
      _selectedPresetKey = 'custom';
      _draft = _draft.copyWith(openingAt: selected);
    });
  }

  Future<void> _showMediaPicker() async {
    final snap = await showModalBottomSheet<CapsuleMediaSnap>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.52),
      builder: (context) => const _MediaPickerSheet(),
    );
    if (snap == null || !mounted) {
      return;
    }
    if (_draft.mediaSnaps.any((item) => item.snapKey == snap.snapKey)) {
      return;
    }
    setState(() {
      _draft = _draft.copyWith(
        mediaSnaps: [..._draft.mediaSnaps, snap].take(6).toList(),
      );
    });
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
    final result = await Navigator.of(context).push<CapsuleSquareNote>(
      MaterialPageRoute(
        builder: (_) => CapsulePreviewScreen(
          draft: _draft.copyWith(messageLine: message),
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
        actionLabel: 'Got it',
        onAction: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _MessageField extends StatelessWidget {
  const _MessageField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 214,
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
          hintText: 'Please enter',
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
    required this.onAdd,
    required this.onRemove,
  });

  final List<CapsuleMediaSnap> selected;
  final VoidCallback onAdd;
  final ValueChanged<CapsuleMediaSnap> onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final snap in selected) ...[
            CapsuleMediaTile(
              snap: snap,
              size: 86,
              onRemove: () => onRemove(snap),
            ),
            const SizedBox(width: 12),
          ],
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onAdd,
            child: Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: const Color(0xFF4D3A53),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                  width: 1.2,
                ),
              ),
              child: const Icon(
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
    required this.openingAt,
    required this.onPreset,
    required this.onCustom,
  });

  final String selectedKey;
  final DateTime openingAt;
  final ValueChanged<CapsuleOpeningPreset> onPreset;
  final VoidCallback onCustom;

  @override
  Widget build(BuildContext context) {
    final presets = CapsuleSquareSeed.openingPresets(DateTime.now());
    return GridView.count(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.16,
      children: [
        for (final preset in presets)
          _PresetTile(
            title: preset.label,
            date: capsuleDateStamp(preset.openingAt),
            selected: selectedKey == preset.presetKey,
            onTap: () => onPreset(preset),
          ),
        _PresetTile(
          title: 'Custom Time',
          date: selectedKey == 'custom'
              ? '${capsuleDateStamp(openingAt)} ${capsuleClockStamp(openingAt)}'
              : 'Choose a specific time',
          selected: selectedKey == 'custom',
          onTap: onCustom,
          customIcon: true,
        ),
      ],
    );
  }
}

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.title,
    required this.date,
    required this.selected,
    required this.onTap,
    this.customIcon = false,
  });

  final String title;
  final String date;
  final bool selected;
  final VoidCallback onTap;
  final bool customIcon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
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
                      fontSize: 12,
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
    );
  }
}

class _MediaPickerSheet extends StatelessWidget {
  const _MediaPickerSheet();

  @override
  Widget build(BuildContext context) {
    final bottom = MorrowlyFrameGuard.bottomClearance(
      context,
      minimum: 24,
      extra: 18,
    );
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, controller) {
        return Container(
          padding: EdgeInsets.fromLTRB(18, 14, 18, bottom),
          decoration: const BoxDecoration(
            color: Color(0xFF37273C),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
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
                'Choose a memory trace',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: GridView.builder(
                  controller: controller,
                  itemCount: CapsuleSquareSeed.memorySnaps.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final snap = CapsuleSquareSeed.memorySnaps[index];
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).pop(snap),
                      child: CapsuleMediaTile(snap: snap, size: 96),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
