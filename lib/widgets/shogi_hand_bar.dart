import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:game_papan/shogi/shogi_piece.dart';
import 'package:game_papan/widgets/shogi_piece_widget.dart';

class ShogiHandBar extends StatelessWidget {
  final String title;
  final List<ShogiPiece> handPieces;
  final ShogiPiece? selectedPiece;
  final Function(ShogiPiece piece) onPieceSelected;
  final bool isMyTurn;

  const ShogiHandBar({
    super.key,
    required this.title,
    required this.handPieces,
    required this.selectedPiece,
    required this.onPieceSelected,
    required this.isMyTurn,
  });

  @override
  Widget build(BuildContext context) {
    final Map<ShogiPieceType, int> pieceCounts = {};
    final Map<ShogiPieceType, ShogiPiece> pieceMap = {};

    for (final p in handPieces) {
      pieceCounts[p.type] = (pieceCounts[p.type] ?? 0) + 1;
      pieceMap[p.type] = p;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF261811),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMyTurn ? const Color(0xFFEA580C) : const Color(0xFF5D3915),
          width: isMyTurn ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF381F12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF78350F), width: 0.8),
            ),
            child: Text(
              title,
              style: GoogleFonts.cinzel(
                color: const Color(0xFFFDBA74),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: handPieces.isEmpty
                ? Text(
                    'Tidak ada bidak di tangan',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: pieceCounts.entries.map((entry) {
                        final type = entry.key;
                        final count = entry.value;
                        final piece = pieceMap[type]!;
                        final isSelected = selectedPiece?.type == type;

                        return GestureDetector(
                          onTap: isMyTurn ? () => onPieceSelected(piece) : null,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFEA580C).withValues(alpha: 0.35)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? const Color(0xFFF97316) : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ShogiPieceWidget(
                                  piece: ShogiPiece(type: type, player: ShogiPlayer.sente),
                                  baseTileSize: 32,
                                ),
                                if (count > 1)
                                  Positioned(
                                    right: -2,
                                    bottom: -2,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFEA580C),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '$count',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
