import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:game_papan/widgets/game_emblem_icon.dart';
import 'package:game_papan/widgets/interactive_button.dart';
import 'package:game_papan/services/language_provider.dart';
import 'package:provider/provider.dart';

class GameCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;
  final List<Color> gradient;
  final bool isChess;
  final String piecesPreview;
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.gradient,
    required this.isChess,
    required this.piecesPreview,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return InteractiveButton(
      onPressed: onTap,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(22),
      gradient: LinearGradient(
        colors: gradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(
        color: const Color(0xFFFBBF24).withValues(alpha: 0.25),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: gradient.last.withValues(alpha: 0.22),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4.5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFFDE68A),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Container(
                width: 38,
                height: 38,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: GameEmblemIcon(isChess: isChess, size: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.cinzel(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFF3ECE4),
              fontSize: 12.5,
              height: 1.45,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  piecesPreview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFFDE68A),
                    fontSize: 15,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFBEB), Color(0xFFFDE68A)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lang.tr('play_now'),
                      style: GoogleFonts.cinzel(
                        color: const Color(0xFF5C3317),
                        fontWeight: FontWeight.w900,
                        fontSize: 10.5,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFF5C3317),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
