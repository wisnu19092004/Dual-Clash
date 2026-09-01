import 'package:flutter/material.dart';
import 'package:game_papan/widgets/interstitial_ad_dialog.dart';

class AdService {
  static final AdService instance = AdService._internal();
  AdService._internal();

  int _matchesPlayedCount = 0;
  int get matchesPlayedCount => _matchesPlayedCount;

  /// Menampilkan dialog simulasi Interstitial Ad penuh dengan timer countdown 5 detik atau skip.
  /// Ini memastikan requirement: "Lalu terdapat iklan juga didalamnya tiap kali selesai 1 permainan atau match."
  Future<void> showPostMatchInterstitialAd(
    BuildContext context, {
    required VoidCallback onAdClosed,
  }) async {
    _matchesPlayedCount++;
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
