import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:game_papan/widgets/interstitial_ad_dialog.dart';

class AdService {
  static final AdService instance = AdService._internal();
  AdService._internal();

  /// ID Unit Iklan Interstitial AdMob (Default Test ID Google)
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  /// Test Ad Unit ID dari Google untuk testing aman
  static const String _testInterstitialAdUnitIdAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialAdUnitIdIos = 'ca-app-pub-3940256099942544/4411468910';

  static String get adUnitId {
    if (kDebugMode) {
      if (kIsWeb) return interstitialAdUnitId;
      return Platform.isAndroid
          ? _testInterstitialAdUnitIdAndroid
          : _testInterstitialAdUnitIdIos;
    }
    return interstitialAdUnitId;
  }

  InterstitialAd? _interstitialAd;
  bool _isAdLoading = false;
  int _matchesPlayedCount = 0;

  int get matchesPlayedCount => _matchesPlayedCount;

  /// Inisialisasi Google Mobile Ads SDK
  static Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      await MobileAds.instance.initialize();
      instance.loadInterstitialAd();
    } catch (e) {
      debugPrint('AdMob initialization error: $e');
    }
  }

  /// Pre-load iklan Interstitial agar siap tampil seketika saat game selesai
  void loadInterstitialAd() {
    if (kIsWeb || _isAdLoading || _interstitialAd != null) return;
    _isAdLoading = true;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoading = false;
          debugPrint('[AdService] Interstitial Ad loaded successfully.');
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isAdLoading = false;
          debugPrint('[AdService] Interstitial Ad failed to load: $error');
        },
      ),
    );
  }

  /// Menampilkan iklan Interstitial setelah match selesai
  /// Jika di mobile dan iklan AdMob siap, akan menampilkan Google AdMob asli.
  /// Jika offline / web / gagal memuat, otomatis fallback ke simulated Ad Dialog tanpa membuat game freeze.
  Future<void> showPostMatchInterstitialAd(
    BuildContext context, {
    required VoidCallback onAdClosed,
  }) async {
    _matchesPlayedCount++;

    if (!kIsWeb && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd();
          onAdClosed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd();
          onAdClosed();
        },
      );

      _interstitialAd!.show();
      return;
    }

    // Jika iklan belum terdownload atau di platform non-mobile, muat ulang di background dan tampilkan dialog
    loadInterstitialAd();

    if (!context.mounted) {
      onAdClosed();
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => InterstitialAdDialog(onClosed: onAdClosed),
    );
  }
}

