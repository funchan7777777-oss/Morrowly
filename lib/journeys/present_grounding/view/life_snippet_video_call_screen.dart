import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:morrowly/journeys/present_grounding/data/life_snippet_store.dart';
import 'package:morrowly/journeys/present_grounding/models/life_snippet_models.dart';
import 'package:morrowly/journeys/present_grounding/widgets/life_snippet_widgets.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';

class LifeSnippetVideoCallScreen extends StatefulWidget {
  const LifeSnippetVideoCallScreen({super.key, required this.userKey});

  final String userKey;

  @override
  State<LifeSnippetVideoCallScreen> createState() =>
      _LifeSnippetVideoCallScreenState();
}

class _LifeSnippetVideoCallScreenState
    extends State<LifeSnippetVideoCallScreen> {
  final LifeSnippetStore _store = LifeSnippetStore.instance;
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  CameraDescription? _activeCamera;
  Future<void>? _cameraFuture;
  String? _cameraError;
  bool _speakerEnabled = true;
  bool _microphoneEnabled = true;
  bool _cameraEnabled = true;

  @override
  void initState() {
    super.initState();
    _cameraFuture = _prepareCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _store.userByKey(widget.userKey);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            _RemoteVideoBackdrop(user: user),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: _VideoCallTopBar(
                userName: user.displayName,
                onBack: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              left: 30,
              top: MorrowlyFrameGuard.topClearance(
                context,
                minimum: 92,
                extra: 24,
              ),
              child: _LocalPreview(
                cameraFuture: _cameraFuture,
                controller: _controller,
                cameraEnabled: _cameraEnabled,
                errorMessage: _cameraError,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: MorrowlyFrameGuard.bottomClearance(
                context,
                minimum: 42,
                extra: 28,
              ),
              child: _VideoControls(
                speakerEnabled: _speakerEnabled,
                microphoneEnabled: _microphoneEnabled,
                cameraEnabled: _cameraEnabled,
                canSwitchCamera: _cameras.length > 1,
                onSpeaker: () {
                  setState(() => _speakerEnabled = !_speakerEnabled);
                },
                onMicrophone: () {
                  setState(() => _microphoneEnabled = !_microphoneEnabled);
                },
                onCamera: () {
                  setState(() => _cameraEnabled = !_cameraEnabled);
                },
                onSwitchCamera: _switchCamera,
                onEnd: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _prepareCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(
            () => _cameraError = 'No camera is available on this device.',
          );
        }
        return;
      }

      _cameras = cameras;
      final selectedCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      await _startCamera(selectedCamera);
    } catch (_) {
      if (mounted) {
        setState(
          () => _cameraError =
              'Camera and microphone permission is required for video calls.',
        );
      }
    }
  }

  Future<void> _startCamera(CameraDescription camera) async {
    final previous = _controller;
    _controller = null;
    await previous?.dispose();

    CameraController? nextController;
    try {
      nextController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: true,
      );
      await nextController.initialize();
      if (!mounted) {
        await nextController.dispose();
        return;
      }
      setState(() {
        _activeCamera = camera;
        _controller = nextController;
        _cameraError = null;
        _cameraEnabled = true;
        _microphoneEnabled = true;
      });
    } catch (_) {
      await nextController?.dispose();
      if (mounted) {
        setState(
          () => _cameraError =
              'Camera and microphone permission is required for video calls.',
        );
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _activeCamera == null) {
      return;
    }

    final currentIndex = _cameras.indexOf(_activeCamera!);
    final nextCamera = _cameras[(currentIndex + 1) % _cameras.length];
    setState(() {
      _cameraFuture = _startCamera(nextCamera);
      _cameraError = null;
    });
  }
}

class _RemoteVideoBackdrop extends StatelessWidget {
  const _RemoteVideoBackdrop({required this.user});

  final LifeSnippetUser user;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image(image: lifeAvatarProvider(user), fit: BoxFit.cover),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.18),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.72),
              ],
              stops: const [0, 0.46, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _VideoCallTopBar extends StatelessWidget {
  const _VideoCallTopBar({required this.userName, required this.onBack});

  final String userName;
  final VoidCallback onBack;

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
              userName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            const Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.error_rounded, color: Colors.white, size: 23),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocalPreview extends StatelessWidget {
  const _LocalPreview({
    required this.cameraFuture,
    required this.controller,
    required this.cameraEnabled,
    required this.errorMessage,
  });

  final Future<void>? cameraFuture;
  final CameraController? controller;
  final bool cameraEnabled;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 116,
      height: 154,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: FutureBuilder<void>(
        future: cameraFuture,
        builder: (context, snapshot) {
          final activeController = controller;
          if (!cameraEnabled) {
            return const _PreviewStatus(
              icon: Icons.videocam_off_rounded,
              label: 'Camera off',
            );
          }
          if (errorMessage != null) {
            return const _PreviewStatus(
              icon: Icons.lock_rounded,
              label: 'Permission',
            );
          }
          if (snapshot.connectionState != ConnectionState.done ||
              activeController == null ||
              !activeController.value.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          return CameraPreview(activeController);
        },
      ),
    );
  }
}

class _PreviewStatus extends StatelessWidget {
  const _PreviewStatus({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.72), size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoControls extends StatelessWidget {
  const _VideoControls({
    required this.speakerEnabled,
    required this.microphoneEnabled,
    required this.cameraEnabled,
    required this.canSwitchCamera,
    required this.onSpeaker,
    required this.onMicrophone,
    required this.onCamera,
    required this.onSwitchCamera,
    required this.onEnd,
  });

  final bool speakerEnabled;
  final bool microphoneEnabled;
  final bool cameraEnabled;
  final bool canSwitchCamera;
  final VoidCallback onSpeaker;
  final VoidCallback onMicrophone;
  final VoidCallback onCamera;
  final VoidCallback onSwitchCamera;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 344),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(38),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _CallControlButton(
              icon: speakerEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
              active: speakerEnabled,
              onTap: onSpeaker,
            ),
            _CallControlButton(
              icon: microphoneEnabled
                  ? Icons.mic_rounded
                  : Icons.mic_off_rounded,
              active: microphoneEnabled,
              onTap: onMicrophone,
            ),
            _CallControlButton(
              icon: cameraEnabled
                  ? Icons.cameraswitch_rounded
                  : Icons.videocam_off_rounded,
              active: cameraEnabled,
              onTap: canSwitchCamera ? onSwitchCamera : onCamera,
              onLongPress: onCamera,
            ),
            _CallControlButton(
              icon: Icons.call_end_rounded,
              active: true,
              destructive: true,
              onTap: onEnd,
            ),
          ],
        ),
      ),
    );
  }
}

class _CallControlButton extends StatelessWidget {
  const _CallControlButton({
    required this.icon,
    required this.active,
    required this.onTap,
    this.onLongPress,
    this.destructive = false,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 58,
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: destructive
              ? const Color(0xFF9F5CFF).withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: active ? 0.22 : 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Icon(
          icon,
          color: destructive
              ? Colors.white
              : Colors.white.withValues(alpha: active ? 0.94 : 0.54),
          size: 27,
        ),
      ),
    );
  }
}
