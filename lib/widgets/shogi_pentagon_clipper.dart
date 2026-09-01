import 'package:flutter/material.dart';

class ShogiPentagonClipper extends CustomClipper<Path> {
  final double topTaper;

  ShogiPentagonClipper({this.topTaper = 0.28});

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Authentic traditional Japanese Shogi Komagata 5-sided polygon with balanced shoulders
    path.moveTo(w * 0.5, 0); // Top vertex
    path.lineTo(w * 0.94, h * topTaper); // Top right shoulder
    path.lineTo(w * 0.88, h * 0.96); // Bottom right base corner
    path.lineTo(w * 0.12, h * 0.96); // Bottom left base corner
    path.lineTo(w * 0.06, h * topTaper); // Top left shoulder
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant ShogiPentagonClipper oldClipper) =>
      oldClipper.topTaper != topTaper;
}

class ShogiPentagonPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double topTaper;

  ShogiPentagonPainter({
    this.borderColor = const Color(0xFF6E3609),
    this.borderWidth = 1.6,
    this.topTaper = 0.28,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Outer Carved Bevel Rim
    final outerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(w * 0.5, 0);
    path.lineTo(w * 0.95, h * topTaper);
    path.lineTo(w * 0.88, h * 0.98);
    path.lineTo(w * 0.12, h * 0.98);
    path.lineTo(w * 0.05, h * topTaper);
    path.close();

    canvas.drawPath(path, outerPaint);

    // Inner Highlight Contour (Gives 3D wood bevel like the Shogi piece on the logo)
    final innerPaint = Paint()
      ..color = const Color(0xFFFFFBEB).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeJoin = StrokeJoin.round;

    final innerPath = Path();
    innerPath.moveTo(w * 0.5, h * 0.07);
    innerPath.lineTo(w * 0.88, h * (topTaper + 0.02));
    innerPath.lineTo(w * 0.83, h * 0.90);
    innerPath.lineTo(w * 0.17, h * 0.90);
    innerPath.lineTo(w * 0.12, h * (topTaper + 0.02));
    innerPath.close();

    canvas.drawPath(innerPath, innerPaint);
  }

  @override
  bool shouldRepaint(covariant ShogiPentagonPainter oldDelegate) =>
      oldDelegate.borderColor != borderColor ||
      oldDelegate.borderWidth != borderWidth ||
      oldDelegate.topTaper != topTaper;
}
