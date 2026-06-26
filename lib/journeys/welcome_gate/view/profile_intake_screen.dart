import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:morrowly/journeys/welcome_gate/models/credential_gate_seed.dart';
import 'package:morrowly/journeys/welcome_gate/models/profile_intake_draft.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/full_bleed_stage.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/gate_back_button.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/gate_notice_dialog.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/gender_signal_pill.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/lit_action_pill.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/soft_entry_field.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/welcome_artwork.dart';
import 'package:path_provider/path_provider.dart';

class ProfileIntakeScreen extends StatefulWidget {
  const ProfileIntakeScreen({
    super.key,
    required this.seed,
    required this.onBack,
    required this.onProfileSubmitted,
  });

  final PendingCredentialSeed seed;
  final VoidCallback onBack;
  final ValueChanged<ProfileIntakeDraft> onProfileSubmitted;

  @override
  State<ProfileIntakeScreen> createState() => _ProfileIntakeScreenState();
}

class _ProfileIntakeScreenState extends State<ProfileIntakeScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  late final TextEditingController _displayNameController;
  late final TextEditingController _handleController;
  late final TextEditingController _signatureController;
  ProfileIntakeDraft _draft = const ProfileIntakeDraft();
  bool _pickingImage = false;

  @override
  void initState() {
    super.initState();
    final seededName = widget.seed.profileName.trim();
    _draft = ProfileIntakeDraft(
      displayName: seededName,
      chosenHandle: seededName,
    );
    _displayNameController = TextEditingController(text: seededName);
    _handleController = TextEditingController(text: seededName);
    _signatureController = TextEditingController();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _handleController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FullBleedStage(
      backgroundAsset: WelcomeArtwork.profile,
      resizeForKeyboard: true,
      child: Stack(
        children: [
          GateBackButton(onBack: widget.onBack),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final contentWidth = width.clamp(320.0, 430.0).toDouble() * 0.82;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  (width - contentWidth) / 2,
                  96,
                  (width - contentWidth) / 2,
                  28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.seed.isApple
                          ? 'Confirm your\nprofile'
                          : 'Fill in your\ninformation',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        height: 0.92,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.seed.isApple
                          ? 'Your Apple name is filled in. You can adjust it before entering.'
                          : 'Complete your Morrowly profile before entering.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.62),
                        fontSize: 11,
                        height: 1.28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _AvatarCameraSpot(
                      avatarPath: _draft.avatarLocalPath,
                      picking: _pickingImage,
                      onPressed: _showAvatarSourceSheet,
                    ),
                    const SizedBox(height: 16),
                    SoftEntryField(
                      label: 'Name',
                      placeholder: 'Please enter...',
                      controller: _displayNameController,
                      trailingKind: FieldTrailingKind.clear,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (value) {
                        _draft = _draft.copyWith(displayName: value);
                      },
                    ),
                    const SizedBox(height: 16),
                    SoftEntryField(
                      label: 'Morrowly name',
                      placeholder: 'Choose a name...',
                      controller: _handleController,
                      trailingKind: FieldTrailingKind.clear,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (value) {
                        _draft = _draft.copyWith(chosenHandle: value);
                      },
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'Gender selection',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.28),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GenderSignalPill(
                            choice: SocialSignalChoice.female,
                            selectedChoice: _draft.socialSignalChoice,
                            onSelected: _chooseSignal,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GenderSignalPill(
                            choice: SocialSignalChoice.male,
                            selectedChoice: _draft.socialSignalChoice,
                            onSelected: _chooseSignal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SoftEntryField(
                      label: 'Signature',
                      placeholder: 'Share a small line for tomorrow...',
                      controller: _signatureController,
                      maxLines: 4,
                      height: 102,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (value) {
                        _draft = _draft.copyWith(signatureLine: value);
                      },
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: LitActionPill(
                        label: widget.seed.isApple ? 'Enter' : 'Next',
                        width: contentWidth * 0.92,
                        onPressed: _submitProfile,
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

  void _chooseSignal(SocialSignalChoice choice) {
    setState(() {
      _draft = _draft.copyWith(socialSignalChoice: choice);
    });
  }

  Future<void> _showAvatarSourceSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.46),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF3A273F),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AvatarSourceRow(
                    icon: Icons.photo_library_outlined,
                    title: 'Choose from library',
                    subtitle: 'Use a local photo as your Morrowly avatar.',
                    onTap: () {
                      Navigator.of(context).pop();
                      _pickAvatar(ImageSource.gallery);
                    },
                  ),
                  const SizedBox(height: 10),
                  _AvatarSourceRow(
                    icon: Icons.photo_camera_outlined,
                    title: 'Take a photo',
                    subtitle: 'Open the camera and save a fresh avatar.',
                    onTap: () {
                      Navigator.of(context).pop();
                      _pickAvatar(ImageSource.camera);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAvatar(ImageSource source) async {
    setState(() => _pickingImage = true);
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 86,
      );
      if (picked == null) {
        return;
      }

      final savedPath = await _copyAvatarIntoLocalShelf(picked.path);
      setState(() {
        _draft = _draft.copyWith(avatarLocalPath: savedPath);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showNotice(
        title: 'Photo unavailable',
        message:
            'Morrowly could not open this photo source. Please check photo or camera permission and try again.',
        icon: Icons.photo_camera_back_outlined,
      );
    } finally {
      if (mounted) {
        setState(() => _pickingImage = false);
      }
    }
  }

  Future<String> _copyAvatarIntoLocalShelf(String sourcePath) async {
    final directory = await getApplicationSupportDirectory();
    final avatarShelf = Directory('${directory.path}/morrowly_avatar_shelf');
    if (!avatarShelf.existsSync()) {
      avatarShelf.createSync(recursive: true);
    }

    final extension = sourcePath.contains('.')
        ? sourcePath.split('.').last.toLowerCase()
        : 'jpg';
    final filename =
        'morrowly_avatar_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final copiedFile = await File(
      sourcePath,
    ).copy('${avatarShelf.path}/$filename');
    return copiedFile.path;
  }

  void _submitProfile() {
    final displayName = _displayNameController.text.trim();
    final handle = _handleController.text.trim();
    final signature = _signatureController.text.trim();

    if (displayName.isEmpty || handle.isEmpty || signature.isEmpty) {
      _showNotice(
        title: 'Finish your profile',
        message:
            'Please enter your name, Morrowly name, and signature before continuing.',
        icon: Icons.badge_outlined,
      );
      return;
    }

    widget.onProfileSubmitted(
      _draft.copyWith(
        displayName: displayName,
        chosenHandle: handle,
        signatureLine: signature,
      ),
    );
  }

  void _showNotice({
    required String title,
    required String message,
    IconData icon = Icons.info_outline,
  }) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.48),
      builder: (_) =>
          GateNoticeDialog(title: title, message: message, icon: icon),
    );
  }
}

class _AvatarCameraSpot extends StatelessWidget {
  const _AvatarCameraSpot({
    required this.avatarPath,
    required this.picking,
    required this.onPressed,
  });

  final String avatarPath;
  final bool picking;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            clipBehavior: Clip.antiAlias,
            child: avatarPath.isEmpty
                ? Center(
                    child: Image.asset(
                      WelcomeArtwork.camera,
                      width: 64,
                      height: 64,
                      filterQuality: FilterQuality.high,
                    ),
                  )
                : Image.file(
                    File(avatarPath),
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
          ),
          if (picking)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.24),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: -1,
            right: 4,
            child: Image.asset(
              WelcomeArtwork.fieldClear,
              width: 18,
              height: 18,
              filterQuality: FilterQuality.high,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarSourceRow extends StatelessWidget {
  const _AvatarSourceRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
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
