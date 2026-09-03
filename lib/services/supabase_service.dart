import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:game_papan/models/game_enums.dart';
import 'package:game_papan/models/match_record.dart';
import 'package:game_papan/models/user_profile.dart';
import 'package:game_papan/services/supabase_config.dart';

class SupabaseService {
  static SupabaseClient? get client {
    if (!SupabaseConfig.isConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static bool get isReady => client != null && SupabaseConfig.isConfigured;

  /// Fetch user profile from Supabase profiles table
  static Future<UserProfile?> fetchProfile(String userId) async {
    if (!isReady) return null;
    try {
      final response = await client!
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return UserProfile(
        id: response['id'] as String,
        email: response['email'] as String? ?? '',
        displayName: response['display_name'] as String? ?? 'Player',
        photoUrl: response['avatar_url'] as String? ?? '',
        chessRating: response['chess_rating'] as int? ?? 1200,
        shogiRating: response['shogi_rating'] as int? ?? 1200,
        chessWins: response['chess_wins'] as int? ?? 0,
        chessLosses: response['chess_losses'] as int? ?? 0,
        chessDraws: response['chess_draws'] as int? ?? 0,
        shogiWins: response['shogi_wins'] as int? ?? 0,
        shogiLosses: response['shogi_losses'] as int? ?? 0,
        shogiDraws: response['shogi_draws'] as int? ?? 0,
        themeMode: response['theme_mode'] as String? ?? 'dark',
        languageCode: response['language_code'] as String? ?? 'id',
        soundEnabled: response['sound_enabled'] as bool? ?? true,
      );
    } catch (e) {
      debugPrint('SupabaseService.fetchProfile error: $e');
      return null;
    }
  }

  /// Upsert profile into Supabase (dengan verifikasi sesi auth & batasan integritas)
  static Future<bool> upsertProfile(UserProfile profile) async {
    if (!isReady) return false;

    final sessionUser = client?.auth.currentUser;
    // Jangan izinkan push ke cloud jika belum login atau ID tidak cocok dengan sesi aktif
    if (sessionUser == null || sessionUser.id != profile.id) {
      debugPrint('[SupabaseService] Upsert profile diblokir: sesi auth tidak cocok/tidak ada.');
      return false;
    }

    try {
      // Sanitasi nama tampilan (maksimal 30 karakter)
      final cleanDisplayName = profile.displayName.trim().isEmpty
          ? 'Player'
          : (profile.displayName.trim().length > 30
              ? profile.displayName.trim().substring(0, 30)
              : profile.displayName.trim());

      // Batasi rating ke rentang 100 s/d 3500
      final clampedChessRating = profile.chessRating.clamp(100, 3500);
      final clampedShogiRating = profile.shogiRating.clamp(100, 3500);

      await client!.from('profiles').upsert({
        'id': profile.id,
        'email': profile.email.trim(),
        'display_name': cleanDisplayName,
        'avatar_url': profile.photoUrl,
        'chess_rating': clampedChessRating,
        'shogi_rating': clampedShogiRating,
        'chess_wins': profile.chessWins.clamp(0, 999999),
        'chess_losses': profile.chessLosses.clamp(0, 999999),
        'chess_draws': profile.chessDraws.clamp(0, 999999),
        'shogi_wins': profile.shogiWins.clamp(0, 999999),
        'shogi_losses': profile.shogiLosses.clamp(0, 999999),
        'shogi_draws': profile.shogiDraws.clamp(0, 999999),
        'theme_mode': profile.themeMode,
        'language_code': profile.languageCode,
        'sound_enabled': profile.soundEnabled,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('SupabaseService.upsertProfile error: $e');
      return false;
    }
  }

  /// Upload match records batch to Supabase (dengan verifikasi sesi & batasan delta rating)
  static Future<bool> insertMatchRecords({
    required String userId,
    required List<MatchRecord> records,
  }) async {
    if (!isReady || records.isEmpty) return false;

    final sessionUser = client?.auth.currentUser;
    if (sessionUser == null || sessionUser.id != userId) {
      debugPrint('[SupabaseService] Insert match records diblokir: sesi auth tidak cocok/tidak ada.');
      return false;
    }

    try {
      final rows = records.map((m) => {
        'id': m.id,
        'user_id': userId,
        'game_type': m.gameType.name,
        'game_mode': m.gameMode.name,
        'coach_level': m.coachLevel?.name,
        'outcome': m.outcome.name,
        'opponent_name': m.opponentName.trim().length > 40
            ? m.opponentName.trim().substring(0, 40)
            : m.opponentName.trim(),
        'opponent_rating': m.opponentRating.clamp(100, 3500),
        'rating_change': m.ratingChange.clamp(-100, 100),
        'total_moves': m.totalMoves.clamp(0, 5000),
        'accuracy': m.accuracy?.clamp(0.0, 100.0),
        'analysis_summary': m.analysisSummary,
        'played_at': m.timestamp.toIso8601String(),
      }).toList();

      await client!.from('match_history').upsert(rows);
      return true;
    } catch (e) {
      debugPrint('SupabaseService.insertMatchRecords error: $e');
      return false;
    }
  }

  /// Fetch match history from Supabase
  static Future<List<MatchRecord>> fetchMatchHistory(String userId) async {
    if (!isReady) return [];
    try {
      final response = await client!
          .from('match_history')
          .select()
          .eq('user_id', userId)
          .order('played_at', ascending: false)
          .limit(100);

      final list = <MatchRecord>[];
      for (final item in response as List<dynamic>) {
        final map = item as Map<String, dynamic>;
        list.add(MatchRecord(
          id: map['id'] as String,
          gameType: GameType.values.byName(map['game_type'] as String),
          gameMode: GameMode.values.byName(map['game_mode'] as String),
          coachLevel: map['coach_level'] != null
              ? CoachLevel.values.byName(map['coach_level'] as String)
              : null,
          outcome: MatchOutcome.values.byName(map['outcome'] as String),
          opponentRating: map['opponent_rating'] as int? ?? 1200,
          opponentName: map['opponent_name'] as String? ?? 'Opponent',
          ratingChange: map['rating_change'] as int? ?? 0,
          timestamp: DateTime.parse(map['played_at'] as String),
          totalMoves: map['total_moves'] as int? ?? 0,
          accuracy: (map['accuracy'] as num?)?.toDouble(),
          analysisSummary: map['analysis_summary'] as Map<String, dynamic>?,
          isSynced: true,
        ));
      }
      return list;
    } catch (e) {
      debugPrint('SupabaseService.fetchMatchHistory error: $e');
      return [];
    }
  }

  /// Fetch global leaderboard from Supabase
  static Future<List<Map<String, dynamic>>?> fetchGlobalLeaderboard({
    required GameType gameType,
    int limit = 50,
  }) async {
    if (!isReady) return null;
    try {
      final ratingColumn = gameType == GameType.chess ? 'chess_rating' : 'shogi_rating';
      final winsColumn = gameType == GameType.chess ? 'chess_wins' : 'shogi_wins';
      final lossesColumn = gameType == GameType.chess ? 'chess_losses' : 'shogi_losses';

      final response = await client!
          .from('profiles')
          .select('id, display_name, avatar_url, $ratingColumn, $winsColumn, $lossesColumn')
          .order(ratingColumn, ascending: false)
          .limit(limit);

      final results = <Map<String, dynamic>>[];
      for (final r in response as List<dynamic>) {
        final row = r as Map<String, dynamic>;
        results.add({
          'id': row['id'],
          'name': row['display_name'] ?? 'Player',
          'rating': row[ratingColumn] ?? 1200,
          'wins': row[winsColumn] ?? 0,
          'losses': row[lossesColumn] ?? 0,
          'avatar': row['avatar_url'] ?? '',
        });
      }
      return results;
    } catch (e) {
      debugPrint('SupabaseService.fetchGlobalLeaderboard error: $e');
      return null;
    }
  }
}

class OfflineSyncManager {
  static const String _offlineQueueKey = 'app_offline_matches_queue';
  static StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  static bool _isSyncing = false;

  /// Inisialisasi pendengar konektivitas untuk auto-sync saat online
  static void init({required Function() onSyncCompleted}) {
    _connectivitySub?.cancel();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final isConnected = results.any((r) => r != ConnectivityResult.none);
      if (isConnected) {
        debugPrint('[OfflineSyncManager] Internet terdeteksi online! Memulai sinkronisasi otomatis...');
        syncPendingData(onSuccess: onSyncCompleted);
      }
    });
  }

  static void dispose() {
    _connectivitySub?.cancel();
  }

  /// Simpan match record yang belum disinkronkan ke queue lokal
  static Future<void> queueMatch(MatchRecord match) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_offlineQueueKey);
      List<dynamic> list = raw != null ? jsonDecode(raw) : [];
      list.add(match.toJson());
      await prefs.setString(_offlineQueueKey, jsonEncode(list));
      debugPrint('[OfflineSyncManager] Match disimpan ke antrean lokal (${list.length} antrean).');
    } catch (e) {
      debugPrint('Error queueing offline match: $e');
    }
  }

  /// Dapatkan semua antrean match lokal
  static Future<List<MatchRecord>> getQueuedMatches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_offlineQueueKey);
      if (raw == null) return [];
      final List<dynamic> list = jsonDecode(raw);
      return list.map((e) => MatchRecord.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error getting queued matches: $e');
      return [];
    }
  }

  /// Sinkronkan antrean lokal ke Supabase
  static Future<bool> syncPendingData({Function()? onSuccess}) async {
    if (_isSyncing) return false;
    if (!SupabaseService.isReady) return false;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    _isSyncing = true;
    try {
      final queued = await getQueuedMatches();
      if (queued.isEmpty) {
        _isSyncing = false;
        return true;
      }

      debugPrint('[OfflineSyncManager] Menyinkronkan ${queued.length} match ke Supabase...');
      final success = await SupabaseService.insertMatchRecords(
        userId: user.id,
        records: queued,
      );

      if (success) {
        // Hapus queue lokal yang sudah berhasil dikirim
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_offlineQueueKey);
        debugPrint('[OfflineSyncManager] Sinkronisasi ${queued.length} match selesai!');
        if (onSuccess != null) onSuccess();
        _isSyncing = false;
        return true;
      }
    } catch (e) {
      debugPrint('[OfflineSyncManager] Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
    return false;
  }
}
