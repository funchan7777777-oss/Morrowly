import 'package:flutter/material.dart';
import 'package:morrowly/journeys/memory_ribbon/view/memory_ribbon_screen.dart';
import 'package:morrowly/journeys/present_grounding/data/life_snippet_store.dart';
import 'package:morrowly/journeys/present_grounding/models/life_snippet_models.dart';
import 'package:morrowly/journeys/present_grounding/view/life_snippet_chat_screen.dart';
import 'package:morrowly/journeys/present_grounding/view/life_snippet_detail_screen.dart';
import 'package:morrowly/journeys/present_grounding/view/life_snippet_profile_screen.dart';
import 'package:morrowly/journeys/present_grounding/widgets/life_snippet_widgets.dart';
import 'package:morrowly/shared/economy/morrowly_wallet_screen.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';

class TimeMailScreen extends StatefulWidget {
  const TimeMailScreen({
    super.key,
    this.onGoCheckCapsules,
    this.onSignedOut,
    this.onLoggedOut,
    this.onAccountDeleted,
  });

  final VoidCallback? onGoCheckCapsules;
  final VoidCallback? onSignedOut;
  final VoidCallback? onLoggedOut;
  final VoidCallback? onAccountDeleted;

  @override
  State<TimeMailScreen> createState() => _TimeMailScreenState();
}

class _TimeMailScreenState extends State<TimeMailScreen> {
  final LifeSnippetStore _store = LifeSnippetStore.instance;
  late final Future<void> _loadFuture = _store.load();

  @override
  Widget build(BuildContext context) {
    return LifeSnippetStage(
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
              final currentUser = _store.currentUser;
              final commentNotices = _store.commentNotices;
              final likedPosts = _store.likedPosts;
              final incomingRequests = _store.incomingFollowRequestUsers;
              final mutualFriends = _store.mutualFriendUsers;
              final threads = [
                for (final userKey in _store.chatThreadUserKeys)
                  _MailThread(
                    user: _store.userByKey(userKey),
                    message: _store.chatMessagesFor(userKey).last,
                  ),
              ];

              return Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      ProfileCenterAssets.backgroundWash,
                      fit: BoxFit.cover,
                      opacity: const AlwaysStoppedAnimation(0.14),
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final contentWidth = MorrowlyFrameGuard.contentWidth(
                        constraints.maxWidth,
                        maxWidth: 430,
                        phoneGutter: 18,
                      );
                      final side = (constraints.maxWidth - contentWidth) / 2;

                      return SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          side,
                          MorrowlyFrameGuard.topClearance(
                            context,
                            minimum: 48,
                            extra: 8,
                          ),
                          side,
                          MorrowlyFrameGuard.bottomClearance(
                            context,
                            minimum: 150,
                            extra: 108,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _MailHeader(
                              currentUser: currentUser,
                              onProfile: _openProfileCenter,
                              onWallet: _openWallet,
                            ),
                            const SizedBox(height: 28),
                            _MailShortcutRow(
                              commentCount: commentNotices.length,
                              likeCount: likedPosts.length,
                              requestCount: incomingRequests.length,
                              friendCount: mutualFriends.length,
                              onComments: _openComments,
                              onLikes: _openLikes,
                              onRequests: _openFriendRequests,
                              onFriends: _openFriends,
                            ),
                            const SizedBox(height: 26),
                            _CapsuleReminderCard(
                              onGoCheck: widget.onGoCheckCapsules,
                            ),
                            const SizedBox(height: 20),
                            if (threads.isEmpty)
                              const _EmptyMailThreads()
                            else
                              for (final thread in threads) ...[
                                _MailThreadTile(
                                  thread: thread,
                                  onTap: () => _openChat(thread.user.userKey),
                                  onProfile: () =>
                                      _openProfile(thread.user.userKey),
                                ),
                                if (thread != threads.last)
                                  const _MailThreadDivider(),
                              ],
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openProfileCenter() {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MemoryRibbonScreen(
          onSignedOut: widget.onSignedOut,
          onLoggedOut: widget.onLoggedOut,
          onAccountDeleted: widget.onAccountDeleted,
        ),
      ),
    );
  }

  Future<void> _openWallet() {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const MorrowlyWalletScreen()),
    );
  }

  Future<void> _openChat(String userKey) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => LifeSnippetChatScreen(userKey: userKey),
      ),
    );
  }

  Future<void> _openComments() {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const _CommentNoticesScreen()),
    );
  }

  Future<void> _openLikes() {
    return Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => const _LikedPostsScreen()));
  }

  Future<void> _openFriendRequests() {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const _FriendRequestsScreen()),
    );
  }

  Future<void> _openFriends() {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const _MutualFriendsScreen()),
    );
  }
}

class _MailHeader extends StatelessWidget {
  const _MailHeader({
    required this.currentUser,
    required this.onProfile,
    required this.onWallet,
  });

  final LifeSnippetUser currentUser;
  final VoidCallback onProfile;
  final VoidCallback onWallet;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 17),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                ProfileCenterAssets.underline,
                width: 117,
                height: 37,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: MorrowlyCoinBalancePill(
            height: 34,
            iconSize: 22,
            fontSize: 14,
            horizontalPadding: 10,
            onTap: onWallet,
          ),
        ),
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: LifeAvatar(user: currentUser, radius: 20, onTap: onProfile),
        ),
      ],
    );
  }
}

class _MailShortcutRow extends StatelessWidget {
  const _MailShortcutRow({
    required this.commentCount,
    required this.likeCount,
    required this.requestCount,
    required this.friendCount,
    required this.onComments,
    required this.onLikes,
    required this.onRequests,
    required this.onFriends,
  });

  final int commentCount;
  final int likeCount;
  final int requestCount;
  final int friendCount;
  final VoidCallback onComments;
  final VoidCallback onLikes;
  final VoidCallback onRequests;
  final VoidCallback onFriends;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _MailShortcut(
          asset: ProfileCenterAssets.messageStat,
          label: 'Comments',
          badgeLabel: _badgeText(commentCount),
          onTap: onComments,
        ),
        _MailShortcut(
          asset: ProfileCenterAssets.likeStat,
          label: 'Likes',
          badgeLabel: _badgeText(likeCount),
          onTap: onLikes,
        ),
        _MailShortcut(
          asset: ProfileCenterAssets.fanStat,
          label: 'Add friend',
          badgeLabel: _badgeText(requestCount),
          onTap: onRequests,
        ),
        _MailShortcut(
          asset: ProfileCenterAssets.followStat,
          label: 'Friends',
          badgeLabel: _badgeText(friendCount),
          onTap: onFriends,
        ),
      ],
    );
  }

  String? _badgeText(int value) {
    if (value <= 0) {
      return null;
    }
    return value > 99 ? '99+' : '$value';
  }
}

class _MailShortcut extends StatelessWidget {
  const _MailShortcut({
    required this.asset,
    required this.label,
    required this.onTap,
    this.badgeLabel,
  });

  final String asset;
  final String label;
  final VoidCallback onTap;
  final String? badgeLabel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  asset,
                  width: 70,
                  height: 70,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
                if (badgeLabel != null)
                  Positioned(
                    top: 2,
                    right: -1,
                    child: Container(
                      height: 19,
                      constraints: const BoxConstraints(minWidth: 28),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF373C),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badgeLabel!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.46),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CapsuleReminderCard extends StatelessWidget {
  const _CapsuleReminderCard({required this.onGoCheck});

  final VoidCallback? onGoCheck;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onGoCheck,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E1335).withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: AspectRatio(
          aspectRatio: 700 / 236,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                ProfileCenterAssets.capsuleBanner,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
              ),
              Positioned(
                left: 30,
                bottom: 29,
                child: Image.asset(
                  ProfileCenterAssets.goCheck,
                  width: 112,
                  height: 42,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MailThreadTile extends StatelessWidget {
  const _MailThreadTile({
    required this.thread,
    required this.onTap,
    required this.onProfile,
  });

  final _MailThread thread;
  final VoidCallback onTap;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 66,
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onProfile,
              child: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                backgroundImage: lifeAvatarProvider(thread.user),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thread.user.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.1,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    thread.message.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.34),
                      fontSize: 15,
                      height: 1.1,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _clockLabel(thread.message.createdAt),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.24),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MailThreadDivider extends StatelessWidget {
  const _MailThreadDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 66),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.white.withValues(alpha: 0.06),
      ),
    );
  }
}

class _MailThread {
  const _MailThread({required this.user, required this.message});

  final LifeSnippetUser user;
  final LifeChatMessage message;
}

class _EmptyMailThreads extends StatelessWidget {
  const _EmptyMailThreads();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Center(
        child: Image.asset(
          ProfileCenterAssets.empty,
          width: 188,
          height: 214,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

class _CommentNoticesScreen extends StatelessWidget {
  const _CommentNoticesScreen();

  @override
  Widget build(BuildContext context) {
    final store = LifeSnippetStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final notices = store.commentNotices;
        return _MailDetailScaffold(
          title: 'Comments',
          children: notices.isEmpty
              ? const [_MailEmptyArtwork()]
              : [
                  for (final notice in notices) ...[
                    _CommentNoticeTile(
                      notice: notice,
                      commenter: store.userByKey(notice.comment.authorKey),
                      postAuthor: store.userByKey(notice.post.authorKey),
                      onTap: () => _openPost(context, notice.post.postKey),
                      onProfile: () =>
                          _openProfile(context, notice.comment.authorKey),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
        );
      },
    );
  }
}

class _LikedPostsScreen extends StatelessWidget {
  const _LikedPostsScreen();

  @override
  Widget build(BuildContext context) {
    final store = LifeSnippetStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final posts = store.likedPosts;
        return _MailDetailScaffold(
          title: 'Likes',
          children: posts.isEmpty
              ? const [_MailEmptyArtwork()]
              : [
                  for (final post in posts) ...[
                    _LikedPostTile(
                      post: post,
                      author: store.userByKey(post.authorKey),
                      commentCount: store.visibleCommentCount(post),
                      likeCount: store.visibleLikeCount(post),
                      onTap: () => _openPost(context, post.postKey),
                      onProfile: () => _openProfile(context, post.authorKey),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
        );
      },
    );
  }
}

class _FriendRequestsScreen extends StatelessWidget {
  const _FriendRequestsScreen();

  @override
  Widget build(BuildContext context) {
    final store = LifeSnippetStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final users = store.incomingFollowRequestUsers;
        return _MailDetailScaffold(
          title: 'Add friend',
          children: users.isEmpty
              ? const [_MailEmptyArtwork()]
              : [
                  for (final user in users) ...[
                    _FriendRequestTile(
                      user: user,
                      onProfile: () => _openProfile(context, user.userKey),
                      onAccept: () async {
                        await store.acceptIncomingFollow(user.userKey);
                        if (!context.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${user.displayName} is now a friend.',
                            ),
                            backgroundColor: lifePanel,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
        );
      },
    );
  }
}

class _MutualFriendsScreen extends StatelessWidget {
  const _MutualFriendsScreen();

  @override
  Widget build(BuildContext context) {
    final store = LifeSnippetStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final users = store.mutualFriendUsers;
        return _MailDetailScaffold(
          title: 'Friends',
          children: users.isEmpty
              ? const [_MailEmptyArtwork()]
              : [
                  for (final user in users) ...[
                    _FriendTile(
                      user: user,
                      onProfile: () => _openProfile(context, user.userKey),
                      onChat: () => _openChat(context, user.userKey),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
        );
      },
    );
  }
}

class _MailDetailScaffold extends StatelessWidget {
  const _MailDetailScaffold({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
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
              return ListView(
                padding: EdgeInsets.fromLTRB(
                  side,
                  MorrowlyFrameGuard.topClearance(
                    context,
                    minimum: 96,
                    extra: 30,
                  ),
                  side,
                  MorrowlyFrameGuard.bottomClearance(
                    context,
                    minimum: 36,
                    extra: 18,
                  ),
                ),
                children: children,
              );
            },
          ),
          LifeTopBar(title: title, onBack: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}

class _CommentNoticeTile extends StatelessWidget {
  const _CommentNoticeTile({
    required this.notice,
    required this.commenter,
    required this.postAuthor,
    required this.onTap,
    required this.onProfile,
  });

  final LifeCommentNotice notice;
  final LifeSnippetUser commenter;
  final LifeSnippetUser postAuthor;
  final VoidCallback onTap;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return _MailPanelTap(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LifeAvatar(user: commenter, radius: 25, onTap: onProfile),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MailTileHeader(
                  title: commenter.displayName,
                  trailing: _clockLabel(notice.comment.createdAt),
                ),
                const SizedBox(height: 7),
                Text(
                  notice.comment.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${postAuthor.displayName}: ${notice.post.body}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 12,
                    height: 1.32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
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

class _LikedPostTile extends StatelessWidget {
  const _LikedPostTile({
    required this.post,
    required this.author,
    required this.commentCount,
    required this.likeCount,
    required this.onTap,
    required this.onProfile,
  });

  final LifeSnippetPost post;
  final LifeSnippetUser author;
  final int commentCount;
  final int likeCount;
  final VoidCallback onTap;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return _MailPanelTap(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.media.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 74,
                height: 74,
                child: LifeMediaImage(media: post.media.first),
              ),
            )
          else
            Image.asset(
              LifeSnippetAssets.likeFilled,
              width: 74,
              height: 74,
              filterQuality: FilterQuality.high,
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onProfile,
                  child: _MailTileHeader(
                    title: author.displayName,
                    trailing: _clockLabel(post.createdAt),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 10),
                _MailPostCounts(
                  commentCount: commentCount,
                  likeCount: likeCount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendRequestTile extends StatelessWidget {
  const _FriendRequestTile({
    required this.user,
    required this.onProfile,
    required this.onAccept,
  });

  final LifeSnippetUser user;
  final VoidCallback onProfile;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return _MailUserTile(
      user: user,
      onProfile: onProfile,
      trailing: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onAccept,
        child: Image.asset(
          ProfileCenterAssets.follow,
          width: 92,
          height: 36,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  const _FriendTile({
    required this.user,
    required this.onProfile,
    required this.onChat,
  });

  final LifeSnippetUser user;
  final VoidCallback onProfile;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    return _MailUserTile(
      user: user,
      onProfile: onProfile,
      trailing: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChat,
        child: Container(
          width: 48,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: lifePurple,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Image.asset(
            LifeSnippetAssets.send,
            width: 22,
            height: 22,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}

class _MailUserTile extends StatelessWidget {
  const _MailUserTile({
    required this.user,
    required this.onProfile,
    required this.trailing,
  });

  final LifeSnippetUser user;
  final VoidCallback onProfile;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return _MailPanelTap(
      onTap: onProfile,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LifeAvatar(user: user, radius: 28, onTap: onProfile),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
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
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  user.regionLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFBD78FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  user.signatureLine,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.58),
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          trailing,
        ],
      ),
    );
  }
}

class _MailPanelTap extends StatelessWidget {
  const _MailPanelTap({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(13, 13, 13, 13),
        decoration: BoxDecoration(
          color: lifePanel.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: child,
      ),
    );
  }
}

class _MailTileHeader extends StatelessWidget {
  const _MailTileHeader({required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.1,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          trailing,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.32),
            fontSize: 12,
            height: 1,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _MailPostCounts extends StatelessWidget {
  const _MailPostCounts({required this.commentCount, required this.likeCount});

  final int commentCount;
  final int likeCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MailCount(asset: LifeSnippetAssets.comment, count: commentCount),
        const SizedBox(width: 18),
        _MailCount(asset: LifeSnippetAssets.likeFilled, count: likeCount),
      ],
    );
  }
}

class _MailCount extends StatelessWidget {
  const _MailCount({required this.asset, required this.count});

  final String asset;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          asset,
          width: 18,
          height: 18,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.42),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _MailEmptyArtwork extends StatelessWidget {
  const _MailEmptyArtwork();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        ProfileCenterAssets.empty,
        width: 188,
        height: 214,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

Future<void> _openPost(BuildContext context, String postKey) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => LifeSnippetDetailScreen(postKey: postKey),
    ),
  );
}

Future<void> _openProfile(BuildContext context, String userKey) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => LifeSnippetProfileScreen(userKey: userKey),
    ),
  );
}

Future<void> _openChat(BuildContext context, String userKey) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (_) => LifeSnippetChatScreen(userKey: userKey)),
  );
}

String _clockLabel(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
