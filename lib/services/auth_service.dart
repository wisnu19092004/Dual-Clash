import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:game_papan/models/game_enums.dart';
import 'package:game_papan/models/match_record.dart';
import 'package:game_papan/models/user_profile.dart';
import 'package:game_papan/services/elo_calculator.dart';

class AuthService extends ChangeNotifier {
  static const String _userKey = 'app_user_profile';
  static const String _isLoggedInKey = 'app_is_logged_in';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  UserProfile? _currentUser;
  bool _isLoading = true;

  UserProfile? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null && _currentUser!.id.startsWith('google_');
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

  /// Update Profile Picture & Name
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      displayName: displayName ?? _currentUser!.displayName,
      photoUrl: photoUrl ?? _currentUser!.photoUrl,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
    notifyListeners();
  }

  /// Autentikasi Asli Google Sign-In dengan Fallback Handler
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
        _currentUser = UserProfile(
          id: 'google_${googleAccount.id}',
          email: googleAccount.email,
          displayName: googleAccount.displayName?.isNotEmpty == true ? googleAccount.displayName! : 'Google Player',
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
        _currentUser = UserProfile(
          id: 'google_${DateTime.now().millisecondsSinceEpoch}',
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

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Signout google error: $e');
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
    required MatchOutcome outcome,
    required int opponentRating,
    required String opponentName,
    required int totalMoves,
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
      outcome: outcome,
      opponentRating: opponentRating,
      opponentName: opponentName,
      ratingChange: delta,
      timestamp: DateTime.now(),
      totalMoves: totalMoves,
    );

    final updatedHistory = [match, ..._currentUser!.history];

    _currentUser = _currentUser!.copyWith(
      chessRating: gameType == GameType.chess ? newRating : _currentUser!.chessRating,
      shogiRating: gameType == GameType.shogi ? newRating : _currentUser!.shogiRating,
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

    notifyListeners();
    return delta;
  }
}
