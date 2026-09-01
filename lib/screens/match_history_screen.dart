import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:game_papan/models/game_enums.dart';
import 'package:game_papan/services/auth_service.dart';
import 'package:game_papan/services/language_provider.dart';
import 'package:game_papan/widgets/history_item.dart';
import 'package:game_papan/widgets/game_emblem_icon.dart';
import 'package:game_papan/theme/app_colors.dart';

class MatchHistoryScreen extends StatefulWidget {
  final GameType? filterGameType;

  const MatchHistoryScreen({super.key, this.filterGameType});

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: Chess, 2: Shogi

  @override
  void initState() {
    super.initState();
    if (widget.filterGameType == GameType.chess) {
      _selectedFilterIndex = 1;
    } else if (widget.filterGameType == GameType.shogi) {
      _selectedFilterIndex = 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final user = auth.currentUser;
    final allHistory = user?.history ?? [];

    final filteredHistory = allHistory.where((record) {
      if (_selectedFilterIndex == 1) return record.gameType == GameType.chess;
      if (_selectedFilterIndex == 2) return record.gameType == GameType.shogi;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textColor(context),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.history_rounded,
              color: Color(0xFFFBBF24),
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              langProvider.tr('match_history_title'),
              style: GoogleFonts.cinzel(
                color: AppColors.textColor(context),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Selector Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderColor(context)),
              ),
              child: Row(
                children: [
                  _buildFilterTab(0, langProvider.tr('filter_all'), null),
                  _buildFilterTab(1, langProvider.tr('chess_tab'), true),
                  _buildFilterTab(2, langProvider.tr('shogi_tab'), false),
                ],
              ),
            ),

            // History List or Empty State
            Expanded(
              child: filteredHistory.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD97706).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.history_toggle_off_rounded,
                                size: 54,
                                color: AppColors.textSecondaryColor(context),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              langProvider.tr('no_match_history'),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cinzel(
                                color: AppColors.textColor(context),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              langProvider.tr('no_match_history_desc'),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textSecondaryColor(context),
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filteredHistory.length,
                      itemBuilder: (context, index) {
                        return HistoryItem(record: filteredHistory[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(int index, String label, bool? isChess) {
    final isSelected = _selectedFilterIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilterIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFFD97706), Color(0xFF92400E)],
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFD97706).withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isChess != null) ...[
                GameEmblemIcon(isChess: isChess, size: 14),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: GoogleFonts.cinzel(
                  color: isSelected
                      ? Colors.white
                      : AppColors.textSecondaryColor(context),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
