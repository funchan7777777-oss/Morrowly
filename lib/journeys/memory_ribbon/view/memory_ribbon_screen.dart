import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:morrowly/journeys/present_grounding/data/keeper_memory_store.dart';
import 'package:morrowly/journeys/present_grounding/models/keeper_memory_thread.dart';
import 'package:morrowly/journeys/present_grounding/view/memory_release_screen.dart';
import 'package:morrowly/journeys/present_grounding/view/keeper_home_screen.dart';
import 'package:morrowly/journeys/present_grounding/widgets/keeper_memory_widgets.dart';
import 'package:morrowly/journeys/time_capsule/data/local_capsule_store.dart';
import 'package:morrowly/journeys/time_capsule/models/capsule_chronicle.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_widgets.dart';
import 'package:morrowly/journeys/tomorrow_compass/data/tomorrow_compass_store.dart';
import 'package:morrowly/journeys/welcome_gate/data/local_gate_store.dart';
import 'package:morrowly/journeys/welcome_gate/models/legal_document_marker.dart';
import 'package:morrowly/journeys/welcome_gate/view/legal_document_viewer.dart';
import 'package:morrowly/shared/data/morrowly_country_names.dart';
import 'package:morrowly/shared/economy/morrowly_wallet_screen.dart';
import 'package:morrowly/shared/economy/morrowly_wallet_store.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';
import 'package:morrowly/shared/moderation/morrowly_content_safety.dart';
import 'package:morrowly/shared/widgets/morrowly_avatar_placeholder.dart';
import 'package:morrowly/shared/widgets/morrowly_safety_notice.dart';
import 'package:path_provider/path_provider.dart';

abstract final class ProfileCenterAssets {
  static const backgroundWash =
      'assets/morrowly_art/ui/morrowly_ui_shareable.png';
  static const coin = 'assets/morrowly_art/ui/morrowly_ui_timelock.png';
  static const panel = 'assets/morrowly_art/ui/morrowly_ui_cradle.png';
  static const blacklistTile =
      'assets/morrowly_art/ui/morrowly_ui_serendipity.png';
  static const underline = 'assets/morrowly_art/ui/morrowly_ui_tether.png';
  static const follow = 'assets/morrowly_art/ui/morrowly_ui_together.png';
  static const logOut = 'assets/morrowly_art/ui/morrowly_ui_affinity.png';
  static const save = 'assets/morrowly_art/ui/morrowly_ui_pledge.png';
  static const followStat = 'assets/morrowly_art/ui/morrowly_ui_fellowship.png';
  static const messageStat = 'assets/morrowly_art/ui/morrowly_ui_journal.png';
  static const fanStat = 'assets/morrowly_art/ui/morrowly_ui_entrust.png';
  static const likeStat = 'assets/morrowly_art/ui/morrowly_ui_dispatch.png';
  static const placeholderAvatar =
      'assets/morrowly_art/ui/morrowly_ui_memoir.png';
  static const deleteWide = 'assets/morrowly_art/ui/morrowly_ui_storyline.png';
  static const deleteCompact = 'assets/morrowly_art/ui/morrowly_ui_sunrise.png';
  static const goCheck = 'assets/morrowly_art/ui/morrowly_ui_interval.png';
  static const edit = 'assets/morrowly_art/ui/morrowly_ui_messenger.png';
  static const camera = 'assets/morrowly_art/ui/morrowly_ui_continuum.png';
  static const message = 'assets/morrowly_art/ui/morrowly_ui_awakening.png';
  static const settingsDelete =
      'assets/morrowly_art/ui/morrowly_ui_recollection.png';
  static const settingsDoc = 'assets/morrowly_art/ui/morrowly_ui_moonrise.png';
  static const settingsGuide =
      'assets/morrowly_art/ui/morrowly_ui_resonance.png';
  static const settingsPrivacy =
      'assets/morrowly_art/ui/morrowly_ui_remnant.png';
  static const capsuleBanner =
      'assets/morrowly_art/ui/morrowly_ui_heritage.png';
  static const countdown = 'assets/morrowly_art/ui/morrowly_ui_countdown.png';
  static const capsuleArchived =
      'assets/morrowly_art/ui/morrowly_ui_encounter.png';
  static const capsuleOpening =
      'assets/morrowly_art/ui/morrowly_ui_evergreen.png';
  static const capsuleUnlocked =
      'assets/morrowly_art/ui/morrowly_ui_foreword.png';
  static const empty = 'assets/morrowly_art/ui/morrowly_ui_reminder.png';
  static const phone = 'assets/morrowly_art/ui/morrowly_ui_lantern.png';
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
  final KeeperMemoryStore _store = KeeperMemoryStore.instance;
  final LocalCapsuleStore _capsules = LocalCapsuleStore.instance;
  late final Future<void> _loadFuture = Future.wait([
    _store.load(),
    _capsules.load(),
    MorrowlyWalletStore.instance.load(),
  ]);

  @override
  Widget build(BuildContext context) {
    return MorrowlyMemoryStage(
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
              final user = _store.signedInKeeper;
              final approvedPosts = _store.postsForUser(user.keeperId);
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
                              keptCapsuleCount: _capsules.archivedCount,
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
                              pendingCount: _store.reviewQueueSeals.length,
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
      MaterialPageRoute(builder: (_) => const MemoryReleaseScreen()),
    );
  }

  Future<void> _deletePost(MemorySeal post) async {
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
        onTap: () => _confirmSignOut(context, deleteAccount: true),
        isDestructive: true,
      ),
    ];

    return MorrowlyMemoryStage(
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
                  MorrowlyFrameGuard.topBarContentClearance(context),
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
          MorrowlyMemoryTopBar(
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
      await KeeperMemoryStore.instance.clearLocalAccountData();
      await LocalCapsuleStore.instance.clear();
      await TomorrowCompassStore.instance.clear();
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
  final KeeperMemoryStore _store = KeeperMemoryStore.instance;
  late final Future<void> _loadFuture = _store.load();

  @override
  Widget build(BuildContext context) {
    return MorrowlyMemoryStage(
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
                          MorrowlyFrameGuard.topBarContentClearance(context),
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
                  MorrowlyMemoryTopBar(
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

  Future<void> _unblockUser(KeeperProfile user) async {
    await _store.unblockUser(user.keeperId);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${user.publicName} has been removed from blacklist.'),
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
    final store = KeeperMemoryStore.instance;
    return MorrowlyMemoryStage(
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
                      MorrowlyFrameGuard.topBarContentClearance(context),
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
                                user.keeperId,
                              );
                              return _RelationshipRow(
                                user: user,
                                trailing: status == KeeperLinkState.requested
                                    ? const _RequestedBadge()
                                    : Image.asset(
                                        status == KeeperLinkState.following
                                            ? MorrowlyAssetKit.followed
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
              MorrowlyMemoryTopBar(
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
    return MorrowlyMemoryStage(
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
                          MorrowlyFrameGuard.topBarContentClearance(context),
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
                                          capsule.sourceNote.sealId,
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
                  MorrowlyMemoryTopBar(
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

  List<PublicCapsuleSeal> get _filteredCapsules {
    return switch (_selectedIndex) {
      1 => _store.capsules.where((capsule) => !capsule.canOpenNow).toList(),
      2 => _store.capsules.where((capsule) => capsule.canOpenNow).toList(),
      _ => _store.capsules,
    };
  }

  _ProfileCapsule _profileCapsuleFromNote(PublicCapsuleSeal note) {
    final status = note.canOpenNow
        ? _CapsuleProfileStatus.unlocked
        : _CapsuleProfileStatus.opening;
    return _ProfileCapsule(
      title: note.canOpenNow
          ? 'Can be opened'
          : 'Opens ${capsuleDateStamp(note.unlocksAt)}',
      status: status,
      shelfScope: note.shelfScope == CapsuleShelfScope.publicSquare
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
    return MorrowlyMemoryStage(
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
                    MorrowlyFrameGuard.topBarContentClearance(context),
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
                              _avatarPath.isEmpty
                                  ? MorrowlyAvatarPlaceholder(
                                      radius: 70,
                                      label: _nameController.text,
                                    )
                                  : CircleAvatar(
                                      radius: 70,
                                      backgroundColor: Colors.white,
                                      backgroundImage: FileImage(
                                        File(_avatarPath),
                                      ),
                                    ),
                              Positioned(
                                right: 8,
                                bottom: 8,
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFB66DFF),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.18,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.photo_camera_rounded,
                                    color: Colors.white,
                                    size: 18,
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
                        hint: 'Name shown on your capsules',
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
                        hint: 'A quiet line for future you',
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
          MorrowlyMemoryTopBar(
            title: '',
            onBack: () => Navigator.of(context).pop(),
          ),
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
      _nameController.text = gateStore.savedKeeperName;
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
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.58),
      isScrollControlled: true,
      builder: (context) => _CountrySelectionSheet(selectedCountry: _country),
    );
    if (selected != null) {
      setState(() => _country = selected);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      await KeeperMemoryStore.instance.updateCurrentUserProfile(
        publicName: _nameController.text.trim().isEmpty
            ? 'New Timekeeper'
            : _nameController.text,
        morrowLine: _signatureController.text,
        localPortraitPath: _avatarPath,
        gender: _gender,
        region: _country,
        birthDate: _birthController.text,
      );
    } on MorrowlyContentSafetyException catch (issue) {
      if (mounted) {
        setState(() => _saving = false);
        await showMorrowlySafetyNotice(context, issue);
      }
      return;
    }
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
    return MorrowlyMemoryStage(
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
                  MorrowlyFrameGuard.topBarContentClearance(context),
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
                          'Use Report on unsafe posts, comments, profiles, or chats. Use Block when you do not want another person to appear in your experience. Reported content and blocked users are hidden locally right away while the safety record is saved on this device.',
                    ),
                    _GuidelineSection(
                      title: 'Respect future recipients',
                      body:
                          'Time capsules should preserve wishes, memories, and meaningful notes. Do not use capsules to store abusive messages, unwanted contact attempts, financial manipulation, or content intended to embarrass or harm someone later.',
                    ),
                    _GuidelineSection(
                      title: 'Enforcement',
                      body:
                          'Morrowly may hide reported content, restrict chat actions, remove abusive posts after review, or require account changes when a profile or post violates these rules. Safety concerns should be handled promptly through the app support contact configured on the App Store listing.',
                    ),
                  ],
                ),
              );
            },
          ),
          MorrowlyMemoryTopBar(
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
                  'These rules keep memory seals, capsules, comments, and mutual-follow chat safe for real people.',
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

  final KeeperProfile user;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KeeperAvatar(user: user, radius: 34),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      user.publicName,
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
                      user.profileTrail,
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
                user.morrowLine,
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
    required this.keptCapsuleCount,
    required this.onFollow,
    required this.onFans,
    required this.onLikes,
    required this.onCapsules,
  });

  final KeeperProfile user;
  final int keptCapsuleCount;
  final VoidCallback onFollow;
  final VoidCallback onFans;
  final VoidCallback onLikes;
  final VoidCallback onCapsules;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _StatButton(
          value: user.followingCount,
          label: 'Follow',
          onTap: onFollow,
        ),
        _StatButton(value: user.followerCount, label: 'Fans', onTap: onFans),
        _StatButton(value: user.glowCount, label: 'Get likes', onTap: onLikes),
        _StatButton(
          value: keptCapsuleCount,
          label: 'Capsule',
          onTap: onCapsules,
        ),
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

  final KeeperProfile user;
  final List<MemorySeal> posts;
  final int pendingCount;
  final VoidCallback onCompose;
  final ValueChanged<MemorySeal> onDelete;

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
          _EmptyPostMark(hasPending: hasPending),
          const SizedBox(height: 10),
          Text(
            hasPending
                ? '$pendingCount memory seal${pendingCount == 1 ? '' : 's'} waiting for review. It will appear here only after approval.'
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
              MorrowlyAssetKit.release,
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

class _EmptyPostMark extends StatelessWidget {
  const _EmptyPostMark({required this.hasPending});

  final bool hasPending;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 76,
      child: CustomPaint(
        painter: _EmptyPostMarkPainter(hasPending: hasPending),
      ),
    );
  }
}

class _EmptyPostMarkPainter extends CustomPainter {
  const _EmptyPostMarkPainter({required this.hasPending});

  final bool hasPending;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final accent = hasPending
        ? const Color(0xFFFFD97A)
        : const Color(0xFFFF78C8);

    final baseGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          accent.withValues(alpha: 0.36),
          const Color(0xFFB66DFF).withValues(alpha: 0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(w * 0.1, h * 0.04, w * 0.8, h * 0.86))
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.52),
        width: w * 0.8,
        height: h * 0.72,
      ),
      baseGlow,
    );

    final floorShadow = Paint()
      ..color = const Color(0xFF2A1436).withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.76),
        width: w * 0.54,
        height: h * 0.12,
      ),
      floorShadow,
    );

    final backPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.22, h * 0.24, w * 0.48, h * 0.43),
        Radius.circular(w * 0.08),
      ),
      backPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.32, h * 0.18, w * 0.44, h * 0.48),
        Radius.circular(w * 0.08),
      ),
      backPaint..color = Colors.white.withValues(alpha: 0.12),
    );

    final cardShadow = Paint()
      ..color = const Color(0xFF3F2650).withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.3, h * 0.23, w * 0.42, h * 0.5),
      Radius.circular(w * 0.07),
    );
    canvas.drawRRect(cardRect.shift(Offset(0, h * 0.035)), cardShadow);

    final cardPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFFFF), Color(0xFFEFE1FF)],
      ).createShader(cardRect.outerRect);
    canvas.drawRRect(cardRect, cardPaint);

    final fold = Path()
      ..moveTo(w * 0.62, h * 0.23)
      ..lineTo(w * 0.72, h * 0.33)
      ..lineTo(w * 0.62, h * 0.33)
      ..close();
    final foldPaint = Paint()
      ..color = const Color(0xFFE9D5FF)
      ..style = PaintingStyle.fill;
    canvas.drawPath(fold, foldPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF8754D5).withValues(alpha: 0.72)
      ..strokeWidth = w * 0.032
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.39, h * 0.44),
      Offset(w * 0.58, h * 0.44),
      linePaint,
    );
    canvas.drawLine(
      Offset(w * 0.39, h * 0.54),
      Offset(w * 0.63, h * 0.54),
      linePaint,
    );

    final badgeCenter = Offset(w * 0.68, h * 0.64);
    final badgeRadius = w * 0.135;
    final badgePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: hasPending
            ? const [Color(0xFFFFEF9E), Color(0xFFFF907A)]
            : const [Color(0xFFFF91D3), Color(0xFFFF4F9D)],
      ).createShader(Rect.fromCircle(center: badgeCenter, radius: badgeRadius));
    canvas.drawCircle(badgeCenter, badgeRadius, badgePaint);

    final badgeStroke = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..strokeWidth = w * 0.032
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    if (hasPending) {
      canvas.drawCircle(badgeCenter, badgeRadius * 0.55, badgeStroke);
      canvas.drawLine(
        badgeCenter,
        Offset(badgeCenter.dx, badgeCenter.dy - badgeRadius * 0.35),
        badgeStroke,
      );
      canvas.drawLine(
        badgeCenter,
        Offset(badgeCenter.dx + badgeRadius * 0.34, badgeCenter.dy),
        badgeStroke,
      );
    } else {
      final check = Path()
        ..moveTo(w * 0.61, h * 0.64)
        ..lineTo(w * 0.67, h * 0.7)
        ..lineTo(w * 0.76, h * 0.58);
      canvas.drawPath(check, badgeStroke);
    }

    final sparklePaint = Paint()
      ..color = accent.withValues(alpha: 0.74)
      ..strokeWidth = w * 0.018
      ..strokeCap = StrokeCap.round;
    _drawSpark(canvas, Offset(w * 0.22, h * 0.32), w * 0.044, sparklePaint);
    _drawSpark(canvas, Offset(w * 0.78, h * 0.24), w * 0.034, sparklePaint);
  }

  void _drawSpark(Canvas canvas, Offset center, double radius, Paint paint) {
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _EmptyPostMarkPainter oldDelegate) {
    return oldDelegate.hasPending != hasPending;
  }
}

class _ProfilePostCard extends StatelessWidget {
  const _ProfilePostCard({
    required this.user,
    required this.post,
    required this.onDelete,
  });

  final KeeperProfile user;
  final MemorySeal post;
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
              KeeperAvatar(user: user, radius: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.publicName,
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
                            user.profileTrail,
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
          if (post.noteLine.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              post.noteLine,
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
          if (post.attachments.isNotEmpty) ...[
            const SizedBox(height: 11),
            _ProfilePostMediaGrid(attachments: post.attachments),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              _ProfilePostCount(
                asset: MorrowlyAssetKit.comment,
                count: post.replyCount,
              ),
              const SizedBox(width: 28),
              _ProfilePostCount(
                asset: MorrowlyAssetKit.likeOutline,
                count: post.glowCount,
              ),
              const Spacer(),
              Image.asset(
                MorrowlyAssetKit.more,
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
  const _ProfilePostMediaGrid({required this.attachments});

  final List<MemoryAttachment> attachments;

  @override
  Widget build(BuildContext context) {
    final visible = attachments.take(2).toList();
    if (visible.length == 1) {
      return AspectRatio(
        aspectRatio: 1.62,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: MemoryAttachmentImage(attachment: visible.first),
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
                child: MemoryAttachmentImage(attachment: visible[index]),
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
    this.isDestructive = false,
  });

  final String label;
  final String asset;
  final VoidCallback onTap;
  final bool isDestructive;
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({required this.item});

  final _SettingItem item;

  @override
  Widget build(BuildContext context) {
    final labelColor = item.isDestructive
        ? const Color(0xFFFF3A78)
        : const Color(0xFFB9A8C0);

    return Semantics(
      label: item.label,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: item.onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              item.asset,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
            ),
            Align(
              alignment: const Alignment(0, 0.36),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.label,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 13,
                      height: 1.08,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.24),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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

  final KeeperProfile user;
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
          KeeperAvatar(
            user: user,
            radius: 28,
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => KeeperHomeScreen(keeperId: user.keeperId),
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
                  user.publicName,
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
                  user.profileTrail,
                  style: const TextStyle(
                    color: Color(0xFFBD78FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.morrowLine,
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
            'Nothing sealed here yet',
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

enum _CapsuleProfileStatus { opening, unlocked }

class _ProfileCapsule {
  const _ProfileCapsule({
    required this.title,
    required this.status,
    required this.shelfScope,
    required this.asset,
    required this.date,
    required this.sourceNote,
  });

  final String title;
  final _CapsuleProfileStatus status;
  final String shelfScope;
  final String asset;
  final String date;
  final PublicCapsuleSeal sourceNote;
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
              color: capsule.shelfScope == 'Public'
                  ? const Color(0xFFC5CBFF)
                  : const Color(0xFFE7BCFF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              capsule.shelfScope,
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
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
            child: Container(
              width: double.infinity,
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

class _CountrySelectionSheet extends StatefulWidget {
  const _CountrySelectionSheet({required this.selectedCountry});

  final String selectedCountry;

  @override
  State<_CountrySelectionSheet> createState() => _CountrySelectionSheetState();
}

class _CountrySelectionSheetState extends State<_CountrySelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = _query.trim().toLowerCase();
    final countries = normalizedQuery.isEmpty
        ? morrowlyCountryNames
        : morrowlyCountryNames
              .where(
                (country) => country.toLowerCase().contains(normalizedQuery),
              )
              .toList(growable: false);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Container(
              width: double.infinity,
              height: MediaQuery.sizeOf(context).height * 0.72,
              margin: const EdgeInsets.all(18),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              decoration: BoxDecoration(
                color: lifePanel,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      cursorColor: Colors.white,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.search_rounded,
                          color: Colors.white.withValues(alpha: 0.58),
                        ),
                        hintText: 'Search country',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.46),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: countries.isEmpty
                        ? Center(
                            child: Text(
                              'No country found',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.58),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          )
                        : ListView.separated(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            itemCount: countries.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 2),
                            itemBuilder: (context, index) {
                              final country = countries[index];
                              final selected =
                                  country == widget.selectedCountry;
                              return ListTile(
                                dense: true,
                                visualDensity: VisualDensity.compact,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                selected: selected,
                                selectedTileColor: Colors.white.withValues(
                                  alpha: 0.08,
                                ),
                                title: Text(
                                  country,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: selected
                                        ? FontWeight.w900
                                        : FontWeight.w800,
                                    letterSpacing: 0,
                                  ),
                                ),
                                trailing: selected
                                    ? const Icon(
                                        Icons.check_circle_rounded,
                                        color: lifePurple,
                                        size: 20,
                                      )
                                    : null,
                                onTap: () => Navigator.of(context).pop(country),
                              );
                            },
                          ),
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
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 336),
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
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 336),
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
      ),
    );
  }
}
