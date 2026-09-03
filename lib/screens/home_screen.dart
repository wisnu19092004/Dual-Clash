import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:game_papan/models/game_enums.dart';
import 'package:game_papan/services/auth_service.dart';
import 'package:game_papan/services/language_provider.dart';
import 'package:game_papan/screens/game_guide_screen.dart';
import 'package:game_papan/screens/leaderboard_screen.dart';
import 'package:game_papan/screens/profile_screen.dart';
import 'package:game_papan/widgets/game_setup_dialog.dart';
import 'package:game_papan/widgets/game_card.dart';
import 'package:game_papan/widgets/home_top_bar.dart';
import 'package:game_papan/widgets/quick_rating_summary_card.dart';
import 'package:game_papan/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          const _HomeMainContent(),
          const GameGuideScreen(showBackButton: false),
          const LeaderboardScreen(
            initialGameType: GameType.chess,
            showBackButton: false,
          ),
          const ProfileScreen(showBackButton: false),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, langProvider),
    );
  }

  Widget _buildBottomNavigationBar(
    BuildContext context,
    LanguageProvider langProvider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navItems = [
      (
        icon: Icons.sports_esports_outlined,
        activeIcon: Icons.sports_esports_rounded,
        label: langProvider.tr('nav_play'),
      ),
      (
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book_rounded,
        label: langProvider.tr('nav_guide'),
      ),
      (
        icon: Icons.emoji_events_outlined,
        activeIcon: Icons.emoji_events_rounded,
        label: langProvider.tr('nav_leaderboard'),
      ),
      (
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: langProvider.tr('nav_profile'),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(
          top: BorderSide(
            color: AppColors.borderColor(context).withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final isSelected = _currentTabIndex == index;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _currentTabIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFD97706).withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: 23,
                          color: isSelected
                              ? const Color(0xFFF59E0B)
                              : AppColors.textSecondaryColor(context),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cinzel(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected
                                ? const Color(0xFFF59E0B)
                                : AppColors.textSecondaryColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _HomeMainContent extends StatelessWidget {
  const _HomeMainContent();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final user = auth.currentUser;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeTopBar(user: user),
                  const SizedBox(height: 16),

                  // Hero Emblem Banner
                  _buildHeroBanner(context, langProvider),
                  const SizedBox(height: 16),

                  QuickRatingSummaryCard(user: user),
                  const SizedBox(height: 20),

                  Text(
                    langProvider.tr('choose_arena'),
                    style: GoogleFonts.cinzel(
                      color: AppColors.textSecondaryColor(context),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),

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
                  const SizedBox(height: 14),

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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context, LanguageProvider langProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
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
          Container(
            width: 68,
            height: 68,
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 5),
                Text(
                  langProvider.tr('app_title'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  langProvider.tr('hero_desc'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
