import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:game_papan/models/bot_difficulty.dart';
import 'package:game_papan/widgets/interactive_button.dart';
import 'package:game_papan/theme/app_colors.dart';

class BotDifficultySelector extends StatelessWidget {
  final BotDifficulty selectedDifficulty;
  final ValueChanged<BotDifficulty> onSelected;
  final Color activeColor;

  const BotDifficultySelector({
    super.key,
    required this.selectedDifficulty,
    required this.onSelected,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TINGKAT KEPINTARAN BOT (RATING)',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textSecondaryColor(context),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        ...BotDifficulty.values.map((diff) {
          final isSelected = selectedDifficulty == diff;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InteractiveButton(
              onPressed: () => onSelected(diff),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              backgroundColor: isSelected ? activeColor.withValues(alpha: 0.18) : AppColors.surfaceDark(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? activeColor : AppColors.borderColor(context),
                width: isSelected ? 1.8 : 1.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          diff.title,
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textColor(context),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          diff.description,
                          style: TextStyle(color: AppColors.textSecondaryColor(context), fontSize: 11, fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.amber : Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${diff.rating} ELO',
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
