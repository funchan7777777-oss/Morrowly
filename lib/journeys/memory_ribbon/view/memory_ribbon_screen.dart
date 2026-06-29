import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:morrowly/journeys/present_grounding/data/life_snippet_store.dart';
import 'package:morrowly/journeys/present_grounding/models/life_snippet_models.dart';
import 'package:morrowly/journeys/present_grounding/view/life_snippet_compose_screen.dart';
import 'package:morrowly/journeys/present_grounding/widgets/life_snippet_widgets.dart';
import 'package:morrowly/journeys/welcome_gate/data/local_gate_store.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const settingsContact = 'assets/images/Opening.png';
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
  const MemoryRibbonScreen({super.key, this.onSignedOut});

  final VoidCallback? onSignedOut;

  @override
  State<MemoryRibbonScreen> createState() => _MemoryRibbonScreenState();
}

class _MemoryRibbonScreenState extends State<MemoryRibbonScreen> {
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
              final user = _store.currentUser;
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
                            minimum: 64,
                            extra: 14,
                          ),
                          side,
                          MorrowlyFrameGuard.bottomClearance(
                            context,
                            minimum: 150,
                            extra: 110,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ProfileHeader(
                              user: user,
                              onSettings: _openSettings,
                              onWallet: _openWallet,
                              onEdit: _openEditProfile,
                            ),
                            const SizedBox(height: 28),
                            _ProfileStats(
                              user: user,
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
                            const SizedBox(height: 12),
                            _CapsuleSummaryRow(onOpen: _openMyCapsules),
                            const SizedBox(height: 22),
                            const Text('My post', style: _sectionTitleStyle),
                            const SizedBox(height: 12),
                            _MyPostsPanel(
                              posts: _store.pendingReviewPosts,
                              onCompose: _openCompose,
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

  Future<void> _openSettings() {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ProfileSettingsScreen(onSignedOut: widget.onSignedOut),
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
}

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key, this.onSignedOut});

  final VoidCallback? onSignedOut;

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
        onTap: () => _openInfo(context, 'Privacy agreement'),
      ),
      _SettingItem(
        label: 'User agreement',
        asset: ProfileCenterAssets.settingsDoc,
        onTap: () => _openInfo(context, 'User agreement'),
      ),
      _SettingItem(
        label: 'Contact Us',
        asset: ProfileCenterAssets.settingsContact,
        onTap: () => _openInfo(context, 'Contact Us'),
      ),
      _SettingItem(
        label: 'Community guidelines',
        asset: ProfileCenterAssets.settingsGuide,
        onTap: () => _openInfo(context, 'Community guidelines'),
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

  void _openInfo(BuildContext context, String title) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => ProfileInfoScreen(title: title)),
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
            ? 'This clears the active local session on this device. Your public moderation and safety records remain stored locally.'
            : 'You can sign in again from the welcome screen.',
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    final gateStore = await LocalGateStore.open();
    await gateStore.signOut();
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
    onSignedOut?.call();
  }
}

class ProfileBlacklistScreen extends StatefulWidget {
  const ProfileBlacklistScreen({super.key});

  @override
  State<ProfileBlacklistScreen> createState() => _ProfileBlacklistScreenState();
}

class _ProfileBlacklistScreenState extends State<ProfileBlacklistScreen> {
  final LifeSnippetStore _store = LifeSnippetStore.instance;

  @override
  Widget build(BuildContext context) {
    return LifeSnippetStage(
      child: AnimatedBuilder(
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
                                trailing: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _store.unblockUser(user.userKey),
                                  child: Image.asset(
                                    ProfileCenterAssets.deleteWide,
                                    width: 92,
                                    height: 36,
                                    fit: BoxFit.fill,
                                    filterQuality: FilterQuality.high,
                                  ),
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
  int _selectedIndex = 0;
  final List<_ProfileCapsule> _capsules = List.of(_capsuleFixtures);

  @override
  Widget build(BuildContext context) {
    final filtered = _capsules
        .where((capsule) => capsule.status.index == _selectedIndex)
        .toList();
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
                    const SizedBox(height: 18),
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
                            setState(() => _capsules.remove(capsule));
                          },
                          onCheck: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${capsule.title} is ready.'),
                                backgroundColor: lifePanel,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
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
      ),
    );
  }
}

class ProfileWalletScreen extends StatefulWidget {
  const ProfileWalletScreen({super.key});

  @override
  State<ProfileWalletScreen> createState() => _ProfileWalletScreenState();
}

class _ProfileWalletScreenState extends State<ProfileWalletScreen> {
  static const _walletBalanceKey = 'morrowly.profile.walletBalance';

  double _balance = 258.5;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

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
                phoneGutter: 20,
              );
              final side = (constraints.maxWidth - contentWidth) / 2;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  side,
                  MorrowlyFrameGuard.topClearance(
                    context,
                    minimum: 118,
                    extra: 44,
                  ),
                  side,
                  34,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'My wallet',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 26),
                              Text(
                                _formatBalance(_balance),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                'balance',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.58),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Image.asset(
                          ProfileCenterAssets.coin,
                          width: 96,
                          height: 96,
                          filterQuality: FilterQuality.high,
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.68,
                          ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        return _CoinPack(
                          amount: 999.9,
                          onBuy: () => _buyPack(999.9),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          LifeTopBar(
            title: 'Wallet',
            onBack: () => Navigator.of(context).pop(),
            trailing: IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Wallet purchases are stored locally here.'),
                  ),
                );
              },
              icon: const Icon(
                Icons.help_outline_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadBalance() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getDouble(_walletBalanceKey);
    if (mounted && value != null) {
      setState(() => _balance = value);
    }
  }

  Future<void> _buyPack(double amount) async {
    final preferences = await SharedPreferences.getInstance();
    final next = _balance + amount;
    await preferences.setDouble(_walletBalanceKey, next);
    if (!mounted) {
      return;
    }
    setState(() => _balance = next);
  }
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
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
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

class ProfileInfoScreen extends StatelessWidget {
  const ProfileInfoScreen({super.key, required this.title});

  final String title;

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
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: lifePanel.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    _infoCopy(title),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 13,
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
          LifeTopBar(title: title, onBack: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}

const _sectionTitleStyle = TextStyle(
  color: Colors.white,
  fontSize: 15,
  fontWeight: FontWeight.w900,
);

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.onSettings,
    required this.onWallet,
    required this.onEdit,
  });

  final LifeSnippetUser user;
  final VoidCallback onSettings;
  final VoidCallback onWallet;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LifeAvatar(user: user, radius: 42),
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
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
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
              const SizedBox(height: 5),
              Text(
                user.regionLine,
                style: const TextStyle(
                  color: Color(0xFFBD78FF),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 13),
              Text(
                user.signatureLine,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 13,
                  height: 1.28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onWallet,
              child: Container(
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      ProfileCenterAssets.coin,
                      width: 15,
                      height: 15,
                      filterQuality: FilterQuality.high,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '123,45',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
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
      ],
    );
  }
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats({
    required this.user,
    required this.onFollow,
    required this.onFans,
    required this.onLikes,
    required this.onCapsules,
  });

  final LifeSnippetUser user;
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
        _StatButton(
          value: user.fansCount,
          label: 'Fans',
          asset: ProfileCenterAssets.fanStat,
          onTap: onFans,
        ),
        _StatButton(
          value: user.likeCount,
          label: 'Get likes',
          asset: ProfileCenterAssets.likeStat,
          onTap: onLikes,
        ),
        _StatButton(
          value: user.capsuleCount,
          label: 'Capsule',
          asset: ProfileCenterAssets.messageStat,
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
    this.asset = ProfileCenterAssets.followStat,
  });

  final int value;
  final String label;
  final VoidCallback onTap;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Image.asset(
              asset,
              width: 34,
              height: 34,
              filterQuality: FilterQuality.high,
            ),
            const SizedBox(height: 7),
            Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
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
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CapsuleSummaryRow extends StatelessWidget {
  const _CapsuleSummaryRow({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final cards = const [
      _SummaryCapsule('Archived', '246', ProfileCenterAssets.capsuleArchived),
      _SummaryCapsule('To be opened', '85', ProfileCenterAssets.capsuleOpening),
      _SummaryCapsule('Unlocked', '136', ProfileCenterAssets.capsuleUnlocked),
    ];
    return Row(
      children: [
        for (var index = 0; index < cards.length; index++) ...[
          Expanded(
            child: _CapsuleSummaryCard(data: cards[index], onTap: onOpen),
          ),
          if (index != cards.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _MyPostsPanel extends StatelessWidget {
  const _MyPostsPanel({required this.posts, required this.onCompose});

  final List<LifeSnippetPost> posts;
  final VoidCallback onCompose;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
        decoration: BoxDecoration(
          color: lifePanel.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Image.asset(
              ProfileCenterAssets.message,
              width: 58,
              height: 58,
              filterQuality: FilterQuality.high,
            ),
            const SizedBox(height: 10),
            Text(
              'No approved posts yet. New posts wait for moderation.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.62),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w700,
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
    return Column(
      children: [
        for (final post in posts.take(2)) ...[
          _PendingPostCard(post: post),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _PendingPostCard extends StatelessWidget {
  const _PendingPostCard({required this.post});

  final LifeSnippetPost post;

  @override
  Widget build(BuildContext context) {
    final media = post.media.isEmpty ? null : post.media.first;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lifePanel.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          if (media != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 76,
                height: 76,
                child: LifeMediaImage(media: media),
              ),
            )
          else
            Image.asset(
              ProfileCenterAssets.message,
              width: 76,
              height: 76,
              filterQuality: FilterQuality.high,
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'In review',
                  style: TextStyle(
                    color: Color(0xFFFF77D6),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  post.body.isEmpty ? 'Photo snippet' : post.body,
                  maxLines: 3,
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
        ],
      ),
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
          LifeAvatar(user: user, radius: 28),
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
        height: 150,
        padding: const EdgeInsets.fromLTRB(10, 18, 10, 12),
        decoration: BoxDecoration(
          color: const Color(0xFF4C2A60).withValues(alpha: 0.66),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Image.asset(
              data.asset,
              width: 58,
              height: 58,
              filterQuality: FilterQuality.high,
            ),
            const Spacer(),
            Text(
              data.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              data.count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
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
  });

  final String title;
  final _CapsuleProfileStatus status;
  final String visibility;
  final String asset;
  final String date;
}

const _capsuleFixtures = [
  _ProfileCapsule(
    title: 'Open in 1 year',
    status: _CapsuleProfileStatus.archived,
    visibility: 'Public',
    asset: ProfileCenterAssets.capsuleArchived,
    date: '2025.02.25 seal',
  ),
  _ProfileCapsule(
    title: 'Open in 1 year',
    status: _CapsuleProfileStatus.archived,
    visibility: 'Private',
    asset: ProfileCenterAssets.capsuleArchived,
    date: '2025.02.25 seal',
  ),
  _ProfileCapsule(
    title: 'Open in 24 hours',
    status: _CapsuleProfileStatus.opening,
    visibility: 'Private',
    asset: ProfileCenterAssets.capsuleOpening,
    date: '2025.02.25 seal',
  ),
  _ProfileCapsule(
    title: 'Open in 24 hours',
    status: _CapsuleProfileStatus.opening,
    visibility: 'Private',
    asset: ProfileCenterAssets.capsuleOpening,
    date: '2025.02.25 seal',
  ),
  _ProfileCapsule(
    title: 'Can be opened',
    status: _CapsuleProfileStatus.unlocked,
    visibility: 'Public',
    asset: ProfileCenterAssets.capsuleUnlocked,
    date: '2025.02.25 seal',
  ),
  _ProfileCapsule(
    title: 'Can be opened',
    status: _CapsuleProfileStatus.unlocked,
    visibility: 'Public',
    asset: ProfileCenterAssets.capsuleUnlocked,
    date: '2025.02.25 seal',
  ),
];

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
                child: _SmallCapsuleButton(label: 'Delete', onTap: onDelete),
              ),
              if (unlocked) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _SmallCapsuleButton(
                    label: 'Check',
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
    this.filled = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
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
            color: filled ? Colors.white : Colors.white.withValues(alpha: 0.32),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _CoinPack extends StatelessWidget {
  const _CoinPack({required this.amount, required this.onBuy});

  final double amount;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
      decoration: BoxDecoration(
        color: lifePanel.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Image.asset(
            ProfileCenterAssets.coin,
            width: 45,
            height: 45,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(height: 8),
          Text(
            _formatBalance(amount),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.44),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBuy,
            child: Container(
              height: 31,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: lifePurple,
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Text(
                r'$ 9.99',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
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

String _formatBalance(double value) {
  return value.toStringAsFixed(1).replaceAll('.', ',');
}

String _infoCopy(String title) {
  return switch (title) {
    'Privacy agreement' =>
      'Morrowly stores local profile, moderation, wallet, and message records on this device. Community posts and conversations use reporting and blocking controls to keep user-generated content manageable.',
    'User agreement' =>
      'Use Morrowly to preserve capsules, post reviewed life snippets, and communicate only with mutually approved contacts. Do not publish harmful, abusive, or misleading content.',
    'Contact Us' =>
      'For support, safety reports, or account questions, contact the Morrowly team through the support mailbox configured for this app release.',
    'Community guidelines' =>
      'Be specific, kind, and accountable. Report unsafe posts or comments, block users when needed, and remember that new public posts appear only after review.',
    _ => 'No additional content is available for this section.',
  };
}
