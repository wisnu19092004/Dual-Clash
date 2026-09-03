import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:game_papan/models/game_enums.dart';
import 'package:game_papan/services/supabase_service.dart';

enum RoomStatus { waiting, ready, playing, finished, cancelled }

class OnlineRoomInfo {
  final String roomCode;
  final GameType gameType;
  final String hostId;
  final String hostName;
  final int hostRating;
  final String? guestId;
  final String? guestName;
  final int? guestRating;
  final int durationMinutes;
  final bool isHostWhiteOrSente;

  OnlineRoomInfo({
    required this.roomCode,
    required this.gameType,
    required this.hostId,
    required this.hostName,
    required this.hostRating,
    this.guestId,
    this.guestName,
    this.guestRating,
    required this.durationMinutes,
    required this.isHostWhiteOrSente,
  });
}

class OnlineMultiplayerService {
  static RealtimeChannel? _channel;
  static StreamController<Map<String, dynamic>>? _gameEventController;

  static Stream<Map<String, dynamic>> get onGameEvent {
    _gameEventController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _gameEventController!.stream;
  }

  /// Generate an alphanumeric room code with high entropy (e.g. DC-K7X9)
  static String generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Tanpa karakter membingungkan (I, O, 0, 1)
    final rand = Random.secure();
    final buffer = StringBuffer('DC-');
    for (int i = 0; i < 4; i++) {
      buffer.write(chars[rand.nextInt(chars.length)]);
    }
    return buffer.toString();
  }

  /// Create and subscribe to a room
  static Future<bool> createRoom({
    required String roomCode,
    required GameType gameType,
    required String hostId,
    required String hostName,
    required int hostRating,
    required int durationMinutes,
    required bool isHostWhiteOrSente,
    required Function(OnlineRoomInfo roomInfo) onGuestJoined,
    required Function(Map<String, dynamic> moveData) onMoveReceived,
    required Function() onOpponentResigned,
  }) async {
    await leaveRoom();

    if (!SupabaseService.isReady) {
      debugPrint('[OnlineMultiplayer] Supabase not ready, using mock realtime channel.');
      return true;
    }

    try {
      final client = Supabase.instance.client;
      _channel = client.channel('game_room:$roomCode');

      _channel!
        .onBroadcast(
          event: 'join_room',
          callback: (payload) {
            debugPrint('[OnlineMultiplayer] Guest joined: $payload');
            final guestInfo = OnlineRoomInfo(
              roomCode: roomCode,
              gameType: gameType,
              hostId: hostId,
              hostName: hostName,
              hostRating: hostRating,
              guestId: payload['guest_id'] as String?,
              guestName: payload['guest_name'] as String?,
              guestRating: payload['guest_rating'] as int?,
              durationMinutes: durationMinutes,
              isHostWhiteOrSente: isHostWhiteOrSente,
            );
            onGuestJoined(guestInfo);
          },
        )
        .onBroadcast(
          event: 'move',
          callback: (payload) {
            debugPrint('[OnlineMultiplayer] Move received: $payload');
            onMoveReceived(payload);
          },
        )
        .onBroadcast(
          event: 'resign',
          callback: (_) {
            onOpponentResigned();
          },
        );

      _channel!.subscribe();
      return true;
    } catch (e) {
      debugPrint('[OnlineMultiplayer] createRoom error: $e');
      return false;
    }
  }

  /// Join an existing room with room code
  static Future<bool> joinRoom({
    required String roomCode,
    required String guestId,
    required String guestName,
    required int guestRating,
    required Function(Map<String, dynamic> moveData) onMoveReceived,
    required Function() onOpponentResigned,
  }) async {
    await leaveRoom();

    if (!SupabaseService.isReady) {
      return true;
    }

    try {
      final client = Supabase.instance.client;
      _channel = client.channel('game_room:$roomCode');

      _channel!
        .onBroadcast(
          event: 'move',
          callback: (payload) {
            onMoveReceived(payload);
          },
        )
        .onBroadcast(
          event: 'resign',
          callback: (_) {
            onOpponentResigned();
          },
        );

      _channel!.subscribe();

      // Broadcast join event to host
      await _channel!.sendBroadcastMessage(
        event: 'join_room',
        payload: {
          'guest_id': guestId,
          'guest_name': guestName,
          'guest_rating': guestRating,
        },
      );

      return true;
    } catch (e) {
      debugPrint('[OnlineMultiplayer] joinRoom error: $e');
      return false;
    }
  }

  /// Broadcast a move to the opponent
  static Future<void> sendMove(Map<String, dynamic> moveData) async {
    if (_channel == null || !SupabaseService.isReady) return;
    try {
      await _channel!.sendBroadcastMessage(
        event: 'move',
        payload: moveData,
      );
    } catch (e) {
      debugPrint('[OnlineMultiplayer] sendMove error: $e');
    }
  }

  /// Broadcast resign event
  static Future<void> sendResign() async {
    if (_channel == null || !SupabaseService.isReady) return;
    try {
      await _channel!.sendBroadcastMessage(
        event: 'resign',
        payload: {'resigned': true},
      );
    } catch (e) {
      debugPrint('[OnlineMultiplayer] sendResign error: $e');
    }
  }

  /// Clean up and leave channel
  static Future<void> leaveRoom() async {
    if (_channel != null) {
      try {
        await _channel!.unsubscribe();
      } catch (_) {}
      _channel = null;
    }
  }
}
