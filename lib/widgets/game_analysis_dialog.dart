import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:game_papan/models/game_enums.dart';
import 'package:game_papan/services/game_analysis_engine.dart';
import 'package:game_papan/services/language_provider.dart';
import 'package:game_papan/theme/app_colors.dart';
import 'package:game_papan/widgets/interactive_button.dart';

class GameAnalysisDialog extends StatelessWidget {
  final GameAnalysisReport report;
  final GameType gameType;
  final String player1Name;
  final String player2Name;
  final VoidCallback? onPlayAgain;
  final VoidCallback? onMainMenu;

  const GameAnalysisDialog({
    super.key,
    required this.report,
    required this.gameType,
    required this.player1Name,
    required this.player2Name,
    this.onPlayAgain,
    this.onMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surface(context),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD97706), Color(0xFF92400E)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.insights_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          langProvider.tr('game_analysis_title'),
                          style: GoogleFonts.cinzel(
                            color: AppColors.textColor(context),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          langProvider.tr(report.summaryKey),
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textSecondaryColor(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColors.textSecondaryColor(context),
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Accuracy Header Comparison Card
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderColor(context)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            player1Name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textSecondaryColor(context),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${report.accuracyPlayer1}%',
                            style: GoogleFonts.cinzel(
                              color: const Color(0xFF10B981),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            langProvider.tr('accuracy'),
                            style: TextStyle(
                              color: AppColors.textMutedColor(context),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 44,
                      width: 1,
                      color: AppColors.borderColor(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            player2Name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textSecondaryColor(context),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${report.accuracyPlayer2}%',
                            style: GoogleFonts.cinzel(
                              color: const Color(0xFF3B82F6),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            langProvider.tr('accuracy'),
                            style: TextStyle(
                              color: AppColors.textMutedColor(context),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Move Quality Grid Summary Badges
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildQualityBadge(
                    context,
                    'Brilliant (!!)',
                    report.brilliantCount,
                    const Color(0xFF06B6D4),
                  ),
                  _buildQualityBadge(
                    context,
                    'Best (!)',
                    report.bestCount,
                    const Color(0xFF10B981),
                  ),
                  _buildQualityBadge(
                    context,
                    'Good',
                    report.goodCount,
                    const Color(0xFF84CC16),
                  ),
                  _buildQualityBadge(
                    context,
                    'Inaccuracy (?)',
                    report.inaccuracyCount,
                    const Color(0xFFF59E0B),
                  ),
                  _buildQualityBadge(
                    context,
                    'Mistake (??)',
                    report.mistakeCount,
                    const Color(0xFFEA580C),
                  ),
                  _buildQualityBadge(
                    context,
                    'Blunder',
                    report.blunderCount,
                    const Color(0xFFEF4444),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Text(
                langProvider.tr('move_timeline'),
                style: GoogleFonts.cinzel(
                  color: AppColors.textColor(context),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Move List Analysis Feed
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderColor(context)),
                  ),
                  child: report.moveAnalyses.isEmpty
                      ? Center(
                          child: Text(
                            langProvider.tr('no_moves_analyzed'),
                            style: TextStyle(
                              color: AppColors.textMutedColor(context),
                              fontSize: 12,
                            ),
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          itemCount: report.moveAnalyses.length,
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            color: AppColors.borderColor(context),
                          ),
                          itemBuilder: (context, index) {
                            final move = report.moveAnalyses[index];
                            return _buildMoveRow(context, move, langProvider);
                          },
                        ),
                ),
              ),
              const SizedBox(height: 14),

              // Footer Buttons
              Row(
                children: [
                  if (onMainMenu != null)
                    Expanded(
                      child: InteractiveButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onMainMenu!();
                        },
                        backgroundColor: Colors.transparent,
                        border: Border.all(
                          color: AppColors.borderColor(context),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            langProvider.tr('main_menu'),
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textSecondaryColor(context),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (onMainMenu != null && onPlayAgain != null)
                    const SizedBox(width: 10),
                  if (onPlayAgain != null)
                    Expanded(
                      child: InteractiveButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onPlayAgain!();
                        },
                        backgroundColor: const Color(0xFFD97706),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            langProvider.tr('play_again'),
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildQualityBadge(
    BuildContext context,
    String label,
    int count,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            '$label: $count',
            style: GoogleFonts.plusJakartaSans(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveRow(
    BuildContext context,
    MoveAnalysis move,
    LanguageProvider langProvider,
  ) {
    Color qualityColor;
    IconData qualityIcon;

    switch (move.quality) {
      case MoveQuality.brilliant:
        qualityColor = const Color(0xFF06B6D4);
        qualityIcon = Icons.auto_awesome;
        break;
      case MoveQuality.best:
        qualityColor = const Color(0xFF10B981);
        qualityIcon = Icons.check_circle_outline;
        break;
      case MoveQuality.good:
        qualityColor = const Color(0xFF84CC16);
        qualityIcon = Icons.thumb_up_alt_outlined;
        break;
      case MoveQuality.inaccuracy:
        qualityColor = const Color(0xFFF59E0B);
        qualityIcon = Icons.help_outline;
        break;
      case MoveQuality.mistake:
        qualityColor = const Color(0xFFEA580C);
        qualityIcon = Icons.warning_amber_rounded;
        break;
      case MoveQuality.blunder:
        qualityColor = const Color(0xFFEF4444);
        qualityIcon = Icons.error_outline;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            alignment: Alignment.center,
            child: Text(
              '${move.moveNumber}.',
              style: GoogleFonts.cinzel(
                color: AppColors.textMutedColor(context),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: qualityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(qualityIcon, size: 13, color: qualityColor),
                const SizedBox(width: 4),
                Text(
                  move.moveNotation,
                  style: GoogleFonts.cinzel(
                    color: qualityColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              langProvider.tr(move.coachFeedbackKey),
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textColor(context),
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
