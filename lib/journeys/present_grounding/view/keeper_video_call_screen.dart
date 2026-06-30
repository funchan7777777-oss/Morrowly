import 'dart:async';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:morrowly/journeys/present_grounding/data/keeper_memory_store.dart';
import 'package:morrowly/journeys/present_grounding/models/keeper_memory_thread.dart';
import 'package:morrowly/journeys/present_grounding/widgets/keeper_memory_widgets.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';

class KeeperVideoCallScreen extends StatefulWidget {
  const KeeperVideoCallScreen({super.key, required this.keeperId});

  final String keeperId;

  @override
  State<KeeperVideoCallScreen> createState() => _KeeperVideoCallScreenState();
}

class _KeeperVideoCallScreenState extends State<KeeperVideoCallScreen> {
  final KeeperMemoryStore _store = KeeperMemoryStore.instance;
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  CameraDescription? _activeCamera;
  Future<void>? _cameraFuture;
  String? _cameraError;
  late DateTime _connectedAt;
  Timer? _callTimer;
  bool _connected = false;
  bool _speakerEnabled = true;
  bool _microphoneEnabled = true;
  bool _cameraEnabled = true;

  @override
  void initState() {
    super.initState();
    _connectedAt = DateTime.now();
    _cameraFuture = _prepareCamera();
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _connected = true;
        _connectedAt = DateTime.now();
      });
    });
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _connected) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _store.keeperById(widget.keeperId);
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
                userName: user.publicName,
                statusText: _callStatusText,
                onBack: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              right: 24,
              top: MorrowlyFrameGuard.topClearance(
                context,
                minimum: 112,
                extra: 50,
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
                minimum: 36,
                extra: 22,
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

  String get _callStatusText {
    if (!_connected) {
      return 'Ringing...';
    }
    final elapsed = DateTime.now().difference(_connectedAt);
    final minutes = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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
    } on CameraException catch (error) {
      if (mounted) {
        setState(() => _cameraError = _cameraErrorMessage(error));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _cameraError = 'Camera preview is unavailable.');
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
        ResolutionPreset.high,
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
    } on CameraException catch (error) {
      await nextController?.dispose();
      if (mounted) {
        setState(() => _cameraError = _cameraErrorMessage(error));
      }
    } catch (_) {
      await nextController?.dispose();
      if (mounted) {
        setState(() => _cameraError = 'Camera preview is unavailable.');
      }
    }
  }

  String _cameraErrorMessage(CameraException error) {
    final code = error.code.toLowerCase();
    if (code.contains('audio') || code.contains('microphone')) {
      return 'Microphone access is required.';
    }
    if (code.contains('camera')) {
      return 'Camera access is required.';
    }
    return 'Camera and microphone access is required.';
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

  final KeeperProfile user;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 0.35, sigmaY: 0.35),
          child: Image(
            image: keeperAvatarProvider(user),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            filterQuality: FilterQuality.high,
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.22),
                Colors.black.withValues(alpha: 0.03),
                Colors.black.withValues(alpha: 0.82),
              ],
              stops: const [0, 0.5, 1],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.2, -0.25),
              radius: 1.0,
              colors: [
                Colors.transparent,
                const Color(0xFF7E3FA8).withValues(alpha: 0.16),
              ],
              stops: const [0.52, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _VideoCallTopBar extends StatelessWidget {
  const _VideoCallTopBar({
    required this.userName,
    required this.statusText,
    required this.onBack,
  });

  final String userName;
  final String statusText;
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
        height: 64,
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
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 11,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_rounded,
                  color: Color(0xFF6D4675),
                  size: 21,
                ),
              ),
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
      width: 118,
      height: 162,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.34),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          FutureBuilder<void>(
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
                return _PreviewStatus(
                  icon: Icons.lock_rounded,
                  label: errorMessage!,
                );
              }
              if (snapshot.connectionState != ConnectionState.done ||
                  activeController == null ||
                  !activeController.value.isInitialized) {
                return Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white.withValues(alpha: 0.88),
                      strokeWidth: 2.6,
                    ),
                  ),
                );
              }
              return _CameraPreviewCover(controller: activeController);
            },
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.36),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'You',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.86),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraPreviewCover extends StatelessWidget {
  const _CameraPreviewCover({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    final width = previewSize?.height ?? 118;
    final height = previewSize?.width ?? 162;
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: width,
        height: height,
        child: CameraPreview(controller),
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
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 10.5,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 340),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
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
        width: 60,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: destructive
              ? const Color(0xFFFF4B79).withValues(alpha: 0.96)
              : Colors.white.withValues(alpha: active ? 0.24 : 0.13),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: destructive
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF4B79).withValues(alpha: 0.34),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
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
