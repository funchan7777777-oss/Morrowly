import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:morrowly/journeys/present_grounding/data/keeper_memory_store.dart';
import 'package:morrowly/journeys/present_grounding/models/keeper_memory_thread.dart';
import 'package:morrowly/journeys/present_grounding/view/keeper_home_screen.dart';
import 'package:morrowly/journeys/present_grounding/view/keeper_video_call_screen.dart';
import 'package:morrowly/journeys/present_grounding/widgets/keeper_memory_widgets.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';
import 'package:morrowly/shared/moderation/morrowly_content_safety.dart';
import 'package:morrowly/shared/widgets/morrowly_moderation_dialog.dart';
import 'package:morrowly/shared/widgets/morrowly_safety_notice.dart';

class KeeperLetterThreadScreen extends StatefulWidget {
  const KeeperLetterThreadScreen({super.key, required this.keeperId});

  final String keeperId;

  @override
  State<KeeperLetterThreadScreen> createState() =>
      _KeeperLetterThreadScreenState();
}

class _KeeperLetterThreadScreenState extends State<KeeperLetterThreadScreen> {
  final KeeperMemoryStore _store = KeeperMemoryStore.instance;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final Future<void> _loadFuture = _store.load();
  String _draft = '';
  bool _openingVideoCall = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MorrowlyMemoryStage(
      resizeForKeyboard: true,
      child: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          return AnimatedBuilder(
            animation: _store,
            builder: (context, _) {
              final user = _store.keeperById(widget.keeperId);
              if (_store.isUserBlocked(widget.keeperId)) {
                return Stack(
                  children: [
                    const _HiddenChatPanel(),
                    MorrowlyMemoryTopBar(
                      title: user.publicName,
                      onBack: () => Navigator.of(context).pop(),
                    ),
                  ],
                );
              }
              final messages = _store.chatMessagesFor(widget.keeperId);
              return Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final contentWidth = MorrowlyFrameGuard.contentWidth(
                        constraints.maxWidth,
                        maxWidth: 430,
                        phoneGutter: 18,
                      );
                      final side = (constraints.maxWidth - contentWidth) / 2;
                      return ListView(
                        padding: EdgeInsets.fromLTRB(
                          side,
                          MorrowlyFrameGuard.topClearance(
                            context,
                            minimum: 132,
                            extra: 72,
                          ),
                          side,
                          MorrowlyFrameGuard.bottomClearance(
                            context,
                            minimum: 104,
                            extra: 64,
                          ),
                        ),
                        children: [
                          _ChatContactCard(
                            user: user,
                            onProfile: () => _openProfile(user.keeperId),
                            videoCallBusy: _openingVideoCall,
                            onVideoCall: _openVideoCall,
                          ),
                          const SizedBox(height: 26),
                          if (messages.isEmpty)
                            _EmptyChatPanel(
                              onProfile: () => _openProfile(user.keeperId),
                            )
                          else
                            for (final message in messages) ...[
                              _MessageBubble(
                                message: message,
                                signedInKeeperId:
                                    _store.signedInKeeper.keeperId,
                              ),
                              const SizedBox(height: 10),
                            ],
                        ],
                      );
                    },
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                        child: _ChatComposer(
                          controller: _controller,
                          focusNode: _focusNode,
                          draft: _draft,
                          onChanged: (value) => setState(() => _draft = value),
                          onSend: _sendMessage,
                        ),
                      ),
                    ),
                  ),
                  MorrowlyMemoryTopBar(
                    title: user.publicName,
                    onBack: () => Navigator.of(context).pop(),
                    topMinimum: 58,
                    topExtra: 10,
                    trailing: IconButton(
                      onPressed: () => _showChatModeration(user.keeperId),
                      icon: const Icon(
                        Icons.error_rounded,
                        color: Colors.white,
                        size: 23,
                      ),
                      tooltip: 'Report or block',
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _sendMessage() async {
    try {
      await _store.sendMessage(keeperId: widget.keeperId, letterText: _draft);
      _controller.clear();
      setState(() => _draft = '');
      _focusNode.requestFocus();
    } on MutualKeeperGate {
      if (mounted) {
        await showMutualKeeperGateDialog(context);
      }
    } on MorrowlyContentSafetyException catch (issue) {
      if (mounted) {
        await showMorrowlySafetyNotice(context, issue);
      }
    }
  }

  Future<void> _openVideoCall() async {
    if (_openingVideoCall) {
      return;
    }
    if (_store.isUserBlocked(widget.keeperId) ||
        !_store.isMutualFollow(widget.keeperId)) {
      await showMutualKeeperGateDialog(context);
      return;
    }
    setState(() => _openingVideoCall = true);
    final allowed = await _requestVideoCallPermissions();
    if (mounted) {
      setState(() => _openingVideoCall = false);
    }
    if (!allowed) {
      return;
    }
    if (!mounted) {
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => KeeperVideoCallScreen(keeperId: widget.keeperId),
      ),
    );
  }

  Future<bool> _requestVideoCallPermissions() async {
    CameraController? permissionProbe;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        await _showVideoPermissionDialog(
          title: 'Camera unavailable',
          message: 'This device does not have a camera available for preview.',
        );
        return false;
      }
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      permissionProbe = CameraController(
        camera,
        ResolutionPreset.low,
        enableAudio: true,
      );
      await permissionProbe.initialize();
      return true;
    } on CameraException catch (error) {
      await _showVideoPermissionDialog(
        title: 'Call preview needs access',
        message: _videoPermissionMessage(error),
      );
      return false;
    } catch (_) {
      await _showVideoPermissionDialog(
        title: 'Call preview needs access',
        message:
            'Allow camera and microphone access so this call can show your local preview and include your voice.',
      );
      return false;
    } finally {
      await permissionProbe?.dispose();
    }
  }

  String _videoPermissionMessage(CameraException error) {
    final code = error.code.toLowerCase();
    if (code.contains('audio') || code.contains('microphone')) {
      return 'Allow microphone access so the call can carry your voice.';
    }
    if (code.contains('camera')) {
      return 'Allow camera access so Morrowly can show your local preview.';
    }
    return 'Allow camera and microphone access so this call can show your local preview and include your voice.';
  }

  Future<void> _showVideoPermissionDialog({
    required String title,
    required String message,
  }) {
    if (!mounted) {
      return Future.value();
    }
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: lifePanel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            height: 1.34,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Review access',
              style: TextStyle(color: lifePurple, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openProfile(String keeperId) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => KeeperHomeScreen(keeperId: keeperId)),
    );
  }

  Future<void> _showChatModeration(String keeperId) async {
    final result = await showMorrowlyModerationFlow(
      context: context,
      target: _store.moderationTargetForUser(keeperId),
      onReport: (reason) => _store.reportUser(keeperId, reason: reason),
      onBlock: () => _store.blockUser(keeperId),
    );
    if (!mounted || result == null) {
      return;
    }
    Navigator.of(context).pop();
  }
}

class _ChatContactCard extends StatelessWidget {
  const _ChatContactCard({
    required this.user,
    required this.onProfile,
    required this.videoCallBusy,
    required this.onVideoCall,
  });

  final KeeperProfile user;
  final VoidCallback onProfile;
  final bool videoCallBusy;
  final VoidCallback onVideoCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFFFD9B1), Color(0xFFE55EFF), Color(0xFFC651F3)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C1732).withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          KeeperAvatar(user: user, radius: 29, onTap: onProfile),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.publicName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  user.morrowLine,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 12,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onVideoCall,
            child: Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(15),
              ),
              child: videoCallBusy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: lifePurple,
                        strokeWidth: 2.6,
                      ),
                    )
                  : const Icon(
                      Icons.videocam_rounded,
                      color: lifePurple,
                      size: 30,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HiddenChatPanel extends StatelessWidget {
  const _HiddenChatPanel();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
          decoration: BoxDecoration(
            color: lifePanel.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Text(
            'This chat is hidden on this device.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
              height: 1.34,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyChatPanel extends StatelessWidget {
  const _EmptyChatPanel({required this.onProfile});

  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 44),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 310),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onProfile,
                child: Image.asset(
                  MorrowlyAssetKit.empty,
                  width: 138,
                  height: 156,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'No shared notes yet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Once you both follow each other, the first note you send will be saved here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.54),
                  fontSize: 12.5,
                  height: 1.36,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.signedInKeeperId});

  final KeeperLetter message;
  final String signedInKeeperId;

  @override
  Widget build(BuildContext context) {
    final mine = message.senderKeeperId == signedInKeeperId;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: mine ? lifePurple : lifePanel,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(mine ? 18 : 5),
              bottomRight: Radius.circular(mine ? 5 : 18),
            ),
          ),
          child: Text(
            message.letterText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.34,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatComposer extends StatelessWidget {
  const _ChatComposer({
    required this.controller,
    required this.focusNode,
    required this.draft,
    required this.onChanged,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String draft;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final canSend = draft.trim().isNotEmpty;
    return Container(
      height: 48,
      padding: const EdgeInsets.fromLTRB(14, 0, 6, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF352738).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              onSubmitted: (_) {
                if (canSend) {
                  onSend();
                }
              },
              textInputAction: TextInputAction.send,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: 'Send a quiet note',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.28),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: canSend ? onSend : null,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 140),
              opacity: canSend ? 1 : 0.38,
              child: Image.asset(
                MorrowlyAssetKit.send,
                width: 38,
                height: 38,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
