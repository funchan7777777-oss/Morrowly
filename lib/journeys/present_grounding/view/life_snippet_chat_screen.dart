import 'package:flutter/material.dart';
import 'package:morrowly/journeys/present_grounding/data/life_snippet_store.dart';
import 'package:morrowly/journeys/present_grounding/models/life_snippet_models.dart';
import 'package:morrowly/journeys/present_grounding/view/life_snippet_profile_screen.dart';
import 'package:morrowly/journeys/present_grounding/view/life_snippet_video_call_screen.dart';
import 'package:morrowly/journeys/present_grounding/widgets/life_snippet_widgets.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';

class LifeSnippetChatScreen extends StatefulWidget {
  const LifeSnippetChatScreen({super.key, required this.userKey});

  final String userKey;

  @override
  State<LifeSnippetChatScreen> createState() => _LifeSnippetChatScreenState();
}

class _LifeSnippetChatScreenState extends State<LifeSnippetChatScreen> {
  final LifeSnippetStore _store = LifeSnippetStore.instance;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final Future<void> _loadFuture = _store.load();
  String _draft = '';

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LifeSnippetStage(
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
              final user = _store.userByKey(widget.userKey);
              if (_store.isUserBlocked(widget.userKey)) {
                return Stack(
                  children: [
                    const _HiddenChatPanel(),
                    LifeTopBar(
                      title: user.displayName,
                      onBack: () => Navigator.of(context).pop(),
                    ),
                  ],
                );
              }
              final messages = _store.chatMessagesFor(widget.userKey);
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
                            minimum: 92,
                            extra: 30,
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
                            onProfile: () => _openProfile(user.userKey),
                            onVideoCall: _openVideoCall,
                          ),
                          const SizedBox(height: 26),
                          if (messages.isEmpty)
                            _EmptyChatPanel(
                              user: user,
                              onProfile: () => _openProfile(user.userKey),
                            )
                          else
                            for (final message in messages) ...[
                              _MessageBubble(
                                message: message,
                                currentUserKey: _store.currentUser.userKey,
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
                  LifeTopBar(
                    title: user.displayName,
                    onBack: () => Navigator.of(context).pop(),
                    trailing: IconButton(
                      onPressed: () => _openProfile(user.userKey),
                      icon: const Icon(
                        Icons.error_rounded,
                        color: Colors.white,
                        size: 23,
                      ),
                      tooltip: 'User info',
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
      await _store.sendMessage(userKey: widget.userKey, body: _draft);
      _controller.clear();
      setState(() => _draft = '');
      _focusNode.requestFocus();
    } on LifeSnippetRelationshipGate {
      if (mounted) {
        await showLifeRelationshipGateDialog(context);
      }
    }
  }

  Future<void> _openVideoCall() async {
    if (_store.isUserBlocked(widget.userKey) ||
        !_store.isMutualFollow(widget.userKey)) {
      await showLifeRelationshipGateDialog(context);
      return;
    }
    if (!mounted) {
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => LifeSnippetVideoCallScreen(userKey: widget.userKey),
      ),
    );
  }

  Future<void> _openProfile(String userKey) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => LifeSnippetProfileScreen(userKey: userKey),
      ),
    );
  }
}

class _ChatContactCard extends StatelessWidget {
  const _ChatContactCard({
    required this.user,
    required this.onProfile,
    required this.onVideoCall,
  });

  final LifeSnippetUser user;
  final VoidCallback onProfile;
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
          LifeAvatar(user: user, radius: 29, onTap: onProfile),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
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
                  user.signatureLine,
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
              child: const Icon(
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
  const _EmptyChatPanel({required this.user, required this.onProfile});

  final LifeSnippetUser user;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 34),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      decoration: BoxDecoration(
        color: lifePanel.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          LifeAvatar(user: user, radius: 34, onTap: onProfile),
          const SizedBox(height: 14),
          const Text(
            'No messages yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Messages are stored locally after they are sent. Sending is available only after mutual follow approval.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.58),
              fontSize: 12,
              height: 1.34,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.currentUserKey});

  final LifeChatMessage message;
  final String currentUserKey;

  @override
  Widget build(BuildContext context) {
    final mine = message.senderKey == currentUserKey;
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
            message.body,
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
                hintText: 'Please enter',
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
                LifeSnippetAssets.send,
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
