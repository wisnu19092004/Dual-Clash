import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:game_papan/chess/chess_piece.dart';

/// Custom Vector Painter for High-Detail Chess Pieces styled exactly like the logo:
/// - Light (White): Polished Warm Bronze & Golden Metallic with bevel reflections
/// - Dark (Black): Deep Burnished Obsidian & Dark Bronze with gold rim highlights
class ChessPiecePainter extends CustomPainter {
  final ChessPieceType type;
  final ChessColor color;
  final bool isCaptured;

  ChessPiecePainter({
    required this.type,
    required this.color,
    this.isCaptured = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final isWhite = color == ChessColor.white;

    // Rich metallic gradients directly sampled from the Chess X Shogi: Dual Clash logo
    final primaryGradient = isWhite
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFBEB), // Highlight glow
              Color(0xFFFDE68A), // Light gold
              Color(0xFFE5A65E), // Warm metallic bronze/gold
              Color(0xFFB46E28), // Deep golden bronze shade
              Color(0xFF85410E), // Base edge shadow
            ],
            stops: [0.0, 0.22, 0.52, 0.82, 1.0],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF5C3825), // Warm metallic bronze top highlight
              Color(0xFF381F12), // Rich dark bronze
              Color(0xFF221109), // Deep shadow obsidian
              Color(0xFF140803), // Rim shadow
            ],
            stops: [0.0, 0.35, 0.75, 1.0],
          );

    final fillPaint = Paint()
      ..shader = primaryGradient.createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    // Luxury outer rim outline
    final outlinePaint = Paint()
      ..color = isWhite ? const Color(0xFF6B3608) : const Color(0xFF0F0704)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.3, w * 0.048)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Specular light glint on edges
    final highlightPaint = Paint()
      ..color = isWhite ? const Color(0xFFFFFFFF).withValues(alpha: 0.85) : const Color(0xFFD97706).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, w * 0.028)
      ..strokeCap = StrokeCap.round;

    // Inner detail bevel paint
    final accentPaint = Paint()
      ..color = isWhite ? const Color(0xFF85410E) : const Color(0xFFD97706)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, w * 0.038)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Golden jewel accents
    final goldAccent = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFF7ED), Color(0xFFFBBF24), Color(0xFFD97706)],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    switch (type) {
      case ChessPieceType.pawn:
        _drawPawn(canvas, w, h, fillPaint, outlinePaint, highlightPaint, accentPaint);
        break;
      case ChessPieceType.knight:
        _drawKnight(canvas, w, h, fillPaint, outlinePaint, highlightPaint, accentPaint, isWhite);
        break;
      case ChessPieceType.bishop:
        _drawBishop(canvas, w, h, fillPaint, outlinePaint, highlightPaint, accentPaint, goldAccent);
        break;
      case ChessPieceType.rook:
        _drawRook(canvas, w, h, fillPaint, outlinePaint, highlightPaint, accentPaint);
        break;
      case ChessPieceType.queen:
        _drawQueen(canvas, w, h, fillPaint, outlinePaint, highlightPaint, accentPaint, goldAccent);
        break;
      case ChessPieceType.king:
        _drawKing(canvas, w, h, fillPaint, outlinePaint, highlightPaint, accentPaint, goldAccent);
        break;
    }
  }

  void _drawBase(Canvas canvas, double w, double h, Paint fillPaint, Paint outlinePaint, Paint highlightPaint, Paint accentPaint) {
    // Pedestal Bottom Base (Sculpted Metal)
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.16, h * 0.85, w * 0.68, h * 0.10),
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(baseRect, fillPaint);
    canvas.drawRRect(baseRect, outlinePaint);

    // Beveled upper tier ring
    final tierRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.24, h * 0.79, w * 0.52, h * 0.065),
      Radius.circular(w * 0.03),
    );
    canvas.drawRRect(tierRect, fillPaint);
    canvas.drawRRect(tierRect, outlinePaint);

    // Specular reflective highlight across the base rim
    final highlightPath = Path()
      ..moveTo(w * 0.22, h * 0.87)
      ..lineTo(w * 0.78, h * 0.87);
    canvas.drawPath(highlightPath, highlightPaint);
  }

  void _drawPawn(Canvas canvas, double w, double h, Paint fillPaint, Paint outlinePaint, Paint highlightPaint, Paint accentPaint) {
    _drawBase(canvas, w, h, fillPaint, outlinePaint, highlightPaint, accentPaint);

    // Smooth Curving Waist (Matches Pawn in Logo)
    final bodyPath = Path()
      ..moveTo(w * 0.35, h * 0.79)
      ..cubicTo(w * 0.38, h * 0.65, w * 0.39, h * 0.50, w * 0.34, h * 0.40)
      ..lineTo(w * 0.66, h * 0.40)
      ..cubicTo(w * 0.61, h * 0.50, w * 0.62, h * 0.65, w * 0.65, h * 0.79)
      ..close();
    canvas.drawPath(bodyPath, fillPaint);
    canvas.drawPath(bodyPath, outlinePaint);

    // Neck ring with double bevel
    final neckRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.29, h * 0.36, w * 0.42, h * 0.06),
      Radius.circular(w * 0.03),
    );
    canvas.drawRRect(neckRect, fillPaint);
    canvas.drawRRect(neckRect, outlinePaint);

    // Spherical Crown head
    canvas.drawCircle(Offset(w * 0.50, h * 0.22), w * 0.17, fillPaint);
    canvas.drawCircle(Offset(w * 0.50, h * 0.22), w * 0.17, outlinePaint);

    // Bright 3D Specular glint on head
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.44, h * 0.17), w * 0.048, shinePaint);
  }

  void _drawKnight(Canvas canvas, double w, double h, Paint fillPaint, Paint outlinePaint, Paint highlightPaint, Paint accentPaint, bool isWhite) {
    _drawBase(canvas, w, h, fillPaint, outlinePaint, highlightPaint, accentPaint);

    final horsePath = Path();
    horsePath.moveTo(w * 0.30, h * 0.79);
    horsePath.cubicTo(w * 0.22, h * 0.65, w * 0.20, h * 0.42, w * 0.30, h * 0.25);
    horsePath.lineTo(w * 0.35, h * 0.11); // Ear tip
    horsePath.lineTo(w * 0.43, h * 0.22);
    horsePath.lineTo(w * 0.56, h * 0.22);
    horsePath.cubicTo(w * 0.72, h * 0.26, w * 0.78, h * 0.36, w * 0.75, h * 0.44); // Snout
    horsePath.lineTo(w * 0.63, h * 0.47);
    horsePath.cubicTo(w * 0.55, h * 0.48, w * 0.58, h * 0.56, w * 0.68, h * 0.68); // Jaw curve
    horsePath.lineTo(w * 0.70, h * 0.79);
    horsePath.close();

    canvas.drawPath(horsePath, fillPaint);
    canvas.drawPath(horsePath, outlinePaint);

    // Sculpted Mane details
    final manePath = Path()
      ..moveTo(w * 0.28, h * 0.30)
      ..lineTo(w * 0.37, h * 0.33)
      ..moveTo(w * 0.25, h * 0.42)
      ..lineTo(w * 0.36, h * 0.45)
      ..moveTo(w * 0.24, h * 0.56)
      ..lineTo(w * 0.37, h * 0.58);
    canvas.drawPath(manePath, accentPaint);

    // Glowing Knight Eye
    final eyePaint = Paint()
      ..color = isWhite ? const Color(0xFF78350F) : const Color(0xFFFDE68A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.53, h * 0.32), w * 0.042, eyePaint);

    // Nostril
    final nostrilPaint = Paint()
      ..color = isWhite ? const Color(0xFF92400E) : const Color(0xFFB45309)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.70, h * 0.39), w * 0.026, nostrilPaint);

    // Mouth slit
    final mouthPath = Path()
      ..moveTo(w * 0.73, h * 0.44)
      ..lineTo(w * 0.65, h * 0.45);
    canvas.drawPath(mouthPath, accentPaint);
  }

  void _drawBishop(Canvas canvas, double w, double h, Paint fillPaint, Paint outlinePaint, Paint highlightPaint, Paint accentPaint, Paint goldAccent) {
    _drawBase(canvas, w, h, fillPaint, outlinePaint, highlightPaint, accentPaint);

    // Body
    final bodyPath = Path()
      ..moveTo(w * 0.34, h * 0.79)
      ..cubicTo(w * 0.38, h * 0.65, w * 0.40, h * 0.55, w * 0.36, h * 0.45)
      ..lineTo(w * 0.64, h * 0.45)
      ..cubicTo(w * 0.60, h * 0.55, w * 0.62, h * 0.65, w * 0.66, h * 0.79)
      ..close();
    canvas.drawPath(bodyPath, fillPaint);
    canvas.drawPath(bodyPath, outlinePaint);

    // Collar
    final collarRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.30, h * 0.41, w * 0.40, h * 0.055),
      Radius.circular(w * 0.025),
    );
    canvas.drawRRect(collarRect, fillPaint);
    canvas.drawRRect(collarRect, outlinePaint);

    // Mitre head
    final mitrePath = Path()
      ..moveTo(w * 0.30, h * 0.41)
      ..cubicTo(w * 0.23, h * 0.30, w * 0.33, h * 0.16, w * 0.50, h * 0.12)
      ..cubicTo(w * 0.67, h * 0.16, w * 0.77, h * 0.30, w * 0.70, h * 0.41)
      ..close();
    canvas.drawPath(mitrePath, fillPaint);
    canvas.drawPath(mitrePath, outlinePaint);

    // Mitre slit
    final slitPath = Path()
      ..moveTo(w * 0.40, h * 0.19)
      ..lineTo(w * 0.57, h * 0.33);
    canvas.drawPath(slitPath, accentPaint);

    // Top gold finial
    canvas.drawCircle(Offset(w * 0.50, h * 0.09), w * 0.048, goldAccent);
    canvas.drawCircle(Offset(w * 0.50, h * 0.09), w * 0.048, outlinePaint);
  }

  void _drawRook(Canvas canvas, double w, double h, Paint fillPaint, Paint outlinePaint, Paint highlightPaint, Paint accentPaint) {
    _drawBase(canvas, w, h, fillPaint, outlinePaint, highlightPaint, accentPaint);

    // Fortress Body
    final towerPath = Path()
      ..moveTo(w * 0.32, h * 0.79)
      ..lineTo(w * 0.36, h * 0.42)
      ..lineTo(w * 0.64, h * 0.42)
      ..lineTo(w * 0.68, h * 0.79)
      ..close();
    canvas.drawPath(towerPath, fillPaint);
    canvas.drawPath(towerPath, outlinePaint);

    // Upper Balcony
    final balconyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.25, h * 0.36, w * 0.50, h * 0.07),
      Radius.circular(w * 0.02),
    );
    canvas.drawRRect(balconyRect, fillPaint);
    canvas.drawRRect(balconyRect, outlinePaint);

    // Crenellations
    final crownPath = Path();
    crownPath.moveTo(w * 0.25, h * 0.36);
    crownPath.lineTo(w * 0.25, h * 0.18);
    crownPath.lineTo(w * 0.35, h * 0.18);
    crownPath.lineTo(w * 0.35, h * 0.26);
    crownPath.lineTo(w * 0.44, h * 0.26);
    crownPath.lineTo(w * 0.44, h * 0.18);
    crownPath.lineTo(w * 0.56, h * 0.18);
    crownPath.lineTo(w * 0.56, h * 0.26);
    crownPath.lineTo(w * 0.65, h * 0.26);
    crownPath.lineTo(w * 0.65, h * 0.18);
    crownPath.lineTo(w * 0.75, h * 0.18);
    crownPath.lineTo(w * 0.75, h * 0.36);
    crownPath.close();

    canvas.drawPath(crownPath, fillPaint);
    canvas.drawPath(crownPath, outlinePaint);

    // Arrow slit
    final arrowSlit = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.47, h * 0.52, w * 0.06, h * 0.15),
      Radius.circular(w * 0.02),
    );
    canvas.drawRRect(arrowSlit, accentPaint);
  }

  void _drawQueen(Canvas canvas, double w, double h, Paint fillPaint, Paint outlinePaint, Paint highlightPaint, Paint accentPaint, Paint goldAccent) {
    _drawBase(canvas, w, h, fillPaint, outlinePaint, highlightPaint, accentPaint);

    // Body
    final bodyPath = Path()
      ..moveTo(w * 0.33, h * 0.79)
      ..cubicTo(w * 0.39, h * 0.64, w * 0.41, h * 0.52, w * 0.37, h * 0.38)
      ..lineTo(w * 0.63, h * 0.38)
      ..cubicTo(w * 0.59, h * 0.52, w * 0.61, h * 0.64, w * 0.67, h * 0.79)
      ..close();
    canvas.drawPath(bodyPath, fillPaint);
    canvas.drawPath(bodyPath, outlinePaint);

    // Mid collar
    final collarRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.30, h * 0.35, w * 0.40, h * 0.05),
      Radius.circular(w * 0.02),
    );
    canvas.drawRRect(collarRect, fillPaint);
    canvas.drawRRect(collarRect, outlinePaint);

    // Queen tiara / crown (curved styling matching logo crown)
    final crownPath = Path();
    crownPath.moveTo(w * 0.26, h * 0.35);
    crownPath.lineTo(w * 0.18, h * 0.17);
    crownPath.lineTo(w * 0.33, h * 0.26);
    crownPath.lineTo(w * 0.39, h * 0.13);
    crownPath.lineTo(w * 0.46, h * 0.25);
    crownPath.lineTo(w * 0.50, h * 0.10);
    crownPath.lineTo(w * 0.54, h * 0.25);
    crownPath.lineTo(w * 0.61, h * 0.13);
    crownPath.lineTo(w * 0.67, h * 0.26);
    crownPath.lineTo(w * 0.82, h * 0.17);
    crownPath.lineTo(w * 0.74, h * 0.35);
    crownPath.close();

    canvas.drawPath(crownPath, fillPaint);
    canvas.drawPath(crownPath, outlinePaint);

    // Golden pearls
    final pearlRadius = w * 0.034;
    canvas.drawCircle(Offset(w * 0.18, h * 0.17), pearlRadius, goldAccent);
    canvas.drawCircle(Offset(w * 0.39, h * 0.13), pearlRadius, goldAccent);
    canvas.drawCircle(Offset(w * 0.50, h * 0.10), pearlRadius * 1.25, goldAccent);
    canvas.drawCircle(Offset(w * 0.61, h * 0.13), pearlRadius, goldAccent);
    canvas.drawCircle(Offset(w * 0.82, h * 0.17), pearlRadius, goldAccent);

    canvas.drawCircle(Offset(w * 0.18, h * 0.17), pearlRadius, outlinePaint);
    canvas.drawCircle(Offset(w * 0.39, h * 0.13), pearlRadius, outlinePaint);
    canvas.drawCircle(Offset(w * 0.50, h * 0.10), pearlRadius * 1.25, outlinePaint);
    canvas.drawCircle(Offset(w * 0.61, h * 0.13), pearlRadius, outlinePaint);
    canvas.drawCircle(Offset(w * 0.82, h * 0.17), pearlRadius, outlinePaint);
  }

  void _drawKing(Canvas canvas, double w, double h, Paint fillPaint, Paint outlinePaint, Paint highlightPaint, Paint accentPaint, Paint goldAccent) {
    _drawBase(canvas, w, h, fillPaint, outlinePaint, highlightPaint, accentPaint);

    // King Body (Grand Crown Structure directly echoing the crown in the logo)
    final bodyPath = Path()
      ..moveTo(w * 0.32, h * 0.79)
      ..cubicTo(w * 0.38, h * 0.62, w * 0.40, h * 0.50, w * 0.35, h * 0.36)
      ..lineTo(w * 0.65, h * 0.36)
      ..cubicTo(w * 0.60, h * 0.50, w * 0.62, h * 0.62, w * 0.68, h * 0.79)
      ..close();
    canvas.drawPath(bodyPath, fillPaint);
    canvas.drawPath(bodyPath, outlinePaint);

    // Collar
    final collarRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.28, h * 0.33, w * 0.44, h * 0.055),
      Radius.circular(w * 0.02),
    );
    canvas.drawRRect(collarRect, fillPaint);
    canvas.drawRRect(collarRect, outlinePaint);

    // Crown Dome with Gold Filigree
    final crownPath = Path();
    crownPath.moveTo(w * 0.26, h * 0.33);
    crownPath.cubicTo(w * 0.18, h * 0.20, w * 0.34, h * 0.15, w * 0.50, h * 0.17);
    crownPath.cubicTo(w * 0.66, h * 0.15, w * 0.82, h * 0.20, w * 0.74, h * 0.33);
    crownPath.close();

    canvas.drawPath(crownPath, fillPaint);
    canvas.drawPath(crownPath, outlinePaint);

    // Imperial Cross on top
    final crossVertical = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.47, h * 0.04, w * 0.06, h * 0.13),
      Radius.circular(w * 0.015),
    );
    final crossHorizontal = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.40, h * 0.07, w * 0.20, h * 0.055),
      Radius.circular(w * 0.015),
    );

    canvas.drawRRect(crossVertical, goldAccent);
    canvas.drawRRect(crossHorizontal, goldAccent);
    canvas.drawRRect(crossVertical, outlinePaint);
    canvas.drawRRect(crossHorizontal, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant ChessPiecePainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.color != color || oldDelegate.isCaptured != isCaptured;
  }
}
