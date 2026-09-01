import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:game_papan/models/game_enums.dart';
import 'package:game_papan/services/language_provider.dart';
import 'package:game_papan/widgets/interactive_button.dart';
import 'package:game_papan/theme/app_colors.dart';

class GameModeSelector extends StatelessWidget {
  final GameMode selectedMode;
  final ValueChanged<GameMode> onSelected;
  final Color activeColor;

  const GameModeSelector({
    super.key,
    required this.selectedMode,
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
          langProvider.tr('game_mode'),
          style: GoogleFonts.cinzel(
            color: AppColors.textSecondaryColor(context),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildOption(
                context: context,
                mode: GameMode.vsBot,
                title: langProvider.tr('vs_bot'),
                subtitle: langProvider.tr('vs_bot_sub'),
                icon: Icons.smart_toy_outlined,
                isSelected: selectedMode == GameMode.vsBot,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildOption(
                context: context,
                mode: GameMode.vsPlayer,
                title: langProvider.tr('vs_player'),
                subtitle: langProvider.tr('vs_player_sub'),
                icon: Icons.people_outline,
                isSelected: selectedMode == GameMode.vsPlayer,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required GameMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
  }) {
    return InteractiveButton(
      onPressed: () => onSelected(mode),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      backgroundColor: isSelected ? activeColor.withValues(alpha: 0.2) : AppColors.surfaceDark(context),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: isSelected ? activeColor : AppColors.borderColor(context),
        width: isSelected ? 2 : 1,
      ),
      child: Column(
        children: [
          Icon(icon, color: isSelected ? activeColor : AppColors.textSecondaryColor(context), size: 26),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.cinzel(
              color: AppColors.textColor(context),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: isSelected ? AppColors.textSecondaryColor(context) : AppColors.textMutedColor(context),
              fontSize: 10,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
