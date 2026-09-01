import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:game_papan/services/language_provider.dart';
import 'package:game_papan/theme/app_colors.dart';
import 'package:game_papan/widgets/interactive_button.dart';

class LanguageSelectionDialog extends StatelessWidget {
  const LanguageSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final currentLang = langProvider.currentLanguage;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      backgroundColor: AppColors.surface(context),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.4), width: 1.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.language_rounded, color: Color(0xFF451A03), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        langProvider.tr('select_language'),
                        style: GoogleFonts.cinzel(
                          color: AppColors.textColor(context),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Bahasa / Language / 言語',
                        style: TextStyle(
                          color: AppColors.textMutedColor(context),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.textSecondaryColor(context), size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 18),

            ...AppLanguage.values.map((lang) {
              final isSelected = currentLang == lang;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InteractiveButton(
                  onPressed: () {
                    langProvider.setLanguage(lang);
                    Navigator.pop(context);
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  backgroundColor: isSelected
                      ? const Color(0xFFD97706).withValues(alpha: 0.22)
                      : AppColors.surfaceDark(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFBBF24) : AppColors.borderColor(context),
                    width: isSelected ? 1.8 : 1.0,
                  ),
                  child: Row(
                    children: [
                      Text(
                        lang.flag,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang.label,
                              style: GoogleFonts.plusJakartaSans(
                                color: isSelected ? const Color(0xFFFBBF24) : AppColors.textColor(context),
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                fontSize: 13.5,
                              ),
                            ),
                            Text(
                              lang.region,
                              style: TextStyle(
                                color: AppColors.textMutedColor(context),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFBBF24),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, size: 14, color: Color(0xFF451A03)),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
