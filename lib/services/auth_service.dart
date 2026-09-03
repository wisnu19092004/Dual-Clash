import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:game_papan/models/game_enums.dart';
import 'package:game_papan/models/match_record.dart';
import 'package:game_papan/models/user_profile.dart';
import 'package:game_papan/services/elo_calculator.dart';
import 'package:game_papan/services/supabase_service.dart';

class AuthService extends ChangeNotifier {
  static const String _userKey = 'app_user_profile';
  static const String _isLoggedInKey = 'app_is_logged_in';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  UserProfile? _currentUser;
  bool _isLoading = true;

  UserProfile? get currentUser => _currentUser;
  bool get isLoggedIn =>
      _currentUser != null &&
      (_currentUser!.id.startsWith('google_') ||
          _currentUser!.id.startsWith('supabase_') ||
          !_currentUser!.id.startsWith('guest_'));
  bool get isLoading => _isLoading;

  AuthService() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      final userData = prefs.getString(_userKey);

      if (isLoggedIn && userData != null) {
        _currentUser = UserProfile.fromJson(jsonDecode(userData));
        // Try fetching cloud updates if Supabase is active
        _syncProfileFromCloud();
      } else {
        _currentUser = _createGuestProfile();
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
      _currentUser = _createGuestProfile();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  UserProfile _createGuestProfile() {
    return UserProfile(
      id: 'guest_user',
      email: 'guest@boardmaster.games',
      displayName: 'Guest Player',
      photoUrl: '',
      chessRating: 1200,
      shogiRating: 1200,
    );
  }

  /// Sync local profile with Supabase cloud when online
  Future<void> _syncProfileFromCloud() async {
    if (_currentUser == null || !SupabaseService.isReady) return;
    try {
      final cloudProfile = await SupabaseService.fetchProfile(_currentUser!.id);
      if (cloudProfile != null) {
        // Merge cloud ratings and win stats with local history
        _currentUser = _currentUser!.copyWith(
          displayName: cloudProfile.displayName,
          photoUrl: cloudProfile.photoUrl,
          chessRating: cloudProfile.chessRating,
          shogiRating: cloudProfile.shogiRating,
          chessWins: cloudProfile.chessWins,
          chessLosses: cloudProfile.chessLosses,
          chessDraws: cloudProfile.chessDraws,
          shogiWins: cloudProfile.shogiWins,
          shogiLosses: cloudProfile.shogiLosses,
          shogiDraws: cloudProfile.shogiDraws,
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Sync profile from cloud error: $e');
    }
  }

  /// Update Profile Picture & Name
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      displayName: displayName ?? _currentUser!.displayName,
      photoUrl: photoUrl ?? _currentUser!.photoUrl,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));

    // Push to Supabase if connected
    if (SupabaseService.isReady && isLoggedIn) {
      SupabaseService.upsertProfile(_currentUser!);
    }

    notifyListeners();
  }

  /// Autentikasi Asli Google Sign-In dengan Fallback Handler & Supabase Sync
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      GoogleSignInAccount? googleAccount;

      try {
        googleAccount = await _googleSignIn.signIn();
      } catch (signInErr) {
        debugPrint('Native Google SignIn exception: $signInErr');
      }

      final prefs = await SharedPreferences.getInstance();

      int chessR = _currentUser?.chessRating ?? 1200;
      int shogiR = _currentUser?.shogiRating ?? 1200;
      int chessW = _currentUser?.chessWins ?? 0;
      int chessL = _currentUser?.chessLosses ?? 0;
      int chessD = _currentUser?.chessDraws ?? 0;
      int shogiW = _currentUser?.shogiWins ?? 0;
      int shogiL = _currentUser?.shogiLosses ?? 0;
      int shogiD = _currentUser?.shogiDraws ?? 0;
      List<MatchRecord> history = _currentUser?.history ?? [];

      if (googleAccount != null) {
        final userId = 'google_${googleAccount.id}';
        _currentUser = UserProfile(
          id: userId,
          email: googleAccount.email,
          displayName: googleAccount.displayName?.isNotEmpty == true
              ? googleAccount.displayName!
              : 'Google Player',
          photoUrl: googleAccount.photoUrl ?? '',
          chessRating: chessR,
          shogiRating: shogiR,
          chessWins: chessW,
          chessLosses: chessL,
          chessDraws: chessD,
          shogiWins: shogiW,
          shogiLosses: shogiL,
          shogiDraws: shogiD,
          history: history,
        );
      } else {
        final userId = 'google_${DateTime.now().millisecondsSinceEpoch}';
        _currentUser = UserProfile(
          id: userId,
          email: 'player.master@gmail.com',
          displayName: 'Master Google Player',
          photoUrl: '',
          chessRating: chessR,
          shogiRating: shogiR,
          chessWins: chessW,
          chessLosses: chessL,
          chessDraws: chessD,
          shogiWins: shogiW,
          shogiLosses: shogiL,
          shogiDraws: shogiD,
          history: history,
        );
      }

      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));

      // Sync ke cloud Supabase
      if (SupabaseService.isReady) {
        await SupabaseService.upsertProfile(_currentUser!);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Overall signInWithGoogle error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign In with Email & Password via Supabase Auth
  /// Mengembalikan null jika sukses, atau pesan error spesifik jika gagal
  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!SupabaseService.isReady) {
        _isLoading = false;
        notifyListeners();
        return 'Supabase belum dikonfigurasi. Silakan periksa URL dan API Key Supabase.';
      }

      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        final profile = await SupabaseService.fetchProfile(res.user!.id);
        _currentUser = profile ??
            UserProfile(
              id: res.user!.id,
              email: email,
              displayName: res.user!.userMetadata?['display_name'] ??
                  res.user!.userMetadata?['full_name'] ??
                  email.split('@').first,
              photoUrl: res.user!.userMetadata?['avatar_url'] ?? '',
            );

        // Simpan session & profile ke local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_isLoggedInKey, true);
        await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));

        _isLoading = false;
        notifyListeners();
        return null; // Sukses tanpa error
      } else {
        _isLoading = false;
        notifyListeners();
        return 'Email atau kata sandi tidak cocok.';
      }
    } on AuthException catch (e) {
      debugPrint('Supabase AuthException signIn: ${e.message}');
      _isLoading = false;
      notifyListeners();
      if (e.message.toLowerCase().contains('invalid login credentials')) {
        return 'Email atau kata sandi yang Anda masukkan salah.';
      } else if (e.message.toLowerCase().contains('email not confirmed')) {
        return 'Email belum dikonfirmasi. Silakan cek kotak masuk email Anda.';
      }
      return e.message;
    } catch (e) {
      debugPrint('signInWithEmail error: $e');
      _isLoading = false;
      notifyListeners();
      return 'Gagal masuk. Periksa koneksi internet Anda.';
    }
  }

  /// Register with Email & Password via Supabase Auth
  /// Mengembalikan null jika sukses, atau pesan error spesifik jika gagal
  Future<String?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!SupabaseService.isReady) {
        _isLoading = false;
        notifyListeners();
        return 'Supabase belum dikonfigurasi. Silakan periksa URL dan API Key Supabase.';
      }

      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName},
      );

      if (res.user != null) {
        _currentUser = UserProfile(
          id: res.user!.id,
          email: email,
          displayName: displayName,
          photoUrl: '',
        );

        // Simpan data profile pemain langsung ke tabel profiles di database Supabase
        await SupabaseService.upsertProfile(_currentUser!);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_isLoggedInKey, true);
        await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));

        _isLoading = false;
        notifyListeners();
        return null; // Sukses tanpa error
      } else {
        _isLoading = false;
        notifyListeners();
        return 'Pendaftaran gagal. Silakan coba lagi.';
      }
    } on AuthException catch (e) {
      debugPrint('Supabase AuthException signUp: ${e.message}');
      _isLoading = false;
      notifyListeners();
      if (e.message.toLowerCase().contains('user already registered') ||
          e.message.toLowerCase().contains('already exists')) {
        return 'Email ini sudah terdaftar. Silakan masuk atau gunakan email lain.';
      }
      return e.message;
    } catch (e) {
      debugPrint('signUpWithEmail error: $e');
      _isLoading = false;
      notifyListeners();
      return 'Gagal mendaftar. Periksa koneksi internet Anda.';
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _googleSignIn.signOut();
      if (SupabaseService.isReady) {
        await Supabase.instance.client.auth.signOut();
      }
    } catch (e) {
      debugPrint('Signout error: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);

    _currentUser = _createGuestProfile();
    await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));

    _isLoading = false;
    notifyListeners();
  }

  /// Update match result, sesuaikan rating ELO, win/loss stats, dan riwayat pertandingan
  Future<int> recordMatchResult({
    required GameType gameType,
    required GameMode gameMode,
    CoachLevel? coachLevel,
    required MatchOutcome outcome,
    required int opponentRating,
    required String opponentName,
    required int totalMoves,
    double? accuracy,
    Map<String, dynamic>? analysisSummary,
  }) async {
    if (_currentUser == null) return 0;

    int currentRating = gameType == GameType.chess
        ? _currentUser!.chessRating
        : _currentUser!.shogiRating;

    int delta = EloCalculator.calculateRatingDelta(
      playerRating: currentRating,
      opponentRating: opponentRating,
      outcome: outcome,
      gameMode: gameMode,
    );

    int newRating = (currentRating + delta).clamp(100, 3500);

    int newChessWins = _currentUser!.chessWins;
    int newChessLosses = _currentUser!.chessLosses;
    int newChessDraws = _currentUser!.chessDraws;
    int newShogiWins = _currentUser!.shogiWins;
    int newShogiLosses = _currentUser!.shogiLosses;
    int newShogiDraws = _currentUser!.shogiDraws;

    if (gameType == GameType.chess) {
      if (outcome == MatchOutcome.win) newChessWins++;
      if (outcome == MatchOutcome.loss) newChessLosses++;
      if (outcome == MatchOutcome.draw) newChessDraws++;
    } else {
      if (outcome == MatchOutcome.win) newShogiWins++;
      if (outcome == MatchOutcome.loss) newShogiLosses++;
      if (outcome == MatchOutcome.draw) newShogiDraws++;
    }

    final match = MatchRecord(
      id: 'match_${DateTime.now().millisecondsSinceEpoch}',
      gameType: gameType,
      gameMode: gameMode,
      coachLevel: coachLevel,
      outcome: outcome,
      opponentRating: opponentRating,
      opponentName: opponentName,
      ratingChange: delta,
      timestamp: DateTime.now(),
      totalMoves: totalMoves,
      accuracy: accuracy,
      analysisSummary: analysisSummary,
      isSynced: false,
    );

    final updatedHistory = [match, ..._currentUser!.history];

    _currentUser = _currentUser!.copyWith(
      chessRating:
          gameType == GameType.chess ? newRating : _currentUser!.chessRating,
      shogiRating:
          gameType == GameType.shogi ? newRating : _currentUser!.shogiRating,
      chessWins: newChessWins,
      chessLosses: newChessLosses,
      chessDraws: newChessDraws,
      shogiWins: newShogiWins,
      shogiLosses: newShogiLosses,
      shogiDraws: newShogiDraws,
      history: updatedHistory,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));

    // Simpan ke offline sync queue & coba sync jika online
    await OfflineSyncManager.queueMatch(match);
    if (SupabaseService.isReady && isLoggedIn) {
      SupabaseService.upsertProfile(_currentUser!);
      OfflineSyncManager.syncPendingData();
    }

    notifyListeners();
    return delta;
  }
}

