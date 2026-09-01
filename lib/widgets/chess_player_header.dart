import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:game_papan/chess/chess_piece.dart';
import 'package:game_papan/theme/app_colors.dart';
import 'package:game_papan/widgets/chess_captured_pieces_tray.dart';

class ChessPlayerHeader extends StatelessWidget {
  final String name;
  final int rating;
  final ChessColor color;
  final String timeString;
  final bool isCurrentTurn;
  final bool isAi;
  final List<ChessPiece> capturedPieces;

  const ChessPlayerHeader({
    super.key,
    required this.name,
    required this.rating,
    required this.color,
    required this.timeString,
    required this.isCurrentTurn,
    required this.isAi,
    required this.capturedPieces,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      height: 72, // Fixed height to guarantee no UI jumping/shifting
      decoration: BoxDecoration(
        color: isCurrentTurn ? AppColors.surface(context) : AppColors.surfaceDark(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentTurn ? const Color(0xFFF59E0B) : AppColors.borderColor(context),
          width: isCurrentTurn ? 2.0 : 1.0,
        ),
        boxShadow: isCurrentTurn
            ? [
                BoxShadow(
                  color: const Color(0xFFD97706).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              ]
            : [],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
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
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: color == ChessColor.white ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                width: 1.5,
              ),
            ),
            child: Icon(
              isAi ? Icons.smart_toy : Icons.person,
              size: 20,
              color: color == ChessColor.white ? const Color(0xFF78350F) : const Color(0xFFFDE68A),
            ),
          ),
          const SizedBox(width: 10),
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
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFF59E0B), width: 0.6),
                      ),
                      child: Text(
                        '$rating',
                        style: const TextStyle(
                          color: Color(0xFFFBBF24),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                ChessCapturedPiecesTray(capturedPieces: capturedPieces),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: isCurrentTurn
                  ? const LinearGradient(
                      colors: [Color(0xFFD97706), Color(0xFF92400E)],
                    )
                  : null,
              color: isCurrentTurn ? null : AppColors.surface(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCurrentTurn ? const Color(0xFFFBBF24) : AppColors.borderColor(context),
                width: 1,
              ),
            ),
            child: Text(
              timeString,
              style: GoogleFonts.robotoMono(
                color: isCurrentTurn ? Colors.white : AppColors.textColor(context),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
