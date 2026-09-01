import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:game_papan/screens/profile_screen.dart';
import 'package:game_papan/screens/leaderboard_screen.dart';
import 'package:game_papan/screens/game_guide_screen.dart';
import 'package:game_papan/models/user_profile.dart';
import 'package:game_papan/models/game_enums.dart';
import 'package:game_papan/services/language_provider.dart';
import 'package:game_papan/widgets/language_selection_dialog.dart';
import 'package:game_papan/widgets/interactive_button.dart';
import 'package:game_papan/theme/app_colors.dart';
import 'package:game_papan/theme/theme_provider.dart';

class HomeTopBar extends StatelessWidget {
  final UserProfile? user;

  const HomeTopBar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final currentLang = langProvider.currentLanguage;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Brand Title with Logo emblem
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE2A862), Color(0xFF965B27), Color(0xFF5D3111)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD97706).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(color: const Color(0xFFFDE68A), width: 1.8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'lib/aset/Logo.jpeg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(Icons.shield, color: Color(0xFFFDE68A)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'CHESS',
                      style: GoogleFonts.cinzel(
                        color: const Color(0xFFF59E0B),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      ' X ',
                      style: GoogleFonts.cinzel(
                        color: AppColors.textMutedColor(context),
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'SHOGI',
                      style: GoogleFonts.cinzel(
                        color: const Color(0xFFEA580C),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                Text(
                  'DUAL CLASH',
                  style: GoogleFonts.cinzel(
                    color: AppColors.textColor(context),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),

        Row(
          children: [
            // Guide Book Button (Ensiklopedia Bidak & Aturan)
            InteractiveButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GameGuideScreen()),
                );
              },
              padding: const EdgeInsets.all(8),
              backgroundColor: AppColors.surface(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 18,
                color: Color(0xFFFBBF24),
              ),
            ),
            const SizedBox(width: 5),

            // Language Picker Button (Flag)
            InteractiveButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const LanguageSelectionDialog(),
                );
              },
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
              backgroundColor: AppColors.surface(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderColor(context)),
              child: Text(
                currentLang.flag,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 5),

            // Leaderboard Button (Trophy)
            InteractiveButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LeaderboardScreen(initialGameType: GameType.chess)),
                );
              },
              padding: const EdgeInsets.all(8),
              backgroundColor: AppColors.surface(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 18,
                color: Color(0xFFFBBF24),
              ),
            ),
            const SizedBox(width: 5),

            // Dark / Light Theme Toggle Button
            InteractiveButton(
              onPressed: () {
                themeProvider.toggleTheme();
              },
              padding: const EdgeInsets.all(8),
              backgroundColor: AppColors.surface(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderColor(context)),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                size: 18,
                color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
              ),
            ),
            const SizedBox(width: 5),

            // Profile Button
            InteractiveButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              backgroundColor: AppColors.surface(context),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderColor(context)),
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFD97706), Color(0xFF78350F)],
                  ),
                ),
                child: const Icon(Icons.person, size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
