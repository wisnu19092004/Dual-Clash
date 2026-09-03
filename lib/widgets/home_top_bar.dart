import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:game_papan/models/user_profile.dart';
import 'package:game_papan/services/auth_service.dart';
import 'package:game_papan/services/language_provider.dart';
import 'package:game_papan/widgets/auth_dialog.dart';
import 'package:game_papan/widgets/edit_avatar_dialog.dart';
import 'package:game_papan/widgets/interactive_button.dart';
import 'package:game_papan/theme/app_colors.dart';

class HomeTopBar extends StatelessWidget {
  final UserProfile? user;

  const HomeTopBar({super.key, required this.user});

  void _showAuthDialog(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => AuthDialog(auth: auth, initialIsRegister: false),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    if (user == null) return;
    final auth = Provider.of<AuthService>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => EditAvatarDialog(user: user!, auth: auth),
    );
  }

  ImageProvider? _avatarImage(String source) {
    if (source.startsWith('data:')) {
      final commaIndex = source.indexOf(',');
      if (commaIndex != -1) {
        return MemoryImage(base64Decode(source.substring(commaIndex + 1)));
      }
    }
    if (source.startsWith('http')) return NetworkImage(source);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final isLoggedIn = user != null &&
        (user!.id.startsWith('google_') ||
            user!.id.startsWith('supabase_') ||
            !user!.id.startsWith('guest_'));

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isNarrow = screenWidth < 360;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Brand Logo Emblem
            Container(
              width: isNarrow ? 36 : 42,
              height: isNarrow ? 36 : 42,
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
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
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
            const SizedBox(width: 8),

            // Game Brand Titles
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'CHESS',
                        style: GoogleFonts.cinzel(
                          color: const Color(0xFFF59E0B),
                          fontSize: isNarrow ? 9.5 : 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        ' X ',
                        style: GoogleFonts.cinzel(
                          color: AppColors.textMutedColor(context),
                          fontSize: isNarrow ? 7.5 : 8.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'SHOGI',
                        style: GoogleFonts.cinzel(
                          color: const Color(0xFFEA580C),
                          fontSize: isNarrow ? 9.5 : 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
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
                      fontSize: isNarrow ? 13.5 : 15.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),

            // Login Button OR Profile Avatar with Username underneath
            if (!isLoggedIn)
              InteractiveButton(
                onPressed: () => _showAuthDialog(context),
                padding: EdgeInsets.symmetric(
                  horizontal: isNarrow ? 10 : 12,
                  vertical: 6,
                ),
                backgroundColor: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.login_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      lang.tr('login'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isNarrow ? 10.5 : 11.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            else
              GestureDetector(
                onTap: () => _showEditProfileDialog(context),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isNarrow ? 85 : 105,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.borderColor(context),
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Circular Profile Avatar
                      CircleAvatar(
                        radius: isNarrow ? 14 : 16,
                        backgroundColor: AppColors.primary,
                        child: user?.photoUrl.isNotEmpty == true
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image(
                                  image: _avatarImage(user!.photoUrl)!,
                                  width: isNarrow ? 28 : 32,
                                  height: isNarrow ? 28 : 32,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.white,
                              ),
                      ),
                      const SizedBox(height: 2),
                      // Account Name underneath
                      Text(
                        user?.displayName ?? 'Player',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: isNarrow ? 9.5 : 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}


