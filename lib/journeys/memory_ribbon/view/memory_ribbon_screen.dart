import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:morrowly/journeys/present_grounding/data/life_snippet_store.dart';
import 'package:morrowly/journeys/present_grounding/models/life_snippet_models.dart';
import 'package:morrowly/journeys/present_grounding/view/life_snippet_compose_screen.dart';
import 'package:morrowly/journeys/present_grounding/view/life_snippet_profile_screen.dart';
import 'package:morrowly/journeys/present_grounding/widgets/life_snippet_widgets.dart';
import 'package:morrowly/journeys/time_capsule/data/local_capsule_store.dart';
import 'package:morrowly/journeys/time_capsule/models/capsule_chronicle.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_widgets.dart';
import 'package:morrowly/journeys/welcome_gate/data/local_gate_store.dart';
import 'package:morrowly/journeys/welcome_gate/models/legal_document_marker.dart';
import 'package:morrowly/journeys/welcome_gate/view/legal_document_viewer.dart';
import 'package:morrowly/shared/economy/morrowly_wallet_screen.dart';
import 'package:morrowly/shared/economy/morrowly_wallet_store.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';
import 'package:path_provider/path_provider.dart';

abstract final class ProfileCenterAssets {
  static const backgroundWash = 'assets/images/Shareable.png';
  static const coin = 'assets/images/Timelock.png';
  static const panel = 'assets/images/Cradle.png';
  static const blacklistTile = 'assets/images/Serendipity.png';
  static const underline = 'assets/images/Tether.png';
  static const follow = 'assets/images/Together.png';
  static const logOut = 'assets/images/Affinity.png';
  static const save = 'assets/images/Pledge.png';
  static const followStat = 'assets/images/Fellowship.png';
  static const messageStat = 'assets/images/Journal.png';
  static const fanStat = 'assets/images/Entrust.png';
  static const likeStat = 'assets/images/Dispatch.png';
  static const placeholderAvatar = 'assets/images/Memoir.png';
  static const deleteWide = 'assets/images/Storyline.png';
  static const deleteCompact = 'assets/images/Sunrise.png';
  static const goCheck = 'assets/images/Interval.png';
  static const edit = 'assets/images/Messenger.png';
  static const camera = 'assets/images/Continuum.png';
  static const message = 'assets/images/Awakening.png';
  static const send = 'assets/images/Compass.png';
  static const settingsDelete = 'assets/images/Recollection.png';
  static const settingsDoc = 'assets/images/Moonrise.png';
  static const settingsGuide = 'assets/images/Resonance.png';
  static const settingsPrivacy = 'assets/images/Remnant.png';
  static const capsuleBanner = 'assets/images/Heritage.png';
  static const countdown = 'assets/images/Countdown.png';
  static const capsuleArchived = 'assets/images/Encounter.png';
  static const capsuleOpening = 'assets/images/Evergreen.png';
  static const capsuleUnlocked = 'assets/images/Foreword.png';
  static const empty = 'assets/images/Reminder.png';
  static const phone = 'assets/images/Lantern.png';
}

class MemoryRibbonScreen extends StatefulWidget {
  const MemoryRibbonScreen({
    super.key,
    this.onSignedOut,
    this.onLoggedOut,
    this.onAccountDeleted,
  });

  final VoidCallback? onSignedOut;
  final VoidCallback? onLoggedOut;
  final VoidCallback? onAccountDeleted;

  @override
  State<MemoryRibbonScreen> createState() => _MemoryRibbonScreenState();
}

class _MemoryRibbonScreenState extends State<MemoryRibbonScreen> {
  final LifeSnippetStore _store = LifeSnippetStore.instance;
  final LocalCapsuleStore _capsules = LocalCapsuleStore.instance;
  late final Future<void> _loadFuture = Future.wait([
    _store.load(),
    _capsules.load(),
    MorrowlyWalletStore.instance.load(),
  ]);

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
            animation: Listenable.merge([_store, _capsules]),
            builder: (context, _) {
              final user = _store.currentUser;
              final approvedPosts = _store.postsForUser(user.userKey);
              return Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      ProfileCenterAssets.backgroundWash,
                      fit: BoxFit.cover,
                      opacity: const AlwaysStoppedAnimation(0.18),
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
                            extra: 4,
                          ),
                          side,
                          MorrowlyFrameGuard.bottomClearance(
                            context,
                            minimum: 52,
                            extra: 24,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ProfileTopChrome(
                              onBack: _closeProfileCenter,
                              onSettings: _openSettings,
                              onWallet: _openWallet,
                            ),
                            const SizedBox(height: 26),
                            _ProfileHeader(
                              user: user,
                              onEdit: _openEditProfile,
                            ),
                            const SizedBox(height: 30),
                            _ProfileStats(
                              user: user,
                              capsuleCount: _capsules.archivedCount,
                              onFollow: () => _openRelationshipList(true),
                              onFans: () => _openRelationshipList(false),
                              onLikes: _openWallet,
                              onCapsules: _openMyCapsules,
                            ),
                            const SizedBox(height: 28),
                            const Text(
                              'My capsules',
                              style: _sectionTitleStyle,
                            ),
                            const SizedBox(height: 14),
                            _CapsuleSummaryRow(
                              archivedCount: _capsules.archivedCount,
                              toBeOpenedCount: _capsules.toBeOpenedCount,
                              unlockedCount: _capsules.unlockedCount,
                              onOpen: _openMyCapsules,
                            ),
                            const SizedBox(height: 24),
                            const Text('My post', style: _sectionTitleStyle),
                            const SizedBox(height: 12),
                            _MyPostsPanel(
                              user: user,
                              posts: approvedPosts,
                              pendingCount: _store.pendingReviewPosts.length,
                              onCompose: _openCompose,
                              onDelete: _deletePost,
                            ),
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

  void _closeProfileCenter() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  Future<void> _openSettings() {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ProfileSettingsScreen(
          onSignedOut: widget.onSignedOut,
          onLoggedOut: widget.onLoggedOut,
          onAccountDeleted: widget.onAccountDeleted,
        ),
      ),
    );
  }

  Future<void> _openWallet() {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const ProfileWalletScreen()),
    );
  }

  Future<void> _openEditProfile() {
    return Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => const ProfileEditScreen()));
  }

  Future<void> _openRelationshipList(bool follow) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ProfileRelationshipListScreen(showFollow: follow),
      ),
    );
  }

  Future<void> _openMyCapsules() {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const ProfileCapsulesScreen()),
    );
  }

  Future<void> _openCompose() {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const LifeSnippetComposeScreen()),
    );
  }

  Future<void> _deletePost(LifeSnippetPost post) async {
    await _store.deleteOwnPostLocally(post);
  }
}

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({
    super.key,
    this.onSignedOut,
    this.onLoggedOut,
    this.onAccountDeleted,
  });

  final VoidCallback? onSignedOut;
  final VoidCallback? onLoggedOut;
  final VoidCallback? onAccountDeleted;

  @override
  Widget build(BuildContext context) {
    final items = [
      _SettingItem(
        label: 'Blacklist',
        asset: ProfileCenterAssets.blacklistTile,
        onTap: () => Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (_) => const ProfileBlacklistScreen()),
        ),
      ),
      _SettingItem(
        label: 'Privacy agreement',
        asset: ProfileCenterAssets.settingsPrivacy,
        onTap: () =>
            _openLegalDocument(context, LegalDocumentMarker.privacyPolicy),
      ),
      _SettingItem(
        label: 'User agreement',
        asset: ProfileCenterAssets.settingsDoc,
        onTap: () =>
            _openLegalDocument(context, LegalDocumentMarker.userAgreement),
      ),
      _SettingItem(
        label: 'Community guidelines',
        asset: ProfileCenterAssets.settingsGuide,
        onTap: () => Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (_) => const CommunityGuidelinesScreen()),
        ),
      ),
      _SettingItem(
        label: 'Deletion of account',
        asset: ProfileCenterAssets.settingsDelete,
        destructive: true,
        onTap: () => _confirmSignOut(context, deleteAccount: true),
      ),
    ];

    return LifeSnippetStage(
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = MorrowlyFrameGuard.contentWidth(
                constraints.maxWidth,
                maxWidth: 430,
                phoneGutter: 20,
              );
              final side = (constraints.maxWidth - contentWidth) / 2;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  side,
                  MorrowlyFrameGuard.topClearance(
                    context,
                    minimum: 102,
                    extra: 34,
                  ),
                  side,
                  34,
                ),
                child: Column(
                  children: [
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (final item in items) _SettingCard(item: item),
                      ],
                    ),
                    const SizedBox(height: 56),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _confirmSignOut(context),
                      child: Image.asset(
                        ProfileCenterAssets.logOut,
                        width: contentWidth * 0.8,
                        height: contentWidth * 0.8 * 108 / 568,
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          LifeTopBar(
            title: 'Setting',
            onBack: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _openLegalDocument(BuildContext context, LegalDocumentMarker document) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => LegalDocumentViewer(document: document),
      ),
    );
  }

  Future<void> _confirmSignOut(
    BuildContext context, {
    bool deleteAccount = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.58),
      builder: (context) => _ProfileConfirmDialog(
        title: deleteAccount ? 'Delete local account?' : 'Log out?',
        message: deleteAccount
            ? 'This clears your local account profile, session, messages, draft posts, and safety records on this device.'
            : 'You can sign in again from the login screen.',
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    await _runSessionExitFlow(context, deleteAccount: deleteAccount);
  }

  Future<void> _runSessionExitFlow(
    BuildContext context, {
    required bool deleteAccount,
  }) async {
    var completed = false;
    StateSetter? dialogSetState;
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.62),
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setState) {
              dialogSetState = setState;
              return _ProfileSessionProgressDialog(
                completed: completed,
                loadingTitle: deleteAccount
                    ? 'Deleting account'
                    : 'Logging out',
                successTitle: deleteAccount ? 'Account deleted' : 'Logged out',
                loadingMessage: deleteAccount
                    ? 'Clearing the local profile and safety records on this device.'
                    : 'Closing your current session.',
                successMessage: deleteAccount
                    ? 'Done. Returning to the guide screen.'
                    : 'Done. Returning to the login screen.',
              );
            },
          );
        },
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 520));
    final gateStore = await LocalGateStore.open();
    if (deleteAccount) {
      await LifeSnippetStore.instance.clearLocalAccountData();
      await LocalCapsuleStore.instance.clear();
      await MorrowlyWalletStore.instance.clearLocalWallet();
      await gateStore.deleteLocalAccount();
    } else {
      await gateStore.signOut();
    }
    await Future<void>.delayed(const Duration(milliseconds: 240));
    completed = true;
    dialogSetState?.call(() {});
    await Future<void>.delayed(const Duration(milliseconds: 820));
    if (!context.mounted) {
      return;
    }
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.of(context).popUntil((route) => route.isFirst);
    if (deleteAccount) {
      if (onAccountDeleted != null) {
        onAccountDeleted!();
      } else {
        onSignedOut?.call();
      }
    } else if (onLoggedOut != null) {
      onLoggedOut!();
    } else {
      onSignedOut?.call();
    }
  }
}

class ProfileBlacklistScreen extends StatefulWidget {
  const ProfileBlacklistScreen({super.key});

  @override
  State<ProfileBlacklistScreen> createState() => _ProfileBlacklistScreenState();
}

class _ProfileBlacklistScreenState extends State<ProfileBlacklistScreen> {
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
              final users = _store.blockedUsers;
              return Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final contentWidth = MorrowlyFrameGuard.contentWidth(
                        constraints.maxWidth,
                        maxWidth: 430,
                        phoneGutter: 20,
                      );
                      final side = (constraints.maxWidth - contentWidth) / 2;
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          side,
                          MorrowlyFrameGuard.topClearance(
                            context,
                            minimum: 102,
                            extra: 34,
                          ),
                          side,
                          34,
                        ),
                        child: users.isEmpty
                            ? const _EmptyCenterPanel()
                            : ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: users.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final user = users[index];
                                  return _RelationshipRow(
                                    user: user,
                                    trailing: _UnblockButton(
                                      onTap: () => _unblockUser(user),
                                    ),
                                  );
                                },
                              ),
                      );
                    },
                  ),
                  LifeTopBar(
                    title: 'Blacklist',
                    onBack: () => Navigator.of(context).pop(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _unblockUser(LifeSnippetUser user) async {
    await _store.unblockUser(user.userKey);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${user.displayName} has been removed from blacklist.'),
        backgroundColor: lifePanel,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class ProfileRelationshipListScreen extends StatelessWidget {
  const ProfileRelationshipListScreen({super.key, required this.showFollow});

  final bool showFollow;

  @override
  Widget build(BuildContext context) {
    final store = LifeSnippetStore.instance;
    return LifeSnippetStage(
      child: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final users = showFollow ? store.followListUsers : store.fanListUsers;
          return Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final contentWidth = MorrowlyFrameGuard.contentWidth(
                    constraints.maxWidth,
                    maxWidth: 430,
                    phoneGutter: 20,
                  );
                  final side = (constraints.maxWidth - contentWidth) / 2;
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      side,
                      MorrowlyFrameGuard.topClearance(
                        context,
                        minimum: 102,
                        extra: 34,
                      ),
                      side,
                      34,
                    ),
                    child: users.isEmpty
                        ? const _EmptyCenterPanel()
                        : ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: users.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final user = users[index];
                              final status = store.followStatusFor(
                                user.userKey,
                              );
                              return _RelationshipRow(
                                user: user,
                                trailing: status == LifeFollowStatus.requested
                                    ? const _RequestedBadge()
                                    : Image.asset(
                                        status == LifeFollowStatus.following
                                            ? LifeSnippetAssets.followed
                                            : ProfileCenterAssets.follow,
                                        width: 92,
                                        height: 36,
                                        fit: BoxFit.fill,
                                        filterQuality: FilterQuality.high,
                                      ),
                              );
                            },
                          ),
                  );
                },
              ),
              LifeTopBar(
                title: showFollow ? 'Follow' : 'Fans',
                onBack: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProfileCapsulesScreen extends StatefulWidget {
  const ProfileCapsulesScreen({super.key});

  @override
  State<ProfileCapsulesScreen> createState() => _ProfileCapsulesScreenState();
}

class _ProfileCapsulesScreenState extends State<ProfileCapsulesScreen> {
  final LocalCapsuleStore _store = LocalCapsuleStore.instance;
  late final Future<void> _loadFuture = _store.load();
  int _selectedIndex = 0;

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
              final filtered = _filteredCapsules
                  .map(_profileCapsuleFromNote)
                  .toList();
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
                      return SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          side,
                          MorrowlyFrameGuard.topClearance(
                            context,
                            minimum: 104,
                            extra: 36,
                          ),
                          side,
                          32,
                        ),
                        child: Column(
                          children: [
                            _CapsuleSegmentedControl(
                              selectedIndex: _selectedIndex,
                              onChanged: (index) {
                                setState(() => _selectedIndex = index);
                              },
                            ),
                            const SizedBox(height: 34),
                            if (filtered.isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(top: 40),
                                child: _EmptyCenterPanel(),
                              )
                            else
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 0.76,
                                    ),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final capsule = filtered[index];
                                  return _CapsuleTile(
                                    capsule: capsule,
                                    onDelete: () {
                                      unawaited(
                                        _store.remove(
                                          capsule.sourceNote.noteKey,
                                        ),
                                      );
                                    },
                                    onCheck: () => _showCapsuleReady(capsule),
                                  );
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  LifeTopBar(
                    title: 'My capsules',
                    onBack: () => Navigator.of(context).pop(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  List<CapsuleSquareNote> get _filteredCapsules {
    return switch (_selectedIndex) {
      1 => _store.capsules.where((capsule) => !capsule.canOpenNow).toList(),
      2 => _store.capsules.where((capsule) => capsule.canOpenNow).toList(),
      _ => _store.capsules,
    };
  }

  _ProfileCapsule _profileCapsuleFromNote(CapsuleSquareNote note) {
    final status = note.canOpenNow
        ? _CapsuleProfileStatus.unlocked
        : _CapsuleProfileStatus.opening;
    return _ProfileCapsule(
      title: note.canOpenNow
          ? 'Can be opened'
          : 'Opens ${capsuleDateStamp(note.openingAt)}',
      status: status,
      visibility: note.visibility == CapsuleVisibility.publicSquare
          ? 'Public'
          : 'Private',
      asset: note.canOpenNow
          ? ProfileCenterAssets.capsuleUnlocked
          : ProfileCenterAssets.capsuleOpening,
      date: '${capsuleDateStamp(note.sealedAt)} seal',
      sourceNote: note,
    );
  }

  void _showCapsuleReady(_ProfileCapsule capsule) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${capsule.title} is ready.'),
        backgroundColor: lifePanel,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class ProfileWalletScreen extends StatelessWidget {
  const ProfileWalletScreen({super.key});

  @override
  Widget build(BuildContext context) => const MorrowlyWalletScreen();
}

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();
  final TextEditingController _signatureController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String _avatarPath = '';
  String _gender = 'female';
  String _country = 'United States';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LifeSnippetStage(
      resizeForKeyboard: true,
      child: Stack(
        children: [
          if (_loading)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth = MorrowlyFrameGuard.contentWidth(
                  constraints.maxWidth,
                  maxWidth: 430,
                  phoneGutter: 22,
                );
                final side = (constraints.maxWidth - contentWidth) / 2;
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    side,
                    MorrowlyFrameGuard.topClearance(
                      context,
                      minimum: 98,
                      extra: 30,
                    ),
                    side,
                    34,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fill in your\ninformation',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          height: 1.04,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'After editing, the data can be saved',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _pickAvatar,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                radius: 70,
                                backgroundColor: Colors.white,
                                backgroundImage: _avatarPath.isEmpty
                                    ? null
                                    : FileImage(File(_avatarPath)),
                                child: _avatarPath.isEmpty
                                    ? Image.asset(
                                        ProfileCenterAssets.camera,
                                        width: 78,
                                        height: 78,
                                        filterQuality: FilterQuality.high,
                                      )
                                    : null,
                              ),
                              Positioned(
                                top: 6,
                                right: 8,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF8F8F),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _EditLabel('Nickname'),
                      _EditInput(
                        controller: _nameController,
                        hint: 'Please enter...',
                      ),
                      _EditLabel('Date of Birth'),
                      _EditInput(
                        controller: _birthController,
                        hint: '2000  00  00',
                        readOnly: true,
                        trailing: Icons.chevron_right_rounded,
                        onTap: _chooseBirthDate,
                      ),
                      _EditLabel('Gender selection'),
                      Row(
                        children: [
                          Expanded(
                            child: _GenderButton(
                              label: 'Female',
                              selected: _gender == 'female',
                              color: const Color(0xFFFF67B2),
                              onTap: () => setState(() => _gender = 'female'),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: _GenderButton(
                              label: 'Male',
                              selected: _gender == 'male',
                              color: const Color(0xFF42B5F5),
                              onTap: () => setState(() => _gender = 'male'),
                            ),
                          ),
                        ],
                      ),
                      _EditLabel('Select country'),
                      _SelectionPill(label: _country, onTap: _chooseCountry),
                      _EditLabel('Signature'),
                      _EditInput(
                        controller: _signatureController,
                        hint: 'Please enter...',
                        minLines: 3,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 34),
                      Center(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _saving ? null : _saveProfile,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 140),
                            opacity: _saving ? 0.56 : 1,
                            child: Image.asset(
                              ProfileCenterAssets.save,
                              width: contentWidth * 0.82,
                              height: contentWidth * 0.82 * 108 / 568,
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
          LifeTopBar(title: '', onBack: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }

  Future<void> _loadProfile() async {
    final gateStore = await LocalGateStore.open();
    if (!mounted) {
      return;
    }
    setState(() {
      _nameController.text = gateStore.savedDisplayName;
      _signatureController.text = gateStore.savedSignatureLine;
      _birthController.text = gateStore.savedBirthDate;
      _avatarPath = gateStore.savedAvatarPath;
      _gender = gateStore.savedGender.isEmpty
          ? 'female'
          : gateStore.savedGender;
      _country = gateStore.savedRegion;
      _loading = false;
    });
  }

  Future<void> _pickAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.58),
      builder: (_) => const _ProfilePhotoSourceSheet(),
    );
    if (source == null || !mounted) {
      return;
    }

    final image = await _picker.pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (image == null) {
      return;
    }
    final directory = await getApplicationDocumentsDirectory();
    final extension = image.path.split('.').last;
    final target = File(
      '${directory.path}/profile-${DateTime.now().microsecondsSinceEpoch}.$extension',
    );
    await File(image.path).copy(target.path);
    if (mounted) {
      setState(() => _avatarPath = target.path);
    }
  }

  Future<void> _chooseBirthDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 23, now.month, now.day),
      firstDate: DateTime(1940),
      lastDate: now,
    );
    if (selected == null) {
      return;
    }
    final month = selected.month.toString().padLeft(2, '0');
    final day = selected.day.toString().padLeft(2, '0');
    setState(() => _birthController.text = '${selected.year} $month $day');
  }

  Future<void> _chooseCountry() async {
    final countries = ['United States', 'Australia', 'Canada', 'France'];
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(18),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: lifePanel,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final country in countries)
                  ListTile(
                    title: Text(
                      country,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onTap: () => Navigator.of(context).pop(country),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null) {
      setState(() => _country = selected);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    await LifeSnippetStore.instance.updateCurrentUserProfile(
      displayName: _nameController.text.trim().isEmpty
          ? 'Morrowly friend'
          : _nameController.text,
      signatureLine: _signatureController.text,
      avatarLocalPath: _avatarPath,
      gender: _gender,
      region: _country,
      birthDate: _birthController.text,
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }
}

class CommunityGuidelinesScreen extends StatelessWidget {
  const CommunityGuidelinesScreen({super.key});

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
                phoneGutter: 22,
              );
              final side = (constraints.maxWidth - contentWidth) / 2;
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  side,
                  MorrowlyFrameGuard.topClearance(
                    context,
                    minimum: 104,
                    extra: 36,
                  ),
                  side,
                  34,
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: const [
                    _GuidelineHero(),
                    SizedBox(height: 14),
                    _GuidelineSection(
                      title: 'Real identity, real consent',
                      body:
                          'Morrowly does not support anonymous or random chat. Messaging and video calls are available only when both people have truly followed each other. Do not impersonate another person, pressure someone to follow back, or create misleading profiles.',
                    ),
                    _GuidelineSection(
                      title: 'Keep memories safe',
                      body:
                          'Posts, comments, capsules, names, avatars, and messages must not include harassment, threats, hate, sexual content involving minors, explicit sexual solicitation, self-harm encouragement, illegal activity, scams, spam, or private information about another person.',
                    ),
                    _GuidelineSection(
                      title: 'Review before public display',
                      body:
                          'New public posts are submitted for review first. A successful release message means the post was received; it does not mean the post is already public. Content appears only after review approval.',
                    ),
                    _GuidelineSection(
                      title: 'Report and block',
                      body:
                          'Use Report on unsafe posts or comments. Use Block when you do not want another person to appear in your experience. Reported comments and blocked users are hidden locally right away while the safety record is saved on this device.',
                    ),
                    _GuidelineSection(
                      title: 'Respect future recipients',
                      body:
                          'Time capsules should preserve wishes, memories, and meaningful notes. Do not use capsules to store abusive messages, unwanted contact attempts, financial manipulation, or content intended to embarrass or harm someone later.',
                    ),
                    _GuidelineSection(
                      title: 'Enforcement',
                      body:
                          'Morrowly may hide reported content, restrict chat actions, remove abusive posts after review, or require account changes when a profile or post violates these rules. For safety support, use the support contact published on the app listing.',
                    ),
                  ],
                ),
              );
            },
          ),
          LifeTopBar(
            title: 'Community guidelines',
            onBack: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _GuidelineHero extends StatelessWidget {
  const _GuidelineHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: lifePanel.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Image.asset(
            ProfileCenterAssets.settingsGuide,
            width: 68,
            height: 68,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preserve wishes without harm',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'These rules keep Life Snippets, capsules, comments, and mutual-follow chat safe for real people.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.62),
                    fontSize: 12,
                    height: 1.36,
                    fontWeight: FontWeight.w700,
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

class _GuidelineSection extends StatelessWidget {
  const _GuidelineSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: lifePanel.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.66),
              fontSize: 12,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

const _sectionTitleStyle = TextStyle(
  color: Colors.white,
  fontSize: 16,
  fontWeight: FontWeight.w900,
  letterSpacing: 0,
);

class _ProfileTopChrome extends StatelessWidget {
  const _ProfileTopChrome({
    required this.onBack,
    required this.onSettings,
    required this.onWallet,
  });

  final VoidCallback onBack;
  final VoidCallback onSettings;
  final VoidCallback onWallet;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 38, height: 36),
            onPressed: onBack,
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Colors.white,
              size: 28,
            ),
            tooltip: 'Back',
          ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onWallet,
            child: const _ProfileCoinPill(),
          ),
          const SizedBox(width: 12),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
            onPressed: onSettings,
            icon: const Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 24,
            ),
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _ProfileCoinPill extends StatelessWidget {
  const _ProfileCoinPill();

  @override
  Widget build(BuildContext context) {
    return const MorrowlyCoinBalancePill(
      height: 27,
      iconSize: 17,
      fontSize: 12,
      horizontalPadding: 8,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user, required this.onEdit});

  final LifeSnippetUser user;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LifeAvatar(user: user, radius: 34),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      user.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.08,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onEdit,
                    child: Image.asset(
                      ProfileCenterAssets.edit,
                      width: 84,
                      height: 34,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.female_rounded,
                    color: Color(0xFFFF6EEA),
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      user.regionLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFBD78FF),
                        fontSize: 11,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Text(
                user.signatureLine,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 12,
                  height: 1.28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats({
    required this.user,
    required this.capsuleCount,
    required this.onFollow,
    required this.onFans,
    required this.onLikes,
    required this.onCapsules,
  });

  final LifeSnippetUser user;
  final int capsuleCount;
  final VoidCallback onFollow;
  final VoidCallback onFans;
  final VoidCallback onLikes;
  final VoidCallback onCapsules;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _StatButton(value: user.followCount, label: 'Follow', onTap: onFollow),
        _StatButton(value: user.fansCount, label: 'Fans', onTap: onFans),
        _StatButton(value: user.likeCount, label: 'Get likes', onTap: onLikes),
        _StatButton(value: capsuleCount, label: 'Capsule', onTap: onCapsules),
      ],
    );
  }
}

class _StatButton extends StatelessWidget {
  const _StatButton({
    required this.value,
    required this.label,
    required this.onTap,
  });

  final int value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.1,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.38),
                fontSize: 11,
                height: 1.1,
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

class _CapsuleSummaryRow extends StatelessWidget {
  const _CapsuleSummaryRow({
    required this.archivedCount,
    required this.toBeOpenedCount,
    required this.unlockedCount,
    required this.onOpen,
  });

  final int archivedCount;
  final int toBeOpenedCount;
  final int unlockedCount;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SummaryCapsule(
        'Archived',
        '$archivedCount',
        ProfileCenterAssets.capsuleArchived,
      ),
      _SummaryCapsule(
        'To be opened',
        '$toBeOpenedCount',
        ProfileCenterAssets.capsuleOpening,
      ),
      _SummaryCapsule(
        'Unlocked',
        '$unlockedCount',
        ProfileCenterAssets.capsuleUnlocked,
      ),
    ];
    return Row(
      children: [
        for (var index = 0; index < cards.length; index++) ...[
          Expanded(
            child: _CapsuleSummaryCard(data: cards[index], onTap: onOpen),
          ),
          if (index != cards.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _MyPostsPanel extends StatelessWidget {
  const _MyPostsPanel({
    required this.user,
    required this.posts,
    required this.pendingCount,
    required this.onCompose,
    required this.onDelete,
  });

  final LifeSnippetUser user;
  final List<LifeSnippetPost> posts;
  final int pendingCount;
  final VoidCallback onCompose;
  final ValueChanged<LifeSnippetPost> onDelete;

  @override
  Widget build(BuildContext context) {
    if (posts.isNotEmpty) {
      return Column(
        children: [
          for (final post in posts) ...[
            _ProfilePostCard(
              user: user,
              post: post,
              onDelete: () => onDelete(post),
            ),
            if (post != posts.last) const SizedBox(height: 12),
          ],
        ],
      );
    }

    final hasPending = pendingCount > 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
      decoration: BoxDecoration(
        color: lifePanel.withValues(alpha: 0.66),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Image.asset(
            hasPending
                ? ProfileCenterAssets.settingsGuide
                : ProfileCenterAssets.message,
            width: 58,
            height: 58,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(height: 10),
          Text(
            hasPending
                ? '$pendingCount snippet${pendingCount == 1 ? '' : 's'} waiting for review. It will appear here only after approval.'
                : 'No approved posts yet. New posts wait for moderation.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onCompose,
            child: Image.asset(
              LifeSnippetAssets.release,
              width: 176,
              height: 34,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePostCard extends StatelessWidget {
  const _ProfilePostCard({
    required this.user,
    required this.post,
    required this.onDelete,
  });

  final LifeSnippetUser user;
  final LifeSnippetPost post;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 11),
      decoration: BoxDecoration(
        color: lifePanel.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LifeAvatar(user: user, radius: 24),
              const SizedBox(width: 10),
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
                        fontSize: 14,
                        height: 1.08,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.female_rounded,
                          color: Color(0xFFFF6EEA),
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            user.regionLine,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFBD78FF),
                              fontSize: 11,
                              height: 1.1,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _DeletePostPill(onTap: onDelete),
            ],
          ),
          if (post.body.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              post.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.88),
                fontSize: 12,
                height: 1.38,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ],
          if (post.media.isNotEmpty) ...[
            const SizedBox(height: 11),
            _ProfilePostMediaGrid(media: post.media),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              _ProfilePostCount(
                asset: LifeSnippetAssets.comment,
                count: post.commentCount,
              ),
              const SizedBox(width: 28),
              _ProfilePostCount(
                asset: LifeSnippetAssets.likeOutline,
                count: post.likeCount,
              ),
              const Spacer(),
              Image.asset(
                LifeSnippetAssets.more,
                width: 19,
                height: 19,
                color: Colors.white.withValues(alpha: 0.24),
                filterQuality: FilterQuality.high,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeletePostPill extends StatelessWidget {
  const _DeletePostPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Image.asset(
        ProfileCenterAssets.deleteCompact,
        width: 80,
        height: 31,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class _ProfilePostMediaGrid extends StatelessWidget {
  const _ProfilePostMediaGrid({required this.media});

  final List<LifeSnippetMedia> media;

  @override
  Widget build(BuildContext context) {
    final visible = media.take(2).toList();
    if (visible.length == 1) {
      return AspectRatio(
        aspectRatio: 1.62,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LifeMediaImage(media: visible.first),
        ),
      );
    }

    return SizedBox(
      height: 112,
      child: Row(
        children: [
          for (var index = 0; index < visible.length; index++) ...[
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LifeMediaImage(media: visible[index]),
              ),
            ),
            if (index != visible.length - 1) const SizedBox(width: 5),
          ],
        ],
      ),
    );
  }
}

class _ProfilePostCount extends StatelessWidget {
  const _ProfilePostCount({required this.asset, required this.count});

  final String asset;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          asset,
          width: 17,
          height: 17,
          color: Colors.white.withValues(alpha: 0.24),
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.24),
            fontSize: 11,
            height: 1,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _SettingItem {
  const _SettingItem({
    required this.label,
    required this.asset,
    required this.onTap,
    this.destructive = false,
  });

  final String label;
  final String asset;
  final VoidCallback onTap;
  final bool destructive;
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({required this.item});

  final _SettingItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: item.onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: const Color(0xFF4C2A60).withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              ProfileCenterAssets.panel,
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.26),
              filterQuality: FilterQuality.high,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  item.asset,
                  width: 64,
                  height: 64,
                  filterQuality: FilterQuality.high,
                ),
                const SizedBox(height: 14),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: item.destructive
                        ? const Color(0xFFFF4E80)
                        : Colors.white.withValues(alpha: 0.3),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
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

class _UnblockButton extends StatelessWidget {
  const _UnblockButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: lifePurple,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: lifePurple.withValues(alpha: 0.24),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: const Text(
          'Unblock',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _RelationshipRow extends StatelessWidget {
  const _RelationshipRow({required this.user, required this.trailing});

  final LifeSnippetUser user;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: lifePanel.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LifeAvatar(
            user: user,
            radius: 28,
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => LifeSnippetProfileScreen(
                    userKey: user.userKey,
                  ),
                ),
              );
            },
          ),
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
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.regionLine,
                  style: const TextStyle(
                    color: Color(0xFFBD78FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.signatureLine,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 12,
                    height: 1.32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}

class _RequestedBadge extends StatelessWidget {
  const _RequestedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'Requested',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptyCenterPanel extends StatelessWidget {
  const _EmptyCenterPanel();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            ProfileCenterAssets.empty,
            width: 110,
            height: 126,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(height: 10),
          Text(
            'No content',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCapsule {
  const _SummaryCapsule(this.title, this.count, this.asset);

  final String title;
  final String count;
  final String asset;
}

class _CapsuleSummaryCard extends StatelessWidget {
  const _CapsuleSummaryCard({required this.data, required this.onTap});

  final _SummaryCapsule data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 136,
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
        decoration: BoxDecoration(
          color: const Color(0xFF4A285B).withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Image.asset(
              data.asset,
              width: 52,
              height: 52,
              filterQuality: FilterQuality.high,
            ),
            const Spacer(),
            Text(
              data.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                height: 1.1,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              data.count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _CapsuleProfileStatus { archived, opening, unlocked }

class _ProfileCapsule {
  const _ProfileCapsule({
    required this.title,
    required this.status,
    required this.visibility,
    required this.asset,
    required this.date,
    required this.sourceNote,
  });

  final String title;
  final _CapsuleProfileStatus status;
  final String visibility;
  final String asset;
  final String date;
  final CapsuleSquareNote sourceNote;
}

class _CapsuleSegmentedControl extends StatelessWidget {
  const _CapsuleSegmentedControl({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final labels = ['Archived', 'To be opened', 'Unlocked'];
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF3F3044),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          for (var index = 0; index < labels.length; index++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selectedIndex == index
                        ? lifePurple
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    labels[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selectedIndex == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.32),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CapsuleTile extends StatelessWidget {
  const _CapsuleTile({
    required this.capsule,
    required this.onDelete,
    required this.onCheck,
  });

  final _ProfileCapsule capsule;
  final VoidCallback onDelete;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final unlocked = capsule.status == _CapsuleProfileStatus.unlocked;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: lifePanel.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: capsule.visibility == 'Public'
                  ? const Color(0xFFC5CBFF)
                  : const Color(0xFFE7BCFF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              capsule.visibility,
              style: const TextStyle(
                color: Color(0xFF7A5CA4),
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Center(
              child: Image.asset(
                capsule.asset,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          Text(
            capsule.title,
            style: TextStyle(
              color: unlocked ? const Color(0xFFFF4949) : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            capsule.date,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.34),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _SmallCapsuleButton(
                  label: 'Delete',
                  asset: ProfileCenterAssets.deleteCompact,
                  onTap: onDelete,
                ),
              ),
              if (unlocked) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _SmallCapsuleButton(
                    label: 'Check',
                    asset: ProfileCenterAssets.goCheck,
                    onTap: onCheck,
                    filled: true,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallCapsuleButton extends StatelessWidget {
  const _SmallCapsuleButton({
    required this.label,
    required this.onTap,
    this.asset,
    this.filled = false,
  });

  final String label;
  final VoidCallback onTap;
  final String? asset;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: asset == null
          ? Container(
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: filled ? lifePurple : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: filled
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.32),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          : Image.asset(
              asset!,
              height: 30,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: filled ? lifePurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.26),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: filled
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.32),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
    );
  }
}

class _ProfilePhotoSourceSheet extends StatelessWidget {
  const _ProfilePhotoSourceSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF4D3A55),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Profile photo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ProfilePhotoSourceTile(
                      icon: Icons.photo_camera_rounded,
                      label: 'Camera',
                      onTap: () =>
                          Navigator.of(context).pop(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ProfilePhotoSourceTile(
                      icon: Icons.photo_library_rounded,
                      label: 'Album',
                      onTap: () =>
                          Navigator.of(context).pop(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfilePhotoSourceTile extends StatelessWidget {
  const _ProfilePhotoSourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          color: lifePurple.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditLabel extends StatelessWidget {
  const _EditLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 8),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.34),
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EditInput extends StatelessWidget {
  const _EditInput({
    required this.controller,
    required this.hint,
    this.readOnly = false,
    this.trailing,
    this.onTap,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final bool readOnly;
  final IconData? trailing;
  final VoidCallback? onTap;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      minLines: minLines,
      maxLines: maxLines,
      style: const TextStyle(
        color: Color(0xFF48314F),
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFFC8BFCB),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        suffixIcon: trailing == null
            ? null
            : Icon(trailing, color: const Color(0xFFB7ADB9)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(maxLines > 1 ? 24 : 999),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  const _GenderButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              label == 'Female' ? Icons.female_rounded : Icons.male_rounded,
              color: color,
              size: 25,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionPill extends StatelessWidget {
  const _SelectionPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFC8BFCB),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFB7ADB9)),
          ],
        ),
      ),
    );
  }
}

class _ProfileConfirmDialog extends StatelessWidget {
  const _ProfileConfirmDialog({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        decoration: BoxDecoration(
          color: lifePanel,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              ProfileCenterAssets.phone,
              width: 62,
              height: 62,
              filterQuality: FilterQuality.high,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
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
                height: 1.36,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                ),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: lifePurple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Confirm'),
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

class _ProfileSessionProgressDialog extends StatelessWidget {
  const _ProfileSessionProgressDialog({
    required this.completed,
    required this.loadingTitle,
    required this.successTitle,
    required this.loadingMessage,
    required this.successMessage,
  });

  final bool completed;
  final String loadingTitle;
  final String successTitle;
  final String loadingMessage;
  final String successMessage;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
        decoration: BoxDecoration(
          color: lifePanel,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.26),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: completed
                  ? Container(
                      key: const ValueKey('done'),
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: lifePurple,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    )
                  : const SizedBox(
                      key: ValueKey('loading'),
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator(
                        strokeWidth: 5,
                        color: lifePurple,
                        backgroundColor: Color(0xFF6A4C77),
                      ),
                    ),
            ),
            const SizedBox(height: 18),
            Text(
              completed ? successTitle : loadingTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              completed ? successMessage : loadingMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.64),
                fontSize: 12,
                height: 1.36,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
