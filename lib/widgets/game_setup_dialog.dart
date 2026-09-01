import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:game_papan/chess/chess_piece.dart';
import 'package:game_papan/models/bot_difficulty.dart';
import 'package:game_papan/models/game_enums.dart';
import 'package:game_papan/screens/chess_game_screen.dart';
import 'package:game_papan/screens/shogi_game_screen.dart';
import 'package:game_papan/shogi/shogi_piece.dart';
import 'package:game_papan/services/language_provider.dart';
import 'package:game_papan/widgets/game_emblem_icon.dart';
import 'package:game_papan/widgets/interactive_button.dart';
import 'package:game_papan/widgets/game_mode_selector.dart';
import 'package:game_papan/widgets/bot_difficulty_selector.dart';
import 'package:game_papan/widgets/coach_difficulty_selector.dart';
import 'package:game_papan/widgets/match_duration_selector.dart';
import 'package:game_papan/theme/app_colors.dart';

class GameSetupDialog extends StatefulWidget {
  final GameType gameType;

  const GameSetupDialog({super.key, required this.gameType});

  @override
  State<GameSetupDialog> createState() => _GameSetupDialogState();
}

class _GameSetupDialogState extends State<GameSetupDialog> {
  GameMode _selectedMode = GameMode.vsBot;
  BotDifficulty _selectedDifficulty = BotDifficulty.intermediate;
  CoachLevel _selectedCoachLevel = CoachLevel.medium;
  int _matchDurationMinutes = 10;
  ChessColor _selectedChessColor = ChessColor.white;
  ShogiPlayer _selectedShogiPlayer = ShogiPlayer.sente;

  BotDifficulty get _effectiveBotDifficulty {
    if (_selectedMode == GameMode.coach) {
      switch (_selectedCoachLevel) {
        case CoachLevel.beginner:
          return BotDifficulty.beginner;
        case CoachLevel.easy:
          return BotDifficulty.novice;
        case CoachLevel.medium:
          return BotDifficulty.intermediate;
        case CoachLevel.hard:
          return BotDifficulty.advanced;
        case CoachLevel.master:
          return BotDifficulty.grandmaster;
      }
    }
    return _selectedDifficulty;
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final isChess = widget.gameType == GameType.chess;
    final primaryColor = isChess ? AppColors.primary : AppColors.secondary;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surface(context),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(22),
          constraints: const BoxConstraints(maxWidth: 460),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isChess
                            ? [const Color(0xFFD97706), const Color(0xFF92400E)]
                            : [
                                const Color(0xFFEA580C),
                                const Color(0xFF9A3412),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: GameEmblemIcon(isChess: isChess, size: 26),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isChess
                          ? langProvider.tr('setup_chess')
                          : langProvider.tr('setup_shogi'),
                      style: GoogleFonts.cinzel(
                        color: AppColors.textColor(context),
                        fontSize: 17.5,
                        fontWeight: FontWeight.bold,
                      ),
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
              const SizedBox(height: 18),

              // Game Mode Selector (vs Bot, Coach, or Pass & Play)
              GameModeSelector(
                selectedMode: _selectedMode,
                activeColor: primaryColor,
                onSelected: (mode) => setState(() => _selectedMode = mode),
              ),
              const SizedBox(height: 16),

              // Side Selection
              if (_selectedMode == GameMode.vsBot || _selectedMode == GameMode.coach) ...[
                _buildSideSelector(isChess, primaryColor, langProvider),
                const SizedBox(height: 16),
              ] else ...[
                _buildRandomSideNotice(isChess, langProvider),
                const SizedBox(height: 16),
              ],

              // Match Duration Selector (including Unlimited)
              MatchDurationSelector(
                selectedMinutes: _matchDurationMinutes,
                activeColor: primaryColor,
                onSelected: (mins) =>
                    setState(() => _matchDurationMinutes = mins),
              ),

              // Bot Difficulty Selector if vsBot
              if (_selectedMode == GameMode.vsBot) ...[
                const SizedBox(height: 16),
                BotDifficultySelector(
                  selectedDifficulty: _selectedDifficulty,
                  activeColor: primaryColor,
                  onSelected: (diff) =>
                      setState(() => _selectedDifficulty = diff),
                ),
              ],

              // Coach Level Selector if Coach mode
              if (_selectedMode == GameMode.coach) ...[
                const SizedBox(height: 16),
                CoachDifficultySelector(
                  selectedLevel: _selectedCoachLevel,
                  activeColor: primaryColor,
                  onSelected: (lvl) =>
                      setState(() => _selectedCoachLevel = lvl),
                ),
              ],

              const SizedBox(height: 22),

              // Start Button
              SizedBox(
                width: double.infinity,
                child: InteractiveButton(
                  onPressed: () {
                    Navigator.pop(context);
                    final isFirstPlayer = Random().nextBool();
                    if (isChess) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChessGameScreen(
                            mode: _selectedMode,
                            botDifficulty: _effectiveBotDifficulty,
                            coachLevel: _selectedMode == GameMode.coach ? _selectedCoachLevel : null,
                            durationMinutes: _matchDurationMinutes,
                            playerColor: _selectedMode == GameMode.vsPlayer
                                ? (isFirstPlayer
                                      ? ChessColor.white
                                      : ChessColor.black)
                                : _selectedChessColor,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ShogiGameScreen(
                            mode: _selectedMode,
                            botDifficulty: _effectiveBotDifficulty,
                            coachLevel: _selectedMode == GameMode.coach ? _selectedCoachLevel : null,
                            durationMinutes: _matchDurationMinutes,
                            playerSide: _selectedMode == GameMode.vsPlayer
                                ? (isFirstPlayer
                                      ? ShogiPlayer.sente
                                      : ShogiPlayer.gote)
                                : _selectedShogiPlayer,
                          ),
                        ),
                      );
                    }
                  },
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: isChess
                        ? [
                            const Color(0xFFFBBF24),
                            const Color(0xFFD97706),
                            const Color(0xFF92400E),
                          ]
                        : [
                            const Color(0xFFFB923C),
                            const Color(0xFFEA580C),
                            const Color(0xFF9A3412),
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        langProvider.tr('start_match'),
                        style: GoogleFonts.cinzel(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRandomSideNotice(bool isChess, LanguageProvider langProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor(context)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shuffle_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              langProvider.tr(
                isChess ? 'random_chess_side' : 'random_shogi_side',
              ),
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondaryColor(context),
                fontSize: 11.5,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideSelector(
    bool isChess,
    Color activeColor,
    LanguageProvider langProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          langProvider.tr(isChess ? 'choose_side_chess' : 'choose_side_shogi'),
          style: GoogleFonts.cinzel(
            color: AppColors.textSecondaryColor(context),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        if (isChess)
          Row(
            children: [
              Expanded(
                child: _buildSideOption(
                  title: langProvider.tr('side_white_title'),
                  subtitle: langProvider.tr('side_white_sub'),
                  isSelected: _selectedChessColor == ChessColor.white,
                  activeColor: activeColor,
                  onTap: () => setState(() => _selectedChessColor = ChessColor.white),
                  emblem: const GameEmblemIcon(isChess: true, size: 24),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSideOption(
                  title: langProvider.tr('side_black_title'),
                  subtitle: langProvider.tr('side_black_sub'),
                  isSelected: _selectedChessColor == ChessColor.black,
                  activeColor: activeColor,
                  onTap: () => setState(() => _selectedChessColor = ChessColor.black),
                  emblem: const GameEmblemIcon(isChess: true, size: 24),
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: _buildSideOption(
                  title: langProvider.tr('side_sente_title'),
                  subtitle: langProvider.tr('side_sente_sub'),
                  isSelected: _selectedShogiPlayer == ShogiPlayer.sente,
                  activeColor: activeColor,
                  onTap: () => setState(() => _selectedShogiPlayer = ShogiPlayer.sente),
                  emblem: const GameEmblemIcon(isChess: false, size: 24),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSideOption(
                  title: langProvider.tr('side_gote_title'),
                  subtitle: langProvider.tr('side_gote_sub'),
                  isSelected: _selectedShogiPlayer == ShogiPlayer.gote,
                  activeColor: activeColor,
                  onTap: () => setState(() => _selectedShogiPlayer = ShogiPlayer.gote),
                  emblem: const GameEmblemIcon(isChess: false, size: 24),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSideOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
    required Widget emblem,
  }) {
    return InteractiveButton(
      onPressed: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          emblem,
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cinzel(
                    color: AppColors.textColor(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isSelected
                        ? activeColor
                        : AppColors.textSecondaryColor(context),
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
