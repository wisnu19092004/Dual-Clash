import 'package:game_papan/models/game_enums.dart';

class MatchRecord {
  final String id;
  final GameType gameType;
  final GameMode gameMode;
  final CoachLevel? coachLevel;
  final MatchOutcome outcome;
  final int opponentRating;
  final String opponentName;
  final int ratingChange; // 0 if vsBot
  final DateTime timestamp;
  final int totalMoves;
  final double? accuracy;
  final Map<String, dynamic>? analysisSummary;
  final bool isSynced;

  MatchRecord({
    required this.id,
    required this.gameType,
    required this.gameMode,
    this.coachLevel,
    required this.outcome,
    required this.opponentRating,
    required this.opponentName,
    required this.ratingChange,
    required this.timestamp,
    required this.totalMoves,
    this.accuracy,
    this.analysisSummary,
    this.isSynced = false,
  });

  MatchRecord copyWith({
    String? id,
    GameType? gameType,
    GameMode? gameMode,
    CoachLevel? coachLevel,
    MatchOutcome? outcome,
    int? opponentRating,
    String? opponentName,
    int? ratingChange,
    DateTime? timestamp,
    int? totalMoves,
    double? accuracy,
    Map<String, dynamic>? analysisSummary,
    bool? isSynced,
  }) {
    return MatchRecord(
      id: id ?? this.id,
      gameType: gameType ?? this.gameType,
      gameMode: gameMode ?? this.gameMode,
      coachLevel: coachLevel ?? this.coachLevel,
      outcome: outcome ?? this.outcome,
      opponentRating: opponentRating ?? this.opponentRating,
      opponentName: opponentName ?? this.opponentName,
      ratingChange: ratingChange ?? this.ratingChange,
      timestamp: timestamp ?? this.timestamp,
      totalMoves: totalMoves ?? this.totalMoves,
      accuracy: accuracy ?? this.accuracy,
      analysisSummary: analysisSummary ?? this.analysisSummary,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'gameType': gameType.name,
        'gameMode': gameMode.name,
        'coachLevel': coachLevel?.name,
        'outcome': outcome.name,
        'opponentRating': opponentRating,
        'opponentName': opponentName,
        'ratingChange': ratingChange,
        'timestamp': timestamp.toIso8601String(),
        'totalMoves': totalMoves,
        'accuracy': accuracy,
        'analysisSummary': analysisSummary,
        'isSynced': isSynced,
      };

  factory MatchRecord.fromJson(Map<String, dynamic> json) => MatchRecord(
        id: json['id'] as String,
        gameType: GameType.values.byName(json['gameType'] as String),
        gameMode: GameMode.values.byName(json['gameMode'] as String),
        coachLevel: json['coachLevel'] != null
            ? CoachLevel.values.byName(json['coachLevel'] as String)
            : null,
        outcome: MatchOutcome.values.byName(json['outcome'] as String),
        opponentRating: json['opponentRating'] as int? ?? 1200,
        opponentName: json['opponentName'] as String? ?? 'Opponent',
        ratingChange: json['ratingChange'] as int? ?? 0,
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'] as String)
            : DateTime.now(),
        totalMoves: json['totalMoves'] as int? ?? 0,
        accuracy: (json['accuracy'] as num?)?.toDouble(),
        analysisSummary: json['analysisSummary'] as Map<String, dynamic>?,
        isSynced: json['isSynced'] as bool? ?? false,
      );
}
