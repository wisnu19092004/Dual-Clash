import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:game_papan/shogi/shogi_piece.dart';
import 'package:game_papan/widgets/shogi_pentagon_clipper.dart';

class ShogiPieceWidget extends StatelessWidget {
  final ShogiPiece piece;
  final double baseTileSize;
  final bool isFacingDown;

  const ShogiPieceWidget({
    super.key,
    required this.piece,
    required this.baseTileSize,
    this.isFacingDown = false,
  });

  // Authentic Traditional Shogi scale factor by rank:
  // King/Gyoku (largest) -> Rook/Bishop -> Gold/Silver -> Knight/Lance -> Pawn (smallest)
  double get _pieceScaleRatio {
    switch (piece.type) {
      case ShogiPieceType.king:
        return 0.94;
      case ShogiPieceType.rook:
      case ShogiPieceType.promotedRook:
      case ShogiPieceType.bishop:
      case ShogiPieceType.promotedBishop:
        return 0.90;
      case ShogiPieceType.gold:
      case ShogiPieceType.silver:
      case ShogiPieceType.promotedSilver:
        return 0.86;
      case ShogiPieceType.knight:
      case ShogiPieceType.promotedKnight:
      case ShogiPieceType.lance:
      case ShogiPieceType.promotedLance:
        return 0.81;
      case ShogiPieceType.pawn:
      case ShogiPieceType.promotedPawn:
        return 0.75;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPromoted = piece.isPromoted;
    final pieceHeight = baseTileSize * _pieceScaleRatio;
    final pieceWidth = pieceHeight * 0.88;

    return Transform.rotate(
      angle: isFacingDown ? 3.14159 : 0,
      child: SizedBox(
        width: pieceWidth,
        height: pieceHeight,
        child: RepaintBoundary(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pentagon wooden piece with rich Warm Cedar/Kaya wood texture
              ClipPath(
                clipper: ShogiPentagonClipper(),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFFF0D4),
                        Color(0xFFECC48C),
                        Color(0xFFC99554),
                        Color(0xFFA26F32),
                      ],
                      stops: [0.0, 0.35, 0.75, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 3.5,
                        offset: Offset(0, 2.0),
                      ),
                    ],
                  ),
                ),
              ),

              // Realistic carved bevel border lines
              CustomPaint(
                size: Size(pieceWidth, pieceHeight),
                painter: ShogiPentagonPainter(
                  borderColor: const Color(0xFF6B3608),
                  borderWidth: 1.4,
                ),
              ),

              // Embossed Kanji Calligraphy - Centered on piece body
              Positioned(
                top: pieceHeight * 0.28,
                bottom: pieceHeight * 0.08,
                child: Center(
                  child: Text(
                    piece.kanji,
                    style: GoogleFonts.sawarabiMincho(
                      fontSize: pieceHeight * 0.44,
                      fontWeight: FontWeight.w900,
                      color: isPromoted
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFF241004),
                      height: 1.0,
                      shadows: [
                        Shadow(
                          color: isPromoted
                              ? const Color(0xFFFEF2F2)
                              : const Color(0xFFFFF7ED).withValues(alpha: 0.6),
                          blurRadius: 0.5,
                          offset: const Offset(0.5, 0.8),
                        ),
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 1.2,
                          offset: const Offset(-0.4, -0.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
