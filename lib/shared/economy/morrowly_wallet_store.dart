import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MorrowlyCoinPack {
  const MorrowlyCoinPack({
    required this.priceLabel,
    required this.coins,
    required this.productId,
  });

  final String priceLabel;
  final int coins;
  final String productId;

  String get coinsLabel => MorrowlyWalletStore.formatCoins(coins);
}

abstract final class MorrowlyCoinPacks {
  static const all = [
    MorrowlyCoinPack(
      priceLabel: '\$99.99',
      coins: 20000,
      productId: 'sabmhkpxsewajgxh',
    ),
    MorrowlyCoinPack(
      priceLabel: '\$49.99',
      coins: 10000,
      productId: 'mbsyiohodfzqrwxx',
    ),
    MorrowlyCoinPack(
      priceLabel: '\$19.99',
      coins: 4000,
      productId: 'ytjwuvqpgugzijcb',
    ),
    MorrowlyCoinPack(
      priceLabel: '\$9.99',
      coins: 2000,
      productId: 'raedausirkatvziy',
    ),
    MorrowlyCoinPack(
      priceLabel: '\$4.99',
      coins: 1000,
      productId: 'tldywuhsnatbxpud',
    ),
    MorrowlyCoinPack(
      priceLabel: '\$1.99',
      coins: 400,
      productId: 'neurmxmwffvpimqq',
    ),
    MorrowlyCoinPack(
      priceLabel: '\$0.99',
      coins: 200,
      productId: 'ovnheiwvdkbhgsis',
    ),
  ];

  static MorrowlyCoinPack? byProductId(String productId) {
    for (final pack in all) {
      if (pack.productId == productId) {
        return pack;
      }
    }
    return null;
  }
}

class MorrowlyCoinCost {
  const MorrowlyCoinCost({
    required this.title,
    required this.description,
    required this.amount,
  });

  final String title;
  final String description;
  final int amount;
}

abstract final class MorrowlyCoinCosts {
  static const welcomeGift = 600;

  static const releaseLifeSnippet = MorrowlyCoinCost(
    title: 'Release Life Snippet',
    description: 'Submit a public moment for review before it appears.',
    amount: 30,
  );

  static const sealCapsule = MorrowlyCoinCost(
    title: 'Seal a time capsule',
    description: 'Lock a future wish with its opening time.',
    amount: 80,
  );

  static const openCapsule = MorrowlyCoinCost(
    title: 'Open a ready capsule',
    description: 'View a capsule from your personal shelf.',
    amount: 50,
  );

  static const paidFeatures = [
    releaseLifeSnippet,
    sealCapsule,
    openCapsule,
  ];
}

enum MorrowlyPurchaseStartStatus {
  started,
  alreadyRunning,
  storeUnavailable,
  productNotFound,
  queryFailed,
  purchaseFailed,
}

class MorrowlyPurchaseStartResult {
  const MorrowlyPurchaseStartResult({
    required this.status,
    required this.message,
  });

  final MorrowlyPurchaseStartStatus status;
  final String message;

  bool get started => status == MorrowlyPurchaseStartStatus.started;
}

class MorrowlyWalletStore extends ChangeNotifier {
  MorrowlyWalletStore._();

  static final MorrowlyWalletStore instance = MorrowlyWalletStore._();

  static const _balanceKey = 'morrowly.wallet.coinBalance';
  static const _welcomeGiftClaimedKey = 'morrowly.wallet.welcomeGiftClaimed';
  static const _creditedPurchasesKey = 'morrowly.wallet.creditedPurchases';
  static const _legacyProfileBalanceKey = 'morrowly.profile.walletBalance';

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  SharedPreferences? _preferences;
  Future<void>? _loading;
  final Set<String> _creditedPurchases = {};
  int _balance = 0;
  bool _welcomeGiftClaimed = false;
  bool _purchaseInFlight = false;
  String? _purchasingProductId;

  int get balance => _balance;
  bool get welcomeGiftClaimed => _welcomeGiftClaimed;
  bool get purchaseInFlight => _purchaseInFlight;
  String? get purchasingProductId => _purchasingProductId;

  Future<void> load() {
    final activeLoad = _loading;
    if (activeLoad != null) {
      return activeLoad;
    }

    final load = _load();
    _loading = load;
    return load;
  }

  Future<int> grantWelcomeGiftIfNeeded({
    int amount = MorrowlyCoinCosts.welcomeGift,
  }) async {
    await load();
    if (_welcomeGiftClaimed) {
      return 0;
    }

    _welcomeGiftClaimed = true;
    _balance += amount;
    await _preferences!.setBool(_welcomeGiftClaimedKey, true);
    await _preferences!.setInt(_balanceKey, _balance);
    notifyListeners();
    return amount;
  }

  Future<bool> spend(MorrowlyCoinCost cost) async {
    await load();
    if (_balance < cost.amount) {
      return false;
    }

    _balance -= cost.amount;
    await _preferences!.setInt(_balanceKey, _balance);
    notifyListeners();
    return true;
  }

  Future<void> credit(int amount) async {
    if (amount <= 0) {
      return;
    }

    await load();
    _balance += amount;
    await _preferences!.setInt(_balanceKey, _balance);
    notifyListeners();
  }

  Future<void> clearLocalWallet() async {
    await load();
    _balance = 0;
    _welcomeGiftClaimed = false;
    _creditedPurchases.clear();
    await _preferences!.remove(_balanceKey);
    await _preferences!.remove(_welcomeGiftClaimedKey);
    await _preferences!.remove(_creditedPurchasesKey);
    await _preferences!.remove(_legacyProfileBalanceKey);
    notifyListeners();
  }

  Future<MorrowlyPurchaseStartResult> purchasePack(
    MorrowlyCoinPack pack,
  ) async {
    await load();
    if (_purchaseInFlight) {
      return const MorrowlyPurchaseStartResult(
        status: MorrowlyPurchaseStartStatus.alreadyRunning,
        message: 'Another Apple purchase is still processing.',
      );
    }

    final available = await _inAppPurchase.isAvailable();
    if (!available) {
      return const MorrowlyPurchaseStartResult(
        status: MorrowlyPurchaseStartStatus.storeUnavailable,
        message: 'The App Store purchase service is unavailable right now.',
      );
    }

    final ProductDetailsResponse response;
    try {
      response = await _inAppPurchase.queryProductDetails({pack.productId});
    } catch (_) {
      return const MorrowlyPurchaseStartResult(
        status: MorrowlyPurchaseStartStatus.queryFailed,
        message: 'Morrowly could not fetch this product from Apple.',
      );
    }

    if (response.error != null) {
      return MorrowlyPurchaseStartResult(
        status: MorrowlyPurchaseStartStatus.queryFailed,
        message: response.error!.message,
      );
    }

    if (response.productDetails.isEmpty) {
      return MorrowlyPurchaseStartResult(
        status: MorrowlyPurchaseStartStatus.productNotFound,
        message:
            'Apple did not return ${pack.productId}. Check the App Store Connect consumable setup.',
      );
    }

    _purchaseInFlight = true;
    _purchasingProductId = pack.productId;
    notifyListeners();

    try {
      final purchaseParam = PurchaseParam(
        productDetails: response.productDetails.first,
      );
      final started = await _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );
      if (!started) {
        _finishPurchaseAttempt();
        return const MorrowlyPurchaseStartResult(
          status: MorrowlyPurchaseStartStatus.purchaseFailed,
          message: 'Apple did not start the purchase sheet.',
        );
      }
      return const MorrowlyPurchaseStartResult(
        status: MorrowlyPurchaseStartStatus.started,
        message: 'Apple purchase started.',
      );
    } catch (_) {
      _finishPurchaseAttempt();
      return const MorrowlyPurchaseStartResult(
        status: MorrowlyPurchaseStartStatus.purchaseFailed,
        message: 'Apple could not start this purchase.',
      );
    }
  }

  static String formatCoins(int coins) {
    final raw = coins.toString();
    final buffer = StringBuffer();
    for (var index = 0; index < raw.length; index++) {
      final remaining = raw.length - index;
      buffer.write(raw[index]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }

  Future<void> _load() async {
    _preferences = await SharedPreferences.getInstance();
    _balance = _preferences!.getInt(_balanceKey) ?? 0;
    _welcomeGiftClaimed =
        _preferences!.getBool(_welcomeGiftClaimedKey) ?? false;
    _creditedPurchases
      ..clear()
      ..addAll(_preferences!.getStringList(_creditedPurchasesKey) ?? const []);
    _listenToPurchases();
    notifyListeners();
  }

  void _listenToPurchases() {
    _purchaseSubscription ??= _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (_) {
        _finishPurchaseAttempt();
      },
      onDone: () {
        _purchaseSubscription = null;
      },
    );
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    _preferences ??= await SharedPreferences.getInstance();
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _purchaseInFlight = true;
          _purchasingProductId = purchase.productID;
          notifyListeners();
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _creditPurchaseIfNeeded(purchase);
          await _completePurchaseIfNeeded(purchase);
          _finishPurchaseAttempt();
          break;
        case PurchaseStatus.error:
        case PurchaseStatus.canceled:
          await _completePurchaseIfNeeded(purchase);
          _finishPurchaseAttempt();
          break;
      }
    }
  }

  Future<void> _creditPurchaseIfNeeded(PurchaseDetails purchase) async {
    final pack = MorrowlyCoinPacks.byProductId(purchase.productID);
    if (pack == null) {
      return;
    }

    final purchaseKey = _purchaseKey(purchase);
    if (_creditedPurchases.contains(purchaseKey)) {
      return;
    }

    _creditedPurchases.add(purchaseKey);
    _balance += pack.coins;
    await _preferences!.setStringList(
      _creditedPurchasesKey,
      _creditedPurchases.toList()..sort(),
    );
    await _preferences!.setInt(_balanceKey, _balance);
    notifyListeners();
  }

  Future<void> _completePurchaseIfNeeded(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchase);
    }
  }

  String _purchaseKey(PurchaseDetails purchase) {
    final id = purchase.purchaseID ?? '';
    if (id.isNotEmpty) {
      return '${purchase.productID}::$id';
    }
    final date = purchase.transactionDate ?? '';
    if (date.isNotEmpty) {
      return '${purchase.productID}::$date';
    }
    return '${purchase.productID}::${purchase.verificationData.serverVerificationData.hashCode}';
  }

  void _finishPurchaseAttempt() {
    _purchaseInFlight = false;
    _purchasingProductId = null;
    notifyListeners();
  }
}
