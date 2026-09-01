import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:game_papan/models/game_enums.dart';
import 'package:game_papan/widgets/interactive_button.dart';
import 'package:game_papan/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:game_papan/services/language_provider.dart';

class MatchEndDialog extends StatelessWidget {
  final MatchOutcome outcome;
  final int ratingDelta;
  final GameType gameType;
  final GameMode gameMode;
  final String title;
  final String message;
  final VoidCallback onPlayAgain;
  final VoidCallback onMainMenu;
  final VoidCallback? onAnalyzeGame;

  const MatchEndDialog({
    super.key,
    required this.outcome,
    required this.ratingDelta,
    required this.gameType,
    required this.gameMode,
    required this.title,
    required this.message,
    required this.onPlayAgain,
    required this.onMainMenu,
    this.onAnalyzeGame,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    Color outcomeColor;
    IconData outcomeIcon;
    String outcomeBadge;

    switch (outcome) {
      case MatchOutcome.win:
        outcomeColor = const Color(0xFF10B981);
        outcomeIcon = Icons.emoji_events_rounded;
        outcomeBadge = lang.tr('victory');
        break;
      case MatchOutcome.loss:
        outcomeColor = const Color(0xFFEF4444);
        outcomeIcon = Icons.sentiment_dissatisfied_rounded;
        outcomeBadge = lang.tr('defeat');
        break;
      case MatchOutcome.draw:
        outcomeColor = const Color(0xFFF59E0B);
        outcomeIcon = Icons.handshake_rounded;
        outcomeBadge = lang.tr('draw');
        break;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surface(context),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: outcomeColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: outcomeColor.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: Icon(outcomeIcon, color: outcomeColor, size: 54),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: outcomeColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                outcomeBadge,
                style: GoogleFonts.outfit(
                  color: outcomeColor,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: AppColors.textColor(context),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondaryColor(context),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderColor(context)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    gameMode == GameMode.vsPlayer
                        ? lang.tr('rating_change')
                        : lang.tr('bot_practice'),
                    style: TextStyle(
                      color: AppColors.textSecondaryColor(context),
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    gameMode == GameMode.vsPlayer
                        ? (ratingDelta >= 0
                              ? '+$ratingDelta ELO'
                              : '$ratingDelta ELO')
                        : '±0 ELO',
                    style: GoogleFonts.outfit(
                      color: ratingDelta >= 0
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (onAnalyzeGame != null) ...[
              SizedBox(
                width: double.infinity,
                child: InteractiveButton(
                  onPressed: onAnalyzeGame,
                  backgroundColor: const Color(0xFFD97706),
                  borderRadius: BorderRadius.circular(14),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.insights_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        lang.tr('review_game_analysis'),
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: InteractiveButton(
                    onPressed: onMainMenu,
                    backgroundColor: Colors.transparent,
                    border: Border.all(color: AppColors.borderColor(context)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    child: Center(
                      child: Text(
                        lang.tr('main_menu'),
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textSecondaryColor(context),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InteractiveButton(
                    onPressed: onPlayAgain,
                    backgroundColor: outcomeColor,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    child: Center(
                      child: Text(
                        lang.tr('play_again'),
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
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
