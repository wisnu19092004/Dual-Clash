import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:game_papan/widgets/interactive_button.dart';
import 'package:game_papan/widgets/ad_banner_card.dart';

class InterstitialAdDialog extends StatefulWidget {
  final VoidCallback onClosed;

  const InterstitialAdDialog({super.key, required this.onClosed});

  @override
  State<InterstitialAdDialog> createState() => _InterstitialAdDialogState();
}

class _InterstitialAdDialogState extends State<InterstitialAdDialog> {
  int _secondsLeft = 5;
  Timer? _timer;
  bool _canSkip = false;

  final List<Map<String, String>> _adSampleCatalog = [
    {
      'title': 'Tactics Master 3D',
      'tagline': 'Join 10M+ Grandmasters in Epic Online Tournaments!',
      'cta': 'INSTALL NOW',
      'icon': '♟️',
      'rating': '4.9 ★',
      'category': 'Strategy & Board Games',
    },
    {
      'title': 'Shogi Kingdom Online',
      'tagline': 'Master Japanese Chess with Pro AI Coaching & Ranked Seasons!',
      'cta': 'PLAY FREE',
      'icon': '🏯',
      'rating': '4.8 ★',
      'category': 'Mind Sports',
    },
    {
      'title': 'Cloud Gaming Ultra Pass',
      'tagline': 'Stream 500+ Console Games anywhere with Ultra Low Latency!',
      'cta': 'TRY 30 DAYS FREE',
      'icon': '⚡',
      'rating': '4.9 ★',
      'category': 'Gaming & Entertainment',
    }
  ];

  late final Map<String, String> _currentAd;

  @override
  void initState() {
    super.initState();
    _currentAd = _adSampleCatalog[DateTime.now().second % _adSampleCatalog.length];
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        setState(() {
          _secondsLeft = 0;
          _canSkip = true;
        });
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canSkip,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF1E1E2E),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.ads_click, size: 14, color: Colors.amber),
                        SizedBox(width: 5),
                        Text(
                          'SPONSORED AD',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _canSkip
                      ? InteractiveButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onClosed();
                          },
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          backgroundColor: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Skip Ad ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.close, size: 14, color: Colors.white),
                            ],
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Reward in ${_secondsLeft}s',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 16),
              AdBannerCard(adData: _currentAd),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: InteractiveButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Simulasi membuka: ${_currentAd['title']}!'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    Navigator.of(context).pop();
                    widget.onClosed();
                  },
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  child: Center(
                    child: Text(
                      _currentAd['cta']!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
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
