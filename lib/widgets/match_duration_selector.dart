import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:game_papan/services/language_provider.dart';
import 'package:game_papan/widgets/interactive_button.dart';
import 'package:game_papan/theme/app_colors.dart';

class MatchDurationSelector extends StatelessWidget {
  final int selectedMinutes;
  final ValueChanged<int> onSelected;
  final Color activeColor;

  // 0 means Unlimited / Tanpa Batas Waktu
  static const List<int> durationOptions = [3, 5, 10, 15, 20, 0];

  const MatchDurationSelector({
    super.key,
    required this.selectedMinutes,
    required this.onSelected,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          langProvider.tr('duration_label'),
          style: GoogleFonts.cinzel(
            color: AppColors.textSecondaryColor(context),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: durationOptions.map((mins) {
            final isSelected = selectedMinutes == mins;
            final label = mins == 0 ? '∞' : '${mins}m';
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: InteractiveButton(
                  onPressed: () => onSelected(mins),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  backgroundColor: isSelected ? activeColor.withValues(alpha: 0.22) : AppColors.surfaceDark(context),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? activeColor : AppColors.borderColor(context),
                    width: isSelected ? 1.8 : 1.0,
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        color: isSelected ? Colors.white : AppColors.textSecondaryColor(context),
                        fontWeight: FontWeight.bold,
                        fontSize: mins == 0 ? 15 : 12.5,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
