import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:game_papan/models/game_enums.dart';
import 'package:game_papan/services/auth_service.dart';
import 'package:game_papan/services/leaderboard_service.dart';
import 'package:game_papan/services/language_provider.dart';
import 'package:game_papan/widgets/game_emblem_icon.dart';
import 'package:game_papan/theme/app_colors.dart';

class LeaderboardScreen extends StatefulWidget {
  final GameType initialGameType;

  const LeaderboardScreen({super.key, this.initialGameType = GameType.chess});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialGameType == GameType.chess ? 0 : 1,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textColor(context),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFFFBBF24),
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              langProvider.tr('leaderboard'),
              style: GoogleFonts.cinzel(
                color: AppColors.textColor(context),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor(context)),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD97706), Color(0xFF92400E)],
                ),
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD97706).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondaryColor(context),
              labelStyle: GoogleFonts.cinzel(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GameEmblemIcon(isChess: true, size: 16),
                      SizedBox(width: 6),
                      Text(langProvider.tr('chess_tab')),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GameEmblemIcon(isChess: false, size: 16),
                      SizedBox(width: 6),
                      Text(langProvider.tr('shogi_tab')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaderboardView(GameType.chess, user),
          _buildLeaderboardView(GameType.shogi, user),
        ],
      ),
    );
  }

  Widget _buildLeaderboardView(GameType gameType, dynamic currentUser) {
    final players = LeaderboardService.getLeaderboard(
      gameType: gameType,
      currentUser: currentUser,
    );

    final myPlayer = players.firstWhere((p) => p.isCurrentUser);
    final top3 = players.take(3).toList();
    final remainingPlayers = players.skip(3).toList();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Column(
              children: [
                // Top 3 Podium
                if (top3.length >= 3) _buildTop3Podium(top3, gameType),
                const SizedBox(height: 18),

                // Table Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Text(
                          context.watch<LanguageProvider>().tr('rank'),
                          style: GoogleFonts.cinzel(
                            color: AppColors.textMutedColor(context),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.watch<LanguageProvider>().tr('players'),
                          style: GoogleFonts.cinzel(
                            color: AppColors.textMutedColor(context),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        context.watch<LanguageProvider>().tr('rating_elo'),
                        style: GoogleFonts.cinzel(
                          color: AppColors.textMutedColor(context),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                // List of players rank 4+
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: remainingPlayers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final p = remainingPlayers[index];
                    return _buildPlayerRow(p, gameType);
                  },
                ),
              ],
            ),
          ),
        ),

        // Sticky Bottom "My Rank" Bar
        _buildMyRankStickyBar(myPlayer, gameType),
      ],
    );
  }

  Widget _buildTop3Podium(List<LeaderboardPlayer> top3, GameType gameType) {
    final rank1 = top3[0];
    final rank2 = top3[1];
    final rank3 = top3[2];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF261811), Color(0xFF19100B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF92400E).withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place (Silver)
          _buildPodiumPillar(
            player: rank2,
            rank: 2,
            height: 100,
            medalColor: const Color(0xFFCBD5E1),
            badgeColor: const Color(0xFF94A3B8),
            medalIcon: Icons.military_tech_rounded,
          ),

          // 1st Place (Gold) - Tallest
          _buildPodiumPillar(
            player: rank1,
            rank: 1,
            height: 130,
            medalColor: const Color(0xFFFBBF24),
            badgeColor: const Color(0xFFD97706),
            medalIcon: Icons.workspace_premium_rounded,
            isFirst: true,
          ),

          // 3rd Place (Bronze)
          _buildPodiumPillar(
            player: rank3,
            rank: 3,
            height: 85,
            medalColor: const Color(0xFFCD7F32),
            badgeColor: const Color(0xFF9A632F),
            medalIcon: Icons.military_tech_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPillar({
    required LeaderboardPlayer player,
    required int rank,
    required double height,
    required Color medalColor,
    required Color badgeColor,
    required IconData medalIcon,
    bool isFirst = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar + Crown
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: isFirst ? 54 : 44,
              height: isFirst ? 54 : 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isFirst
                      ? [
                          const Color(0xFFFFFBEB),
                          const Color(0xFFFBBF24),
                          const Color(0xFF92400E),
                        ]
                      : [const Color(0xFF475569), const Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: medalColor,
                  width: isFirst ? 2.2 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: medalColor.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                player.avatar,
                style: TextStyle(fontSize: isFirst ? 24 : 18),
              ),
            ),
            Positioned(
              bottom: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  '#$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Player Name
        SizedBox(
          width: 90,
          child: Text(
            player.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: player.isCurrentUser
                  ? const Color(0xFFFBBF24)
                  : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Rating
        Container(
          margin: const EdgeInsets.only(top: 2, bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${player.rating} ELO',
            style: GoogleFonts.cinzel(
              color: medalColor,
              fontWeight: FontWeight.bold,
              fontSize: 10.5,
            ),
          ),
        ),

        // Podium Block
        Container(
          width: 82,
          height: height * 0.45,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                badgeColor.withValues(alpha: 0.7),
                badgeColor.withValues(alpha: 0.25),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            border: Border.all(
              color: medalColor.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(medalIcon, color: medalColor, size: isFirst ? 28 : 22),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerRow(LeaderboardPlayer player, GameType gameType) {
    final isMe = player.isCurrentUser;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isMe
            ? const Color(0xFFD97706).withValues(alpha: 0.22)
            : AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe
              ? const Color(0xFFFBBF24)
              : AppColors.borderColor(context),
          width: isMe ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Rank Number
          SizedBox(
            width: 32,
            child: Text(
              '#${player.rank}',
              style: GoogleFonts.cinzel(
                color: isMe
                    ? const Color(0xFFFBBF24)
                    : AppColors.textMutedColor(context),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Avatar / Icon
          Text(player.avatar, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),

          // Name and Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        player.name,
                        style: GoogleFonts.plusJakartaSans(
                          color: isMe
                              ? const Color(0xFFFBBF24)
                              : AppColors.textColor(context),
                          fontWeight: isMe ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 12.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                          width: 0.6,
                        ),
                      ),
                      child: Text(
                        player.title,
                        style: const TextStyle(
                          color: Color(0xFFFBBF24),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  context.watch<LanguageProvider>().trArgs('record', {
                    'wins': '${player.wins}',
                    'losses': '${player.losses}',
                  }),
                  style: TextStyle(
                    color: AppColors.textMutedColor(context),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),

          // Rating
          Text(
            '${player.rating} ELO',
            style: GoogleFonts.cinzel(
              color: isMe
                  ? const Color(0xFFFBBF24)
                  : AppColors.textColor(context),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyRankStickyBar(LeaderboardPlayer myPlayer, GameType gameType) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E1B10), Color(0xFF1A0E08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFD97706).withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                context.watch<LanguageProvider>().trArgs('position', {
                  'rank': '${myPlayer.rank}',
                }),
                style: GoogleFonts.cinzel(
                  color: const Color(0xFF451A03),
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    myPlayer.name,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    context.watch<LanguageProvider>().trArgs('title_record', {
                      'title': myPlayer.title,
                      'wins': '${myPlayer.wins}',
                      'losses': '${myPlayer.losses}',
                    }),
                    style: const TextStyle(
                      color: Color(0xFFD4C5B8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFD97706).withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF59E0B), width: 0.8),
              ),
              child: Text(
                '${myPlayer.rating} ELO',
                style: GoogleFonts.cinzel(
                  color: const Color(0xFFFDE68A),
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
