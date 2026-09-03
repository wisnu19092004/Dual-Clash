import 'package:game_papan/models/match_record.dart';

class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String photoUrl;
  final int chessRating;
  final int shogiRating;
  final int chessWins;
  final int chessLosses;
  final int chessDraws;
  final int shogiWins;
  final int shogiLosses;
  final int shogiDraws;
  final String themeMode; // 'dark' | 'light'
  final String languageCode; // 'id' | 'en' | 'ja' | 'ms'
  final bool soundEnabled;
  final List<MatchRecord> history;

  UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    this.chessRating = 1200,
    this.shogiRating = 1200,
    this.chessWins = 0,
    this.chessLosses = 0,
    this.chessDraws = 0,
    this.shogiWins = 0,
    this.shogiLosses = 0,
    this.shogiDraws = 0,
    this.themeMode = 'dark',
    this.languageCode = 'id',
    this.soundEnabled = true,
    this.history = const [],
  });

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    int? chessRating,
    int? shogiRating,
    int? chessWins,
    int? chessLosses,
    int? chessDraws,
    int? shogiWins,
    int? shogiLosses,
    int? shogiDraws,
    String? themeMode,
    String? languageCode,
    bool? soundEnabled,
    List<MatchRecord>? history,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      chessRating: chessRating ?? this.chessRating,
      shogiRating: shogiRating ?? this.shogiRating,
      chessWins: chessWins ?? this.chessWins,
      chessLosses: chessLosses ?? this.chessLosses,
      chessDraws: chessDraws ?? this.chessDraws,
      shogiWins: shogiWins ?? this.shogiWins,
      shogiLosses: shogiLosses ?? this.shogiLosses,
      shogiDraws: shogiDraws ?? this.shogiDraws,
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      history: history ?? this.history,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'chessRating': chessRating,
        'shogiRating': shogiRating,
        'chessWins': chessWins,
        'chessLosses': chessLosses,
        'chessDraws': chessDraws,
        'shogiWins': shogiWins,
        'shogiLosses': shogiLosses,
        'shogiDraws': shogiDraws,
        'themeMode': themeMode,
        'languageCode': languageCode,
        'soundEnabled': soundEnabled,
        'history': history.map((e) => e.toJson()).toList(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        email: json['email'] as String? ?? '',
        displayName: json['displayName'] as String? ?? 'Player',
        photoUrl: json['photoUrl'] as String? ?? '',
        chessRating: json['chessRating'] as int? ?? 1200,
        shogiRating: json['shogiRating'] as int? ?? 1200,
        chessWins: json['chessWins'] as int? ?? 0,
        chessLosses: json['chessLosses'] as int? ?? 0,
        chessDraws: json['chessDraws'] as int? ?? 0,
        shogiWins: json['shogiWins'] as int? ?? 0,
        shogiLosses: json['shogiLosses'] as int? ?? 0,
        shogiDraws: json['shogiDraws'] as int? ?? 0,
        themeMode: json['themeMode'] as String? ?? 'dark',
        languageCode: json['languageCode'] as String? ?? 'id',
        soundEnabled: json['soundEnabled'] as bool? ?? true,
        history: (json['history'] as List<dynamic>?)
                ?.map((e) => MatchRecord.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
