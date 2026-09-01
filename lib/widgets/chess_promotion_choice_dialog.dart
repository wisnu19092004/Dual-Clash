import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:game_papan/chess/chess_piece.dart';
import 'package:game_papan/widgets/chess_piece_widget.dart';
import 'package:game_papan/widgets/interactive_button.dart';

class ChessPromotionChoiceDialog extends StatelessWidget {
  final ChessColor color;
  final ValueChanged<ChessPieceType> onPieceSelected;

  const ChessPromotionChoiceDialog({
    super.key,
    required this.color,
    required this.onPieceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final promoOptions = [
      (
        type: ChessPieceType.queen,
        name: 'Ratu / Queen',
        desc: 'Gerak bebas ke segala arah',
      ),
      (
        type: ChessPieceType.rook,
        name: 'Benteng / Rook',
        desc: 'Gerak lurus horizontal & vertikal',
      ),
      (
        type: ChessPieceType.bishop,
        name: 'Gajah / Bishop',
        desc: 'Gerak diagonal',
      ),
      (
        type: ChessPieceType.knight,
        name: 'Kuda / Knight',
        desc: 'Gerak bentuk L & lompat bidak',
      ),
    ];

    return Dialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF92400E), width: 1.5),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFFFBBF24),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Promosi Pion!',
                        style: GoogleFonts.cinzel(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pilih bidak baru untuk pion Anda:',
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ...promoOptions.map((option) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InteractiveButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onPieceSelected(option.type);
                  },
                  backgroundColor: const Color(0xFF334155).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: option.type == ChessPieceType.queen
                        ? const Color(0xFFFBBF24).withValues(alpha: 0.6)
                        : Colors.white12,
                    width: option.type == ChessPieceType.queen ? 1.5 : 1.0,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFD97706).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Center(
                          child: ChessPieceWidget(
                            piece: ChessPiece(type: option.type, color: color),
                            tileSize: 46,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.name,
                              style: GoogleFonts.cinzel(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              option.desc,
                              style: GoogleFonts.outfit(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFFBBF24),
                        size: 20,
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
