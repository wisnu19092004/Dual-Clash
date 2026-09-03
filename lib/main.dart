import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:game_papan/screens/home_screen.dart';
import 'package:game_papan/services/ad_service.dart';
import 'package:game_papan/services/auth_service.dart';
import 'package:game_papan/services/language_provider.dart';
import 'package:game_papan/services/sound_effects.dart';
import 'package:game_papan/services/supabase_config.dart';
import 'package:game_papan/services/supabase_service.dart';
import 'package:game_papan/theme/app_theme.dart';
import 'package:game_papan/theme/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  SoundEffects.init();
  await AdService.initialize();

  // Inisialisasi Supabase jika konfigurasi telah diatur
  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        publishableKey: SupabaseConfig.supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('Supabase initialization failed: $e');
    }
  }

  runApp(const BoardMasterApp());
}

class BoardMasterApp extends StatefulWidget {
  const BoardMasterApp({super.key});

  @override
  State<BoardMasterApp> createState() => _BoardMasterAppState();
}

class _BoardMasterAppState extends State<BoardMasterApp> {
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    // Inisialisasi auto-sync saat koneksi kembali online
    OfflineSyncManager.init(
      onSyncCompleted: () {
        debugPrint('[App] Background offline sync sukses diselesaikan.');
      },
    );
  }

  @override
  void dispose() {
    OfflineSyncManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authService),
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

