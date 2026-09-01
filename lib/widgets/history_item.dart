import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:game_papan/models/game_enums.dart';
import 'package:game_papan/models/match_record.dart';
import 'package:game_papan/widgets/game_emblem_icon.dart';
import 'package:game_papan/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:game_papan/services/language_provider.dart';

class HistoryItem extends StatelessWidget {
  final MatchRecord record;

  const HistoryItem({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final isWin = record.outcome == MatchOutcome.win;
    final isDraw = record.outcome == MatchOutcome.draw;
    final isChess = record.gameType == GameType.chess;
    final lang = context.watch<LanguageProvider>();

    Color badgeColor;
    String badgeText;

    if (isWin) {
      badgeColor = AppColors.success;
      badgeText = lang.tr('win');
    } else if (isDraw) {
      badgeColor = AppColors.warning;
      badgeText = lang.tr('draw');
    } else {
      badgeColor = AppColors.error;
      badgeText = lang.tr('loss');
    }

    final formattedDate = DateFormat(
      'dd MMM yyyy, HH:mm',
      lang.currentLocale.toLanguageTag(),
    ).format(record.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: isChess
                  ? const LinearGradient(
                      colors: [Color(0xFF381F12), Color(0xFF1B0E07)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF26140A), Color(0xFF190C05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              shape: isChess ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: isChess ? null : BorderRadius.circular(8),
              border: Border.all(
                color: isChess
                    ? const Color(0xFFD97706)
                    : const Color(0xFFEA580C),
                width: 1.2,
              ),
            ),
            child: Center(child: GameEmblemIcon(isChess: isChess, size: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      lang.tr(
                        record.gameType == GameType.chess
                            ? 'chess_tab'
                            : 'shogi_tab',
                      ),
                      style: GoogleFonts.cinzel(
                        color: AppColors.textColor(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      lang.trArgs('versus', {'name': record.opponentName}),
                      style: TextStyle(
                        color: AppColors.textSecondaryColor(context),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: AppColors.textMutedColor(context),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              if (record.gameMode == GameMode.vsPlayer)
                Text(
                  record.ratingChange >= 0
                      ? '+${record.ratingChange} ELO'
                      : '${record.ratingChange} ELO',
                  style: TextStyle(
                    color: record.ratingChange >= 0
                        ? AppColors.success
                        : AppColors.error,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                Text(
                  '±0 ELO',
                  style: TextStyle(
                    color: AppColors.textMutedColor(context),
                    fontSize: 10.5,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
