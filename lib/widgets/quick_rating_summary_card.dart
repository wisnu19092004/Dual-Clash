import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:game_papan/models/user_profile.dart';
import 'package:game_papan/models/game_enums.dart';
import 'package:game_papan/screens/match_history_screen.dart';
import 'package:game_papan/widgets/game_emblem_icon.dart';
import 'package:game_papan/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:game_papan/services/language_provider.dart';

class QuickRatingSummaryCard extends StatelessWidget {
  final UserProfile? user;

  const QuickRatingSummaryCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.35
                  : 0.05,
            ),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Chess Rating Item (Click to view Chess match history)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MatchHistoryScreen(
                          filterGameType: GameType.chess,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF381F12), Color(0xFF1B0E07)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFD97706),
                            width: 1.4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD97706)
                                  .withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: GameEmblemIcon(isChess: true, size: 24),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang.tr('chess_rating'),
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textSecondaryColor(context),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${user?.chessRating ?? 1200} ELO',
                              style: GoogleFonts.cinzel(
                                color: AppColors.textColor(context),
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                height: 32,
                width: 1,
                color: AppColors.borderColor(context),
              ),
              const SizedBox(width: 10),

              // Shogi Rating Item (Click to view Shogi match history)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MatchHistoryScreen(
                          filterGameType: GameType.shogi,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF26140A), Color(0xFF190C05)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFEA580C),
                            width: 1.4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEA580C)
                                  .withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: GameEmblemIcon(isChess: false, size: 24),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang.tr('shogi_rating'),
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textSecondaryColor(context),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${user?.shogiRating ?? 1200} ELO',
                              style: GoogleFonts.cinzel(
                                color: AppColors.textColor(context),
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MatchHistoryScreen(),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.history_rounded,
                  size: 15,
                  color: Color(0xFFFBBF24),
                ),
                const SizedBox(width: 5),
                Text(
                  lang.tr('view_match_history'),
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFFBBF24),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 10,
                  color: Color(0xFFFBBF24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
