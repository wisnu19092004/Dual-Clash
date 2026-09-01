import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:game_papan/models/user_profile.dart';
import 'package:game_papan/theme/app_colors.dart';

class HomeTopBar extends StatelessWidget {
  final UserProfile? user;

  const HomeTopBar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isNarrow = screenWidth < 360;

        return Row(
          children: [
            // Brand Title with Logo emblem
            Container(
              width: isNarrow ? 40 : 46,
              height: isNarrow ? 40 : 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFE2A862),
                    Color(0xFF965B27),
                    Color(0xFF5D3111),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD97706).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(color: const Color(0xFFFDE68A), width: 1.8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'lib/aset/Logo.jpeg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.shield, color: Color(0xFFFDE68A)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'CHESS',
                        style: GoogleFonts.cinzel(
                          color: const Color(0xFFF59E0B),
                          fontSize: isNarrow ? 10.5 : 11.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        ' X ',
                        style: GoogleFonts.cinzel(
                          color: AppColors.textMutedColor(context),
                          fontSize: isNarrow ? 8.5 : 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'SHOGI',
                        style: GoogleFonts.cinzel(
                          color: const Color(0xFFEA580C),
                          fontSize: isNarrow ? 10.5 : 11.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'DUAL CLASH',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cinzel(
                      color: AppColors.textColor(context),
                      fontSize: isNarrow ? 15 : 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
