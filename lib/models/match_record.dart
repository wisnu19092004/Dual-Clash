import 'package:game_papan/models/game_enums.dart';

class MatchRecord {
  final String id;
  final GameType gameType;
  final GameMode gameMode;
  final MatchOutcome outcome;
  final int opponentRating;
  final String opponentName;
  final int ratingChange; // 0 if vsBot
  final DateTime timestamp;
  final int totalMoves;

  MatchRecord({
    required this.id,
    required this.gameType,
    required this.gameMode,
    required this.outcome,
    required this.opponentRating,
    required this.opponentName,
    required this.ratingChange,
    required this.timestamp,
    required this.totalMoves,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'gameType': gameType.name,
        'gameMode': gameMode.name,
        'outcome': outcome.name,
        'opponentRating': opponentRating,
        'opponentName': opponentName,
        'ratingChange': ratingChange,
        'timestamp': timestamp.toIso8601String(),
        'totalMoves': totalMoves,
      };

  factory MatchRecord.fromJson(Map<String, dynamic> json) => MatchRecord(
        id: json['id'] as String,
        gameType: GameType.values.byName(json['gameType'] as String),
        gameMode: GameMode.values.byName(json['gameMode'] as String),
        outcome: MatchOutcome.values.byName(json['outcome'] as String),
        opponentRating: json['opponentRating'] as int,
        opponentName: json['opponentName'] as String,
        ratingChange: json['ratingChange'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
        totalMoves: json['totalMoves'] as int,
      );
}
