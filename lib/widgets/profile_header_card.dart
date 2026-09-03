import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:game_papan/models/user_profile.dart';
import 'package:game_papan/services/auth_service.dart';
import 'package:game_papan/services/language_provider.dart';
import 'package:game_papan/widgets/interactive_button.dart';
import 'package:game_papan/widgets/confirm_dialog.dart';
import 'package:game_papan/widgets/edit_avatar_dialog.dart';
import 'package:game_papan/widgets/auth_dialog.dart';
import 'package:game_papan/theme/app_colors.dart';

class ProfileHeaderCard extends StatelessWidget {
  final UserProfile user;
  final AuthService auth;

  const ProfileHeaderCard({super.key, required this.user, required this.auth});

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => EditAvatarDialog(user: user, auth: auth),
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

  void _showAuthDialog(BuildContext context, {bool isRegister = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AuthDialog(auth: auth, initialIsRegister: isRegister),
    );
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => ConfirmDialog(
        title: 'Keluar dari Akun?',
        message: 'Apakah Anda yakin ingin keluar dari akun ini? Rating Anda tetap tersimpan di akun.',
        confirmText: 'Keluar Akun',
        cancelText: 'Batal',
        confirmColor: Colors.redAccent,
        icon: Icons.logout_rounded,
        onConfirm: () async {
          await auth.signOut();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Berhasil keluar dari akun.')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final isLoggedIn = auth.isLoggedIn;
    final isGoogleUser = user.id.startsWith('google_');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with Camera Edit Icon Overlay
          Stack(
            children: [
              GestureDetector(
                onTap: () => _showEditProfileDialog(context),
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primary,
                  child: user.photoUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(44),
                          child: Image(
                            image: _avatarImage(user.photoUrl)!,
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.person,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.person, size: 48, color: Colors.white),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showEditProfileDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.surface(context),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.displayName,
                style: GoogleFonts.outfit(
                  color: AppColors.textColor(context),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _showEditProfileDialog(context),
                child: Icon(
                  Icons.edit,
                  size: 16,
                  color: AppColors.textSecondaryColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isGoogleUser ? Icons.verified : Icons.account_circle,
                color: isGoogleUser ? Colors.blueAccent : Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                user.email,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondaryColor(context),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!isLoggedIn)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InteractiveButton(
                  onPressed: () => _showAuthDialog(context, isRegister: false),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.login_rounded, size: 16, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        lang.tr('login'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                InteractiveButton(
                  onPressed: () => _showAuthDialog(context, isRegister: true),
                  backgroundColor: Colors.transparent,
                  border: Border.all(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_add_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        lang.tr('register'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            InteractiveButton(
              onPressed: () => _showLogoutConfirmDialog(context),
              backgroundColor: Colors.transparent,
              border: Border.all(
                color: Colors.redAccent.withValues(alpha: 0.6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              borderRadius: BorderRadius.circular(10),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout, size: 16, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text(
                    'Keluar Akun',
                    style: TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
