import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:morrowly/journeys/present_grounding/data/life_snippet_store.dart';
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
  Future<void>? _cameraFuture;
  String? _cameraError;

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
    return LifeSnippetStage(
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
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  side,
                  MorrowlyFrameGuard.topClearance(
                    context,
                    minimum: 98,
                    extra: 30,
                  ),
                  side,
                  MorrowlyFrameGuard.bottomClearance(
                    context,
                    minimum: 32,
                    extra: 18,
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: lifePanel.withValues(alpha: 0.88),
                          ),
                          child: FutureBuilder<void>(
                            future: _cameraFuture,
                            builder: (context, snapshot) {
                              final controller = _controller;
                              if (_cameraError != null) {
                                return _CameraUnavailable(
                                  message: _cameraError!,
                                );
                              }
                              if (snapshot.connectionState !=
                                      ConnectionState.done ||
                                  controller == null ||
                                  !controller.value.isInitialized) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                );
                              }
                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  CameraPreview(controller),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.fromLTRB(
                                        18,
                                        18,
                                        18,
                                        18,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withValues(
                                              alpha: 0.45,
                                            ),
                                          ],
                                        ),
                                      ),
                                      child: Text(
                                        'Local preview with ${user.displayName}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF4D6D),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.call_end_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          LifeTopBar(
            title: user.displayName,
            onBack: () => Navigator.of(context).pop(),
          ),
        ],
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

      final selectedCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: true,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (_) {
      if (mounted) {
        setState(
          () => _cameraError =
              'Camera or microphone permission is required for video calls.',
        );
      }
    }
  }
}

class _CameraUnavailable extends StatelessWidget {
  const _CameraUnavailable({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              LifeSnippetAssets.compose,
              width: 74,
              height: 74,
              filterQuality: FilterQuality.high,
            ),
            const SizedBox(height: 14),
            const Text(
              'Preview unavailable',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.62),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
