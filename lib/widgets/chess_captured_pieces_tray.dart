import 'package:flutter/material.dart';
import 'package:game_papan/chess/chess_piece.dart';
import 'package:game_papan/widgets/chess_piece_painter.dart';

class ChessCapturedPiecesTray extends StatelessWidget {
  final List<ChessPiece> capturedPieces;

  const ChessCapturedPiecesTray({super.key, required this.capturedPieces});

  @override
  Widget build(BuildContext context) {
    // Fixed height container to prevent layout shifting during captures
    return SizedBox(
      height: 20,
      child: capturedPieces.isEmpty
          ? const SizedBox(height: 20)
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: capturedPieces.length > 12 ? 12 : capturedPieces.length,
              separatorBuilder: (_, _) => const SizedBox(width: 3),
              itemBuilder: (context, index) {
                final piece = capturedPieces[index];
                return SizedBox(
                  width: 15,
                  height: 18,
                  child: CustomPaint(
                    painter: ChessPiecePainter(
                      type: piece.type,
                      color: piece.color,
                      isCaptured: true,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
