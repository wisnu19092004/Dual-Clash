import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:game_papan/chess/chess_piece.dart';
import 'package:game_papan/models/bot_difficulty.dart';
import 'package:game_papan/models/game_enums.dart';
import 'package:game_papan/screens/chess_game_screen.dart';
import 'package:game_papan/screens/shogi_game_screen.dart';
import 'package:game_papan/services/auth_service.dart';
import 'package:game_papan/services/language_provider.dart';
import 'package:game_papan/services/online_multiplayer_service.dart';
import 'package:game_papan/shogi/shogi_piece.dart';
import 'package:game_papan/theme/app_colors.dart';
import 'package:game_papan/widgets/interactive_button.dart';

class OnlineRoomDialog extends StatefulWidget {
  final GameType gameType;
  final int durationMinutes;

  const OnlineRoomDialog({
    super.key,
    required this.gameType,
    required this.durationMinutes,
  });

  @override
  State<OnlineRoomDialog> createState() => _OnlineRoomDialogState();
}

class _OnlineRoomDialogState extends State<OnlineRoomDialog> {
  bool _isCreating = true;
  String? _roomCode;
  bool _isWaitingOpponent = false;
  final TextEditingController _joinCodeController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _joinCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateRoom() async {
    final auth = context.read<AuthService>();
    final user = auth.currentUser;
    final generatedCode = OnlineMultiplayerService.generateRoomCode();

    setState(() {
      _roomCode = generatedCode;
      _isWaitingOpponent = true;
      _errorMessage = null;
    });

    final success = await OnlineMultiplayerService.createRoom(
      roomCode: generatedCode,
      gameType: widget.gameType,
      hostId: user?.id ?? 'guest_host',
      hostName: user?.displayName ?? 'Host Player',
      hostRating: widget.gameType == GameType.chess
          ? (user?.chessRating ?? 1200)
          : (user?.shogiRating ?? 1200),
      durationMinutes: widget.durationMinutes,
      isHostWhiteOrSente: true,
      onGuestJoined: (roomInfo) {
        if (!mounted) return;
        Navigator.pop(context); // Close dialog
        _navigateToOnlineGame(
          isHost: true,
          roomCode: generatedCode,
          opponentName: roomInfo.guestName ?? 'Opponent',
          opponentRating: roomInfo.guestRating ?? 1200,
        );
      },
      onMoveReceived: (_) {},
      onOpponentResigned: () {},
    );

    if (!success && mounted) {
      setState(() {
        _isWaitingOpponent = false;
        _errorMessage = 'Gagal membuat room. Silakan coba lagi.';
      });
    }
  }

  Future<void> _handleJoinRoom() async {
    final code = _joinCodeController.text.trim().toUpperCase().replaceAll(' ', '');
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Masukkan kode room terlebih dahulu.');
      return;
    }

    if (!code.startsWith('DC-') || code.length < 5) {
      setState(() => _errorMessage = 'Format kode tidak valid. Contoh: DC-K7X9');
      return;
    }

    final auth = context.read<AuthService>();
    final user = auth.currentUser;

    setState(() {
      _isWaitingOpponent = true;
      _errorMessage = null;
    });

    final success = await OnlineMultiplayerService.joinRoom(
      roomCode: code,
      guestId: user?.id ?? 'guest_player',
      guestName: user?.displayName ?? 'Guest Player',
      guestRating: widget.gameType == GameType.chess
          ? (user?.chessRating ?? 1200)
          : (user?.shogiRating ?? 1200),
      onMoveReceived: (_) {},
      onOpponentResigned: () {},
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      _navigateToOnlineGame(
        isHost: false,
        roomCode: code,
        opponentName: 'Host Player',
        opponentRating: 1200,
      );
    } else {
      setState(() {
        _isWaitingOpponent = false;
        _errorMessage = 'Room tidak ditemukan atau telah ditutup.';
      });
    }
  }

  void _navigateToOnlineGame({
    required bool isHost,
    required String roomCode,
    required String opponentName,
    required int opponentRating,
  }) {
    if (widget.gameType == GameType.chess) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChessGameScreen(
            mode: GameMode.onlineMatch,
            botDifficulty: BotDifficulty.intermediate,
            durationMinutes: widget.durationMinutes,
            playerColor: isHost ? ChessColor.white : ChessColor.black,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ShogiGameScreen(
            mode: GameMode.onlineMatch,
            botDifficulty: BotDifficulty.intermediate,
            durationMinutes: widget.durationMinutes,
            playerSide: isHost ? ShogiPlayer.sente : ShogiPlayer.gote,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final isChess = widget.gameType == GameType.chess;
    final primaryColor = isChess ? AppColors.primary : AppColors.secondary;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      backgroundColor: AppColors.surface(context),
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.wifi_tethering_rounded, color: primaryColor, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      lang.tr('vs_online'),
                      style: GoogleFonts.cinzel(
                        color: AppColors.textColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.textSecondaryColor(context), size: 20),
                  onPressed: () {
                    OnlineMultiplayerService.leaveRoom();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Tab switcher
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor(context)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_isWaitingOpponent) return;
                        setState(() {
                          _isCreating = true;
                          _errorMessage = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _isCreating ? primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          lang.tr('create_room'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: _isCreating ? Colors.white : AppColors.textSecondaryColor(context),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_isWaitingOpponent) return;
                        setState(() {
                          _isCreating = false;
                          _errorMessage = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !_isCreating ? primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          lang.tr('join_room'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: !_isCreating ? Colors.white : AppColors.textSecondaryColor(context),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),

            if (_isCreating) ...[
              if (!_isWaitingOpponent) ...[
                Text(
                  'Buat room baru dan bagikan kodenya ke teman mabar Anda.',
                  style: TextStyle(color: AppColors.textSecondaryColor(context), fontSize: 12.5),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: InteractiveButton(
                    onPressed: _handleCreateRoom,
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Text(
                        lang.tr('create_room'),
                        style: GoogleFonts.cinzel(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Center(
                  child: Column(
                    children: [
                      Text(
                        lang.tr('share_room_code'),
                        style: TextStyle(color: AppColors.textSecondaryColor(context), fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: primaryColor, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _roomCode ?? '',
                              style: GoogleFonts.cinzel(
                                color: primaryColor,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 20),
                              color: primaryColor,
                              onPressed: () {
                                if (_roomCode != null) {
                                  Clipboard.setData(ClipboardData(text: _roomCode!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Kode room disalin ke clipboard!')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        lang.tr('waiting_opponent'),
                        style: TextStyle(color: AppColors.textSecondaryColor(context), fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            OnlineMultiplayerService.leaveRoom();
                            setState(() {
                              _isWaitingOpponent = false;
                              _roomCode = null;
                            });
                          },
                          icon: const Icon(Icons.close_rounded, size: 16),
                          label: Text(
                            lang.tr('cancel'),
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else ...[
              Text(
                lang.tr('enter_room_code'),
                style: TextStyle(color: AppColors.textSecondaryColor(context), fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _joinCodeController,
                textCapitalization: TextCapitalization.characters,
                style: GoogleFonts.cinzel(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: AppColors.textColor(context),
                ),
                decoration: InputDecoration(
                  hintText: 'DC-XXXX',
                  hintStyle: TextStyle(color: AppColors.textMutedColor(context)),
                  filled: true,
                  fillColor: AppColors.surfaceDark(context),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: InteractiveButton(
                  onPressed: _isWaitingOpponent ? null : _handleJoinRoom,
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: _isWaitingOpponent
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            lang.tr('join_room'),
                            style: GoogleFonts.cinzel(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
