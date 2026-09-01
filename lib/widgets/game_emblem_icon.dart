import 'package:flutter/material.dart';
import 'package:game_papan/chess/chess_piece.dart';
import 'package:game_papan/shogi/shogi_piece.dart';
import 'package:game_papan/widgets/chess_piece_painter.dart';
import 'package:game_papan/widgets/shogi_piece_widget.dart';

/// Authentic Game Emblem Badge for Chess & Shogi
/// Renders an authentic King (♔) crown / vector piece for Chess and an authentic Komagata (王将) piece for Shogi.
class GameEmblemIcon extends StatelessWidget {
  final bool isChess;
  final double size;
  final Color? glowColor;

  const GameEmblemIcon({
    super.key,
    required this.isChess,
    this.size = 28,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isChess) {
      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (glowColor != null)
              Container(
                width: size * 0.9,
                height: size * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor!.withValues(alpha: 0.45),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            CustomPaint(
              size: Size(size, size),
              painter: ChessPiecePainter(
                type: ChessPieceType.king,
                color: ChessColor.white,
              ),
            ),
          ],
        ),
      );
    } else {
      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (glowColor != null)
              Container(
                width: size * 0.9,
                height: size * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor!.withValues(alpha: 0.45),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ShogiPieceWidget(
              piece: const ShogiPiece(
                type: ShogiPieceType.king,
                player: ShogiPlayer.sente,
              ),
              baseTileSize: size * 0.95,
              isFacingDown: false,
            ),
          ],
        ),
      );
    }
  }
}
