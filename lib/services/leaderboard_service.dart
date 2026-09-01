import 'package:game_papan/models/game_enums.dart';
import 'package:game_papan/models/user_profile.dart';

class LeaderboardPlayer {
  final String id;
  final String name;
  final int rating;
  final int rank;
  final int wins;
  final int losses;
  final String avatar;
  final String title;
  final bool isCurrentUser;

  LeaderboardPlayer({
    required this.id,
    required this.name,
    required this.rating,
    required this.rank,
    required this.wins,
    required this.losses,
    required this.avatar,
    required this.title,
    this.isCurrentUser = false,
  });
}

class LeaderboardService {
  // Preset AI Masters & Global Champions pool
  static final List<Map<String, dynamic>> _chessMasters = [
    {'name': 'Magnus C.', 'rating': 2850, 'wins': 412, 'losses': 48, 'avatar': '👑', 'title': 'GM'},
    {'name': 'Hikaru N.', 'rating': 2810, 'wins': 389, 'losses': 55, 'avatar': '⚡', 'title': 'GM'},
    {'name': 'Alireza F.', 'rating': 2780, 'wins': 340, 'losses': 62, 'avatar': '🔥', 'title': 'GM'},
    {'name': 'Garry K.', 'rating': 2750, 'wins': 315, 'losses': 70, 'avatar': '🛡️', 'title': 'GM'},
    {'name': 'Vishy A.', 'rating': 2700, 'wins': 295, 'losses': 81, 'avatar': '🐯', 'title': 'GM'},
    {'name': 'Ding L.', 'rating': 2680, 'wins': 260, 'losses': 75, 'avatar': '🐉', 'title': 'GM'},
    {'name': 'Ian N.', 'rating': 2650, 'wins': 245, 'losses': 88, 'avatar': '⚔️', 'title': 'GM'},
    {'name': 'Levon A.', 'rating': 2610, 'wins': 230, 'losses': 90, 'avatar': '🦅', 'title': 'GM'},
    {'name': 'Wesley S.', 'rating': 2580, 'wins': 210, 'losses': 95, 'avatar': '💎', 'title': 'GM'},
    {'name': 'Fabiano C.', 'rating': 2550, 'wins': 198, 'losses': 100, 'avatar': '🎯', 'title': 'GM'},
    {'name': 'Anish G.', 'rating': 2500, 'wins': 185, 'losses': 105, 'avatar': '🏰', 'title': 'GM'},
    {'name': 'Nodirbek A.', 'rating': 2450, 'wins': 170, 'losses': 95, 'avatar': '🌟', 'title': 'IM'},
    {'name': 'Pragg R.', 'rating': 2400, 'wins': 160, 'losses': 90, 'avatar': '🚀', 'title': 'IM'},
    {'name': 'Gukesh D.', 'rating': 2350, 'wins': 150, 'losses': 85, 'avatar': '🥇', 'title': 'IM'},
    {'name': 'Vincent K.', 'rating': 2250, 'wins': 130, 'losses': 80, 'avatar': '🎖️', 'title': 'FM'},
    {'name': 'Daniel N.', 'rating': 2100, 'wins': 110, 'losses': 75, 'avatar': '♟️', 'title': 'CM'},
    {'name': 'Alexey S.', 'rating': 1950, 'wins': 95, 'losses': 70, 'avatar': '⚔️', 'title': 'Master'},
    {'name': 'Elena R.', 'rating': 1800, 'wins': 80, 'losses': 65, 'avatar': '🛡️', 'title': 'Expert'},
    {'name': 'Marcus V.', 'rating': 1650, 'wins': 65, 'losses': 55, 'avatar': '🗡️', 'title': 'Adept'},
    {'name': 'Kenji S.', 'rating': 1500, 'wins': 50, 'losses': 45, 'avatar': '🥋', 'title': 'Player'},
    {'name': 'Lucas B.', 'rating': 1350, 'wins': 35, 'losses': 40, 'avatar': '🏹', 'title': 'Player'},
    {'name': 'David K.', 'rating': 1200, 'wins': 20, 'losses': 30, 'avatar': '🎮', 'title': 'Novice'},
    {'name': 'Ethan W.', 'rating': 1050, 'wins': 10, 'losses': 25, 'avatar': '🌱', 'title': 'Novice'},
    {'name': 'Rookie Bot', 'rating': 850, 'wins': 5, 'losses': 35, 'avatar': '🤖', 'title': 'Beginner'},
  ];

  static final List<Map<String, dynamic>> _shogiMasters = [
    {'name': 'Souta Fujii (藤井 聡太)', 'rating': 2900, 'wins': 450, 'losses': 35, 'avatar': '👑', 'title': 'Meijin (名人)'},
    {'name': 'Yoshiharu Habu (羽生 善治)', 'rating': 2840, 'wins': 420, 'losses': 60, 'avatar': '🏯', 'title': '9-Dan (九段)'},
    {'name': 'Takuya Nagase (永瀬 拓矢)', 'rating': 2790, 'wins': 365, 'losses': 72, 'avatar': '⚡', 'title': 'Oza (王座)'},
    {'name': 'Akira Watanabe (渡辺 明)', 'rating': 2750, 'wins': 330, 'losses': 80, 'avatar': '🔥', 'title': '9-Dan (九段)'},
    {'name': 'Shintaro Saito (斎藤 慎太郎)', 'rating': 2690, 'wins': 280, 'losses': 75, 'avatar': '🦅', 'title': '8-Dan (八段)'},
    {'name': 'Masayuki Toyoshima (豊島 将之)', 'rating': 2640, 'wins': 250, 'losses': 85, 'avatar': '🐉', 'title': '9-Dan (九段)'},
    {'name': 'Tatsuya Sugai (菅井 竜也)', 'rating': 2590, 'wins': 230, 'losses': 90, 'avatar': '⚔️', 'title': '8-Dan (八段)'},
    {'name': 'Yasuhiro Masuda (増田 康宏)', 'rating': 2520, 'wins': 205, 'losses': 88, 'avatar': '🎯', 'title': '7-Dan (七段)'},
    {'name': 'Akiyuki Honda (本田 奎)', 'rating': 2450, 'wins': 180, 'losses': 92, 'avatar': '💎', 'title': '6-Dan (六段)'},
    {'name': 'Takayuki Yamasaki (山崎 隆之)', 'rating': 2380, 'wins': 160, 'losses': 85, 'avatar': '🌟', 'title': '8-Dan (八段)'},
    {'name': 'Kazuki Ito (伊藤 匠)', 'rating': 2300, 'wins': 140, 'losses': 70, 'avatar': '🗡️', 'title': '7-Dan (七段)'},
    {'name': 'Reo Kurosawa (黒沢 怜生)', 'rating': 2200, 'wins': 120, 'losses': 75, 'avatar': '🛡️', 'title': '6-Dan (六段)'},
    {'name': 'Wataru Kamimura (上村 亘)', 'rating': 2050, 'wins': 105, 'losses': 70, 'avatar': '🥋', 'title': '5-Dan (五段)'},
    {'name': 'Kenta Sasaki (佐々木 勇気)', 'rating': 1900, 'wins': 90, 'losses': 65, 'avatar': '⛩️', 'title': '4-Dan (四段)'},
    {'name': 'Hiroshi Mori (森 裕司)', 'rating': 1750, 'wins': 75, 'losses': 60, 'avatar': '🏯', 'title': '1-Dan (初段)'},
    {'name': 'Daiki Sato (佐藤 大樹)', 'rating': 1600, 'wins': 60, 'losses': 55, 'avatar': '🌸', 'title': '1-Kyu (1級)'},
    {'name': 'Yuki Tanaka (田中 勇気)', 'rating': 1450, 'wins': 45, 'losses': 50, 'avatar': '🎏', 'title': '3-Kyu (3級)'},
    {'name': 'Shinji Ono (小野 伸二)', 'rating': 1300, 'wins': 30, 'losses': 40, 'avatar': '🏮', 'title': '5-Kyu (5級)'},
    {'name': 'Ryota Takahashi (高橋 亮太)', 'rating': 1150, 'wins': 18, 'losses': 30, 'avatar': '🌱', 'title': '7-Kyu (7級)'},
    {'name': 'Beginner Shogi Bot', 'rating': 850, 'wins': 5, 'losses': 35, 'avatar': '🤖', 'title': '10-Kyu (10級)'},
  ];

  /// Get leaderboard with current player injected at their accurate rank
  static List<LeaderboardPlayer> getLeaderboard({
    required GameType gameType,
    required UserProfile? currentUser,
  }) {
    final rawList = gameType == GameType.chess ? _chessMasters : _shogiMasters;

    final userRating = gameType == GameType.chess
        ? (currentUser?.chessRating ?? 1200)
        : (currentUser?.shogiRating ?? 1200);

    final userWins = gameType == GameType.chess
        ? (currentUser?.chessWins ?? 0)
        : (currentUser?.shogiWins ?? 0);

    final userLosses = gameType == GameType.chess
        ? (currentUser?.chessLosses ?? 0)
        : (currentUser?.shogiLosses ?? 0);

    final userName = currentUser?.displayName ?? 'Player (Anda)';

    String userTitle;
    if (gameType == GameType.chess) {
      if (userRating >= 2400) {
        userTitle = 'GM';
      } else if (userRating >= 2200) {
        userTitle = 'FM';
      } else if (userRating >= 1800) {
        userTitle = 'Expert';
      } else if (userRating >= 1400) {
        userTitle = 'Adept';
      } else {
        userTitle = 'Novice';
      }
    } else {
      if (userRating >= 2600) {
        userTitle = 'Meijin (名人)';
      } else if (userRating >= 2200) {
        userTitle = '7-Dan (七段)';
      } else if (userRating >= 1800) {
        userTitle = '3-Dan (三段)';
      } else if (userRating >= 1400) {
        userTitle = '1-Kyu (1級)';
      } else {
        userTitle = 'Novice';
      }
    }

    final allPlayers = <Map<String, dynamic>>[];

    for (final m in rawList) {
      allPlayers.add(Map<String, dynamic>.from(m));
    }

    // Inject current user
    allPlayers.add({
      'name': '$userName (Anda)',
      'rating': userRating,
      'wins': userWins,
      'losses': userLosses,
      'avatar': '👑',
      'title': userTitle,
      'isCurrentUser': true,
      'id': currentUser?.id ?? 'user_me',
    });

    // Sort descending by rating, then by wins
    allPlayers.sort((a, b) {
      final int ratingComp = (b['rating'] as int).compareTo(a['rating'] as int);
      if (ratingComp != 0) return ratingComp;
      return (b['wins'] as int).compareTo(a['wins'] as int);
    });

    final result = <LeaderboardPlayer>[];
    for (int i = 0; i < allPlayers.length; i++) {
      final item = allPlayers[i];
      result.add(
        LeaderboardPlayer(
          id: item['id'] as String? ?? 'bot_$i',
          name: item['name'] as String,
          rating: item['rating'] as int,
          rank: i + 1,
          wins: item['wins'] as int,
          losses: item['losses'] as int,
          avatar: item['avatar'] as String,
          title: item['title'] as String,
          isCurrentUser: item['isCurrentUser'] as bool? ?? false,
        ),
      );
    }

    return result;
  }
}
