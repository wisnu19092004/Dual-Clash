import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:game_papan/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:game_papan/services/language_provider.dart';
import 'package:game_papan/widgets/interactive_button.dart';
import 'package:game_papan/widgets/auth_dialog.dart';
import 'package:game_papan/theme/app_colors.dart';

class GoogleAuthBanner extends StatelessWidget {
  final AuthService auth;

  const GoogleAuthBanner({super.key, required this.auth});

  void _showAuthDialog(BuildContext context, {bool isRegister = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AuthDialog(auth: auth, initialIsRegister: isRegister),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.2
                  : 0.05,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'G',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.tr('save_progress'),
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textColor(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lang.tr('sync_progress'),
                  style: TextStyle(
                    color: AppColors.textSecondaryColor(context),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          InteractiveButton(
            onPressed: () => _showAuthDialog(context, isRegister: false),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            backgroundColor: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
            child: Text(
              lang.tr('login_register'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
