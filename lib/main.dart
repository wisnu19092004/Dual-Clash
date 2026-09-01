import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:game_papan/screens/home_screen.dart';
import 'package:game_papan/services/auth_service.dart';
import 'package:game_papan/services/language_provider.dart';
import 'package:game_papan/services/sound_effects.dart';
import 'package:game_papan/theme/app_theme.dart';
import 'package:game_papan/theme/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SoundEffects.init();
  runApp(const BoardMasterApp());
}

class BoardMasterApp extends StatelessWidget {
  const BoardMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, _) {
          return MaterialApp(
            title: languageProvider.tr('app_title'),
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            locale: languageProvider.currentLocale,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
