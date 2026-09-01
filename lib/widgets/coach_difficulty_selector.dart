import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:game_papan/models/game_enums.dart';
import 'package:game_papan/services/language_provider.dart';
import 'package:game_papan/widgets/interactive_button.dart';
import 'package:game_papan/theme/app_colors.dart';

class CoachDifficultySelector extends StatelessWidget {
  final CoachLevel selectedLevel;
  final ValueChanged<CoachLevel> onSelected;
  final Color activeColor;

  const CoachDifficultySelector({
    super.key,
    required this.selectedLevel,
    required this.onSelected,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    final levels = [
      (
        level: CoachLevel.beginner,
        nameKey: 'coach_beginner',
        descKey: 'coach_beginner_desc',
        icon: Icons.school_outlined,
        badge: 'LV 1',
      ),
      (
        level: CoachLevel.easy,
        nameKey: 'coach_easy',
        descKey: 'coach_easy_desc',
        icon: Icons.psychology_outlined,
        badge: 'LV 2',
      ),
      (
        level: CoachLevel.medium,
        nameKey: 'coach_medium',
        descKey: 'coach_medium_desc',
        icon: Icons.sports_kabaddi_outlined,
        badge: 'LV 3',
      ),
      (
        level: CoachLevel.hard,
        nameKey: 'coach_hard',
        descKey: 'coach_hard_desc',
        icon: Icons.local_fire_department_outlined,
        badge: 'LV 4',
      ),
      (
        level: CoachLevel.master,
        nameKey: 'coach_master',
        descKey: 'coach_master_desc',
        icon: Icons.military_tech_outlined,
        badge: 'LV 5',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              langProvider.tr('coach_level_title'),
              style: GoogleFonts.cinzel(
                color: AppColors.textSecondaryColor(context),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFD97706).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                  width: 0.8,
                ),
              ),
              child: Text(
                '5 TINGKATAN PELATIH',
                style: GoogleFonts.cinzel(
                  color: const Color(0xFFFBBF24),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Vertical List so all 5 options (Pemula, Mudah, Sedang, Sulit, Master) are clearly visible and accessible without hidden horizontal scroll
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: levels.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = levels[index];
            final isSelected = selectedLevel == item.level;

            return InteractiveButton(
              onPressed: () => onSelected(item.level),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              backgroundColor: isSelected
                  ? activeColor.withValues(alpha: 0.2)
                  : AppColors.surfaceDark(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? activeColor : AppColors.borderColor(context),
                width: isSelected ? 2 : 1,
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? activeColor.withValues(alpha: 0.25)
                          : AppColors.surface(context),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? activeColor : AppColors.borderColor(context),
                      ),
                    ),
                    child: Icon(
                      item.icon,
                      color: isSelected ? activeColor : AppColors.textSecondaryColor(context),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              langProvider.tr(item.nameKey),
                              style: GoogleFonts.cinzel(
                                color: isSelected
                                    ? AppColors.textColor(context)
                                    : AppColors.textColor(context),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? activeColor.withValues(alpha: 0.3)
                                    : Colors.white10,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.badge,
                                style: TextStyle(
                                  color: isSelected ? activeColor : Colors.grey,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          langProvider.tr(item.descKey),
                          style: TextStyle(
                            color: AppColors.textSecondaryColor(context),
                            fontSize: 10.5,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected ? activeColor : AppColors.borderColor(context),
                    size: 20,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
