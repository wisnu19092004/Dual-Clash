import 'package:flutter/material.dart';
import 'package:game_papan/chess/chess_piece.dart';
import 'package:game_papan/widgets/chess_piece_painter.dart';

class ChessPieceWidget extends StatelessWidget {
  final ChessPiece piece;
  final double tileSize;

  const ChessPieceWidget({
    super.key,
    required this.piece,
    required this.tileSize,
  });

  // Authentic relative size ratios per piece type to create a grand, realistic board feel
  double get _pieceScaleFactor {
    switch (piece.type) {
      case ChessPieceType.king:
        return 0.94;
      case ChessPieceType.queen:
        return 0.91;
      case ChessPieceType.rook:
        return 0.84;
      case ChessPieceType.bishop:
        return 0.86;
      case ChessPieceType.knight:
        return 0.84;
      case ChessPieceType.pawn:
        return 0.74;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWhite = piece.color == ChessColor.white;
    final pieceSize = tileSize * _pieceScaleFactor;

    return Center(
      child: SizedBox(
        width: pieceSize,
        height: pieceSize,
        child: RepaintBoundary(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Soft Realistic Drop Shadow under the piece
              Positioned(
                bottom: pieceSize * 0.03,
                child: Container(
                  width: pieceSize * 0.72,
                  height: pieceSize * 0.16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.elliptical(pieceSize * 0.72, pieceSize * 0.16)),
                    boxShadow: [
                      BoxShadow(
                        color: isWhite 
                            ? const Color(0xFF451A03).withValues(alpha: 0.45) 
                            : Colors.black.withValues(alpha: 0.75),
                        blurRadius: 5.0,
                        spreadRadius: 1.0,
                        offset: const Offset(0, 3.0),
                      ),
                    ],
                  ),
                ),
              ),

              // High Definition Bronze & Gold Vector Painted Chess Piece
              CustomPaint(
                size: Size(pieceSize, pieceSize),
                painter: ChessPiecePainter(
                  type: piece.type,
                  color: piece.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
