import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:game_papan/chess/chess_piece.dart';
import 'package:game_papan/theme/app_colors.dart';
import 'package:game_papan/widgets/chess_captured_pieces_tray.dart';
import 'package:game_papan/widgets/interactive_button.dart';

class ChessPlayerHeader extends StatelessWidget {
  final String name;
  final int rating;
  final ChessColor color;
  final String timeString;
  final bool isCurrentTurn;
  final bool isAi;
  final List<ChessPiece> capturedPieces;
  final VoidCallback? onUndoMove;

  const ChessPlayerHeader({
    super.key,
    required this.name,
    required this.rating,
    required this.color,
    required this.timeString,
    required this.isCurrentTurn,
    required this.isAi,
    required this.capturedPieces,
    this.onUndoMove,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      height: 64, // Sleek compact height for max board responsiveness
      decoration: BoxDecoration(
        color: isCurrentTurn ? AppColors.surface(context) : AppColors.surfaceDark(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentTurn ? const Color(0xFFF59E0B) : AppColors.borderColor(context),
          width: isCurrentTurn ? 1.8 : 1.0,
        ),
        boxShadow: isCurrentTurn
            ? [
                BoxShadow(
                  color: const Color(0xFFD97706).withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : [],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: color == ChessColor.white
                  ? const LinearGradient(
                      colors: [Color(0xFFFFFBEB), Color(0xFFE5A65E), Color(0xFFB46E28)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF5C3825), Color(0xFF221109), Color(0xFF140803)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: color == ChessColor.white ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                width: 1.2,
              ),
            ),
            child: Icon(
              isAi ? Icons.smart_toy : Icons.person,
              size: 18,
              color: color == ChessColor.white ? const Color(0xFF78350F) : const Color(0xFFFDE68A),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: GoogleFonts.cinzel(
                          color: AppColors.textColor(context),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFF59E0B), width: 0.6),
                      ),
                      child: Text(
                        '$rating',
                        style: const TextStyle(
                          color: Color(0xFFFBBF24),
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                ChessCapturedPiecesTray(
                  capturedPieces: capturedPieces,
                ),
              ],
            ),
          ),
          if (onUndoMove != null) ...[
            InteractiveButton(
              onPressed: onUndoMove,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              backgroundColor: AppColors.surface(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFFBBF24).withValues(alpha: 0.6),
                width: 1.0,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.replay_rounded,
                    size: 14,
                    color: Color(0xFFFBBF24),
                  ),
                  SizedBox(width: 3),
                  Text(
                    'Undo',
                    style: TextStyle(
                      color: Color(0xFFFBBF24),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: isCurrentTurn
                  ? const Color(0xFFD97706).withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCurrentTurn ? const Color(0xFFF59E0B) : Colors.transparent,
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 13,
                  color: isCurrentTurn ? const Color(0xFFFBBF24) : AppColors.textSecondaryColor(context),
                ),
                const SizedBox(width: 4),
                Text(
                  timeString,
                  style: GoogleFonts.cinzel(
                    color: isCurrentTurn ? Colors.white : AppColors.textSecondaryColor(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
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
