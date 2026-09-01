import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:game_papan/models/game_enums.dart';
import 'package:game_papan/services/auth_service.dart';
import 'package:game_papan/services/language_provider.dart';
import 'package:game_papan/screens/game_guide_screen.dart';
import 'package:game_papan/widgets/game_setup_dialog.dart';
import 'package:game_papan/widgets/game_card.dart';
import 'package:game_papan/widgets/home_top_bar.dart';
import 'package:game_papan/widgets/quick_rating_summary_card.dart';
import 'package:game_papan/widgets/google_auth_banner.dart';
import 'package:game_papan/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeTopBar(user: user),
              const SizedBox(height: 18),

              // Hero Emblem Banner (Clickable to open Guide)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GameGuideScreen()),
                  );
                },
                child: _buildHeroBanner(context, langProvider),
              ),
              const SizedBox(height: 18),

              QuickRatingSummaryCard(user: user),
              const SizedBox(height: 24),

              Text(
                langProvider.tr('choose_arena'),
                style: GoogleFonts.cinzel(
                  color: AppColors.textSecondaryColor(context),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              GameCard(
                title: langProvider.tr('chess_title'),
                subtitle: langProvider.tr('chess_desc'),
                badge: langProvider.tr('bot_tiers_badge'),
                gradient: const [
                  Color(0xFF2C1810),
                  Color(0xFF5C3317),
                  Color(0xFF8B5A2B),
                ],
                isChess: true,
                piecesPreview: '♔ ♕ ♖ ♗ ♘ ♙',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) =>
                        const GameSetupDialog(gameType: GameType.chess),
                  );
                },
              ),
              const SizedBox(height: 16),
              GameCard(
                title: langProvider.tr('shogi_title'),
                subtitle: langProvider.tr('shogi_desc'),
                badge: langProvider.tr('shogi_features_badge'),
                gradient: const [
                  Color(0xFF421C06),
                  Color(0xFF854D0E),
                  Color(0xFFB45309),
                ],
                isChess: false,
                piecesPreview: '王 飛 角 金 銀 桂 香 歩',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) =>
                        const GameSetupDialog(gameType: GameType.shogi),
                  );
                },
              ),
              const SizedBox(height: 24),
              if (user != null && !user.id.startsWith('google_'))
                GoogleAuthBanner(auth: auth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context, LanguageProvider langProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E1A0F), Color(0xFF1E100A), Color(0xFF150A05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFB45309).withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo Thumbnail with rounded square metal frame
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFBBF24),
                  Color(0xFFB45309),
                  Color(0xFF78350F),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('lib/aset/Logo.jpeg', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFF59E0B),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        langProvider.tr('official_edition'),
                        style: GoogleFonts.cinzel(
                          color: const Color(0xFFFDE68A),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          langProvider.tr('guide'),
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFFBBF24),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 14,
                          color: Color(0xFFFBBF24),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  langProvider.tr('app_title'),
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  langProvider.tr('hero_desc'),
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFD1D5DB),
                    fontSize: 11,
                    height: 1.3,
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
