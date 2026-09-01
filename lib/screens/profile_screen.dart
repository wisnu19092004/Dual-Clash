import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:game_papan/services/auth_service.dart';
import 'package:game_papan/services/language_provider.dart';
import 'package:game_papan/screens/match_history_screen.dart';
import 'package:game_papan/widgets/language_selection_dialog.dart';
import 'package:game_papan/widgets/rating_card.dart';
import 'package:game_papan/widgets/history_item.dart';
import 'package:game_papan/widgets/profile_header_card.dart';
import 'package:game_papan/theme/app_colors.dart';
import 'package:game_papan/theme/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  final bool showBackButton;

  const ProfileScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final user = auth.currentUser;
    final currentLang = langProvider.currentLanguage;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: showBackButton
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textColor(context),
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          langProvider.tr('profile'),
          style: GoogleFonts.outfit(
            color: AppColors.textColor(context),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? Colors.amber : AppColors.primary,
            ),
            tooltip: 'Ganti Mode Gelap / Cerah',
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            ProfileHeaderCard(user: user, auth: auth),
            const SizedBox(height: 16),

            // Language Selector Card inside Profile
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => const LanguageSelectionDialog(),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderColor(context)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFD97706,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.language_rounded,
                            color: Color(0xFFD97706),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              langProvider.tr('language'),
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textColor(context),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${currentLang.flag} ${currentLang.label}',
                              style: TextStyle(
                                color: AppColors.textSecondaryColor(context),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Theme Switcher Card inside Profile
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor(context)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isDark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: isDark ? Colors.amber : AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            langProvider.tr('theme_setting'),
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textColor(context),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            isDark
                                ? 'Mode Gelap (Dark Mode)'
                                : 'Mode Cerah (Light Mode)',
                            style: TextStyle(
                              color: AppColors.textSecondaryColor(context),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    value: isDark,
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
                    onChanged: (_) => themeProvider.toggleTheme(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: RatingCard(
                    title: langProvider.tr('chess_rating'),
                    rating: user.chessRating,
                    isChess: true,
                    color: AppColors.primary,
                    wins: user.chessWins,
                    losses: user.chessLosses,
                    draws: user.chessDraws,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: RatingCard(
                    title: langProvider.tr('shogi_rating'),
                    rating: user.shogiRating,
                    isChess: false,
                    color: AppColors.secondary,
                    wins: user.shogiWins,
                    losses: user.shogiLosses,
                    draws: user.shogiDraws,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  langProvider.tr('match_history_title'),
                  style: GoogleFonts.cinzel(
                    color: AppColors.textColor(context),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user.history.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MatchHistoryScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Lihat Semua',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFFBBF24),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (user.history.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 36,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderColor(context)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.history_toggle_off_rounded,
                      size: 48,
                      color: AppColors.textSecondaryColor(context),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      langProvider.tr('no_match_history'),
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textSecondaryColor(context),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: user.history.length > 5 ? 5 : user.history.length,
                itemBuilder: (context, index) {
                  return HistoryItem(record: user.history[index]);
                },
              ),
          ],
        ),
      ),
    );
  }
}
