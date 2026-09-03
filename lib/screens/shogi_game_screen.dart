import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:game_papan/models/bot_difficulty.dart';
import 'package:game_papan/models/game_enums.dart';
import 'package:game_papan/services/ad_service.dart';
import 'package:game_papan/services/auth_service.dart';
import 'package:game_papan/services/language_provider.dart';
import 'package:game_papan/services/sound_effects.dart';
import 'package:game_papan/shogi/shogi_ai.dart';
import 'package:game_papan/shogi/shogi_board.dart';
import 'package:game_papan/shogi/shogi_move.dart';
import 'package:game_papan/shogi/shogi_piece.dart';
import 'package:game_papan/theme/app_colors.dart';
import 'package:game_papan/theme/theme_provider.dart';
import 'package:game_papan/utils/time_formatter.dart';
import 'package:game_papan/widgets/game_emblem_icon.dart';
import 'package:game_papan/widgets/shogi_board_view.dart';
import 'package:game_papan/widgets/shogi_player_header.dart';
import 'package:game_papan/services/game_analysis_engine.dart';
import 'package:game_papan/services/online_multiplayer_service.dart';
import 'package:game_papan/widgets/game_analysis_dialog.dart';
import 'package:game_papan/widgets/shogi_promotion_choice_dialog.dart';
import 'package:game_papan/widgets/game_status_bar.dart';
import 'package:game_papan/widgets/match_end_dialog.dart';
import 'package:game_papan/widgets/confirm_dialog.dart';
import 'package:game_papan/widgets/interactive_button.dart';

class ShogiGameScreen extends StatefulWidget {
  final GameMode mode;
  final BotDifficulty botDifficulty;
  final CoachLevel? coachLevel;
  final ShogiPlayer playerSide;
  final int durationMinutes; // 0 = unlimited

  const ShogiGameScreen({
    super.key,
    required this.mode,
    this.botDifficulty = BotDifficulty.intermediate,
    this.coachLevel,
    this.playerSide = ShogiPlayer.sente,
    this.durationMinutes = 10,
  });

  @override
  State<ShogiGameScreen> createState() => _ShogiGameScreenState();
}

class _ShogiGameScreenState extends State<ShogiGameScreen> {
  late ShogiBoard _board;
  ShogiPosition? _selectedPosition;
  ShogiPieceType? _selectedHandPiece;
  List<ShogiMove> _validMoves = [];
  bool _isAiThinking = false;
  bool _gameOver = false;
  late int _senteTimerSeconds;
  late int _goteTimerSeconds;
  Timer? _matchTimer;
  ShogiPosition? _lastMoveFrom;
  ShogiPosition? _lastMoveTo;
  ShogiPiece? _animatedPiece;
  MoveAnalysis? _lastCoachAnalysis;

  bool get _isCoachMode => widget.mode == GameMode.coach;
  bool get _isUnlimitedTimer => widget.durationMinutes == 0;

  StreamSubscription? _onlineMoveSub;

  @override
  void initState() {
    super.initState();
    _startNewGame();
    if (widget.mode == GameMode.onlineMatch) {
      _listenToOnlineEvents();
    }
  }

  void _listenToOnlineEvents() {
    _onlineMoveSub = OnlineMultiplayerService.onGameEvent.listen((event) {
      if (!mounted || _gameOver) return;
      if (event.containsKey('toRow') && event.containsKey('toCol')) {
        final to = ShogiPosition(event['toRow'], event['toCol']);
        final isDrop = event['isDrop'] == true;
        final from = !isDrop && event.containsKey('fromRow') && event.containsKey('fromCol')
            ? ShogiPosition(event['fromRow'], event['fromCol'])
            : null;
        final promote = event['promote'] == true;
        final pieceType = ShogiPieceType.values.byName(event['pieceType']);

        final legalMoves = _board.getAllLegalMoves();
        final matchMove = legalMoves.firstWhere(
          (m) =>
              m.to == to &&
              m.from == from &&
              m.promote == promote &&
              (isDrop ? m.dropPieceType == pieceType : true),
          orElse: () => ShogiMove(
            from: from,
            to: to,
            dropPieceType: isDrop ? pieceType : null,
            promote: promote,
          ),
        );
        _applyMove(matchMove, isFromOnline: true);
      } else if (event.containsKey('resigned') && event['resigned'] == true) {
        _onGameEnded(
          outcome: MatchOutcome.win,
          title: 'Lawan Menyerah!',
          message: 'Lawan Anda telah menyerah dari pertandingan online.',
        );
      }
    });
  }

  @override
  void dispose() {
    _onlineMoveSub?.cancel();
    if (widget.mode == GameMode.onlineMatch) {
      OnlineMultiplayerService.leaveRoom();
    }
    _matchTimer?.cancel();
    super.dispose();
  }

  void _startNewGame() {
    _matchTimer?.cancel();
    final initialSeconds = _isUnlimitedTimer ? 0 : widget.durationMinutes * 60;
    setState(() {
      _board = ShogiBoard();
      _selectedPosition = null;
      _selectedHandPiece = null;
      _validMoves = [];
      _isAiThinking = false;
      _gameOver = false;
      _senteTimerSeconds = initialSeconds;
      _goteTimerSeconds = initialSeconds;
      _lastMoveFrom = null;
      _lastMoveTo = null;
      _animatedPiece = null;
      _lastCoachAnalysis = null;
    });

    _startTimer();

    if ((widget.mode == GameMode.vsBot || widget.mode == GameMode.coach) &&
        widget.playerSide == ShogiPlayer.gote) {
      _triggerAiMove();
    }
  }

  void _startTimer() {
    _matchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameOver) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_isUnlimitedTimer) {
          if (_board.turn == ShogiPlayer.sente) {
            _senteTimerSeconds++;
          } else {
            _goteTimerSeconds++;
          }
        } else {
          if (_board.turn == ShogiPlayer.sente) {
            if (_senteTimerSeconds > 0) _senteTimerSeconds--;
            if (_senteTimerSeconds == 0) _handleTimeout(ShogiPlayer.sente);
          } else {
            if (_goteTimerSeconds > 0) _goteTimerSeconds--;
            if (_goteTimerSeconds == 0) _handleTimeout(ShogiPlayer.gote);
          }
        }
      });
    });
  }

  void _handleTimeout(ShogiPlayer timedOutPlayer) {
    if (_gameOver) return;
    _gameOver = true;
    _matchTimer?.cancel();

    final winner = timedOutPlayer == ShogiPlayer.sente
        ? ShogiPlayer.gote
        : ShogiPlayer.sente;
    final isPlayerWin =
        widget.mode == GameMode.vsPlayer || widget.playerSide == winner;

    _onGameEnded(
      outcome: isPlayerWin ? MatchOutcome.win : MatchOutcome.loss,
      title: 'Waktu Habis!',
      message:
          '${timedOutPlayer == ShogiPlayer.sente ? "Sente (先手)" : "Gote (後手)"} kehabisan waktu.',
    );
  }

  void _onSquareTap(int row, int col) {
    if (_gameOver || _isAiThinking) return;

    if ((widget.mode == GameMode.vsBot ||
            widget.mode == GameMode.coach ||
            widget.mode == GameMode.onlineMatch) &&
        _board.turn != widget.playerSide) {
      return;
    }

    final tappedPos = ShogiPosition(row, col);
    final tappedPiece = _board.getPiece(tappedPos);

    if (_selectedPosition == tappedPos) {
      setState(() {
        _selectedPosition = null;
        _selectedHandPiece = null;
        _validMoves = [];
      });
      return;
    }

    if (_selectedPosition != null || _selectedHandPiece != null) {
      final matchingMoves = _validMoves
          .where((m) => m.to == tappedPos)
          .toList();

      if (matchingMoves.isNotEmpty) {
        if (matchingMoves.length == 1) {
          _executePlayerMove(matchingMoves.first);
          return;
        } else {
          _showPromotionChoiceDialog(matchingMoves);
          return;
        }
      }
    }

    if (tappedPiece != null && tappedPiece.player == _board.turn) {
      SoundEffects.playButtonClick();
      setState(() {
        _selectedPosition = tappedPos;
        _selectedHandPiece = null;
        _validMoves = _board.getLegalMovesForPosition(tappedPos);
      });
    } else {
      setState(() {
        _selectedPosition = null;
        _selectedHandPiece = null;
        _validMoves = [];
      });
    }
  }

  void _onHandPieceTap(ShogiPieceType pieceType) {
    if (_gameOver || _isAiThinking) return;
    if ((widget.mode == GameMode.vsBot ||
            widget.mode == GameMode.coach ||
            widget.mode == GameMode.onlineMatch) &&
        _board.turn != widget.playerSide) {
      return;
    }

    if (_selectedHandPiece == pieceType) {
      setState(() {
        _selectedHandPiece = null;
        _validMoves = [];
      });
      return;
    }

    SoundEffects.playButtonClick();
    setState(() {
      _selectedPosition = null;
      _selectedHandPiece = pieceType;
      _validMoves = _board.getLegalDropsForPiece(pieceType);
    });
  }

  void _showPromotionChoiceDialog(List<ShogiMove> moves) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ShogiPromotionChoiceDialog(
        moves: moves,
        onMoveSelected: (chosenMove) {
          _executePlayerMove(chosenMove);
        },
      ),
    );
  }

  void _executePlayerMove(ShogiMove move) {
    _applyMove(move, isFromOnline: false);
  }

  void _applyMove(ShogiMove move, {bool isFromOnline = false}) {
    final movingPiece = move.from == null ? null : _board.getPiece(move.from!);
    if (move.capturedPiece != null) {
      SoundEffects.playCapturePiece();
    } else {
      SoundEffects.playMovePiece();
    }

    MoveAnalysis? coachAnalysis;
    if (_isCoachMode) {
      coachAnalysis = GameAnalysisEngine.analyzeShogiMove(
        boardBeforeMove: _board,
        move: move,
        playerSide: _board.turn,
        moveIndex: _board.moveHistory.length,
      );
    }

    setState(() {
      _lastMoveFrom = move.from;
      _lastMoveTo = move.to;
      _animatedPiece = movingPiece;
      _lastCoachAnalysis = coachAnalysis;
      _board.makeMove(move);
      _selectedPosition = null;
      _selectedHandPiece = null;
      _validMoves = [];
    });

    // Broadcast move to opponent if playing online
    if (widget.mode == GameMode.onlineMatch && !isFromOnline) {
      OnlineMultiplayerService.sendMove({
        'isDrop': move.isDrop,
        'fromRow': move.from?.row,
        'fromCol': move.from?.col,
        'toRow': move.to.row,
        'toCol': move.to.col,
        'promote': move.promote,
        'pieceType': move.isDrop ? move.dropPieceType?.name : movingPiece?.type.name,
      });
    }

    _checkGameOverState();

    if (!_gameOver &&
        (widget.mode == GameMode.vsBot || widget.mode == GameMode.coach) &&
        _board.turn != widget.playerSide) {
      _triggerAiMove();
    }
  }

  void _triggerAiMove() async {
    setState(() {
      _isAiThinking = true;
    });

    final minDelay = Future.delayed(
      Duration(milliseconds: 600 + (widget.botDifficulty.index * 250)),
    );
    final aiComputation = ShogiAiEngine.getBestMoveAsync(
      _board,
      widget.botDifficulty,
    );

    final results = await Future.wait([minDelay, aiComputation]);
    if (!mounted || _gameOver) return;

    final bestMove = results[1] as ShogiMove?;

    if (bestMove != null) {
      final movingPiece = bestMove.from == null
          ? null
          : _board.getPiece(bestMove.from!);
      if (bestMove.capturedPiece != null) {
        SoundEffects.playCapturePiece();
      } else {
        SoundEffects.playMovePiece();
      }

      setState(() {
        _lastMoveFrom = bestMove.from;
        _lastMoveTo = bestMove.to;
        _animatedPiece = movingPiece;
        _board.makeMove(bestMove);
        _isAiThinking = false;
      });
      _checkGameOverState();
    } else {
      setState(() {
        _isAiThinking = false;
      });
    }
  }

  void _checkGameOverState() {
    if (_board.isCheck) {
      SoundEffects.playCheck();
    }

    if (_board.isCheckmate) {
      _gameOver = true;
      _matchTimer?.cancel();
      final winner = _board.turn == ShogiPlayer.sente
          ? ShogiPlayer.gote
          : ShogiPlayer.sente;
      final isPlayerWinner =
          widget.mode == GameMode.vsPlayer || widget.playerSide == winner;

      _onGameEnded(
        outcome: isPlayerWinner ? MatchOutcome.win : MatchOutcome.loss,
        title: 'Tsumi! (Skakmat Shogi)',
        message:
            '${winner == ShogiPlayer.sente ? "Sente (先手)" : "Gote (後手)"} memenangkan pertandingan Shogi!',
      );
    }
  }

  void _resign() {
    if (_gameOver) return;
    _gameOver = true;
    _matchTimer?.cancel();
    _onGameEnded(
      outcome: MatchOutcome.loss,
      title: Provider.of<LanguageProvider>(
        context,
        listen: false,
      ).tr('resigned_title'),
      message: Provider.of<LanguageProvider>(
        context,
        listen: false,
      ).tr('resigned_message'),
    );
  }

  MatchOutcome? _lastOutcome;
  int _lastRatingDelta = 0;
  String _lastEndTitle = '';
  String _lastEndMessage = '';

  void _showMatchEndDialog() {
    if (!mounted || _lastOutcome == null) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => MatchEndDialog(
        outcome: _lastOutcome!,
        ratingDelta: _lastRatingDelta,
        gameType: GameType.shogi,
        gameMode: widget.mode,
        title: _lastEndTitle,
        message: _lastEndMessage,
        onAnalyzeGame: () {
          Navigator.pop(ctx);
          _showPostGameAnalysisReport();
        },
        onPlayAgain: () {
          Navigator.pop(ctx);
          _startNewGame();
        },
        onMainMenu: () {
          Navigator.pop(ctx);
          if (mounted) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  Future<void> _onGameEnded({
    required MatchOutcome outcome,
    required String title,
    required String message,
  }) async {
    final authService = Provider.of<AuthService>(context, listen: false);

    int opponentRating = (widget.mode == GameMode.vsBot || widget.mode == GameMode.coach)
        ? widget.botDifficulty.rating
        : 1200;
    String opponentName = widget.mode == GameMode.coach
        ? 'Coach (${widget.coachLevel?.name ?? "Master"})'
        : (widget.mode == GameMode.vsBot
            ? widget.botDifficulty.title
            : 'Player 2');

    final ratingDelta = await authService.recordMatchResult(
      gameType: GameType.shogi,
      gameMode: widget.mode,
      coachLevel: widget.coachLevel,
      outcome: outcome,
      opponentRating: opponentRating,
      opponentName: opponentName,
      totalMoves: _board.moveHistory.length,
    );

    if (!mounted) return;

    _lastOutcome = outcome;
    _lastRatingDelta = ratingDelta;
    _lastEndTitle = title;
    _lastEndMessage = message;

    AdService.instance.showPostMatchInterstitialAd(
      context,
      onAdClosed: () {
        _showMatchEndDialog();
      },
    );
  }

  void _showPostGameAnalysisReport() {
    final report = GameAnalysisEngine.analyzeFullShogiGame(
      moveHistory: _board.moveHistory,
      playerSide: widget.playerSide,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameAnalysisDialog(
        report: report,
        gameType: GameType.shogi,
        player1Name: widget.playerSide == ShogiPlayer.sente ? 'Sente (Anda)' : 'Sente (Lawan)',
        player2Name: widget.playerSide == ShogiPlayer.gote ? 'Gote (Anda)' : 'Gote (Lawan)',
        onBackToMatchEnd: () {
          _showMatchEndDialog();
        },
        onPlayAgain: () => _startNewGame(),
        onMainMenu: () {
          if (mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  void _undoMove() {
    if (_gameOver || _isAiThinking) return;
    if (_board.moveHistory.isEmpty) return;

    final historyLen = _board.moveHistory.length;
    int movesToUndo = 2;
    if (widget.playerSide == ShogiPlayer.sente) {
      if (historyLen == 1) {
        movesToUndo = 1;
      } else if (_board.turn != widget.playerSide) {
        movesToUndo = 1;
      }
    } else {
      // Player is Gote
      if (historyLen <= 2) {
        movesToUndo = 1;
      } else if (_board.turn != widget.playerSide) {
        movesToUndo = 1;
      }
    }

    final targetMoveCount = (historyLen - movesToUndo).clamp(0, historyLen);
    SoundEffects.playMovePiece();

    setState(() {
      _board.rebuildFromHistory(targetMoveCount);
      _selectedPosition = null;
      _selectedHandPiece = null;
      _validMoves = [];
      _lastMoveFrom = _board.moveHistory.isNotEmpty ? _board.moveHistory.last.from : null;
      _lastMoveTo = _board.moveHistory.isNotEmpty ? _board.moveHistory.last.to : null;
      _animatedPiece = null;
      _lastCoachAnalysis = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final lang = Provider.of<LanguageProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final isGotePerspective = widget.playerSide == ShogiPlayer.gote;

    final topPlayerSide = isGotePerspective
        ? ShogiPlayer.sente
        : ShogiPlayer.gote;
    final bottomPlayerSide = isGotePerspective
        ? ShogiPlayer.gote
        : ShogiPlayer.sente;

    final topPlayerName = widget.mode == GameMode.coach
        ? 'Pelatih (${lang.tr("coach_${widget.coachLevel?.name ?? 'medium'}")})'
        : (widget.mode == GameMode.vsBot
            ? widget.botDifficulty.title
            : (isGotePerspective ? 'Pemain 1 (Sente 先手)' : 'Pemain 2 (Gote 後手)'));

    final topPlayerRating = (widget.mode == GameMode.vsBot || widget.mode == GameMode.coach)
        ? widget.botDifficulty.rating
        : 1200;

    final bottomPlayerName = (widget.mode == GameMode.vsBot || widget.mode == GameMode.coach)
        ? (user?.displayName ?? 'Player (Anda)')
        : (isGotePerspective
              ? (user?.displayName ?? 'Pemain 2 (Gote)')
              : (user?.displayName ?? 'Pemain 1 (Sente)'));

    final bottomPlayerRating = user?.shogiRating ?? 1200;

    String statusText;
    Color statusColor = AppColors.textColor(context);

    if (_gameOver) {
      statusText = 'Permainan Berakhir';
      statusColor = AppColors.warning;
    } else if (_isAiThinking) {
      statusText =
          'Bot (${widget.botDifficulty.title}) sedang menganalisis papan...';
      statusColor = AppColors.secondary;
    } else if (_board.isCheck) {
      statusText = 'Ōte! (王手) Raja Terancam!';
      statusColor = AppColors.error;
    } else {
      final isMyTurn =
          widget.mode == GameMode.vsPlayer || _board.turn == widget.playerSide;
      statusText = isMyTurn
          ? 'Giliran Anda (${_board.turn == ShogiPlayer.sente ? "Sente ☗" : "Gote ☖"})'
          : 'Giliran ${_board.turn == ShogiPlayer.sente ? "Sente ☗" : "Gote ☖"}';
      statusColor = _board.turn == ShogiPlayer.sente
          ? const Color(0xFFFBBF24)
          : const Color(0xFFEA580C);
    }

    String titleMode;
    if (widget.mode == GameMode.coach) {
      titleMode = 'Shogi vs ${lang.tr("coach_${widget.coachLevel?.name ?? 'medium'}")}';
    } else if (widget.mode == GameMode.vsBot) {
      titleMode = 'Shogi vs ${widget.botDifficulty.title}';
    } else {
      titleMode = 'Shogi Pass & Play';
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.surface(context),
          elevation: 0,
          title: Row(
            children: [
              const GameEmblemIcon(isChess: false, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titleMode,
                  style: GoogleFonts.cinzel(
                    color: AppColors.textColor(context),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: InteractiveButton(
                onPressed: () => themeProvider.toggleTheme(),
                padding: const EdgeInsets.all(8),
                backgroundColor: Colors.transparent,
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: isDark ? const Color(0xFFFBBF24) : AppColors.secondary,
                  size: 20,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: InteractiveButton(
                onPressed: () {
                  if (_gameOver) return;
                  showDialog(
                    context: context,
                    builder: (ctx) => ConfirmDialog(
                      title: lang.tr('resign_title'),
                      message: lang.tr('resign_message'),
                      confirmText: lang.tr('confirm_resign'),
                      cancelText: lang.tr('cancel'),
                      confirmColor: Colors.redAccent,
                      icon: Icons.flag_rounded,
                      onConfirm: _resign,
                    ),
                  );
                },
                padding: const EdgeInsets.all(8),
                backgroundColor: Colors.transparent,
                child: Icon(
                  Icons.flag_rounded,
                  color: Colors.redAccent.withValues(
                    alpha: _gameOver ? 0.4 : 1,
                  ),
                  size: 20,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
              child: InteractiveButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => ConfirmDialog(
                      title: lang.tr('restart_match'),
                      message: lang.tr('restart_message'),
                      confirmText: lang.tr('restart'),
                      cancelText: lang.tr('cancel'),
                      confirmColor: AppColors.secondary,
                      icon: Icons.refresh_rounded,
                      onConfirm: () => _startNewGame(),
                    ),
                  );
                },
                padding: const EdgeInsets.all(8),
                backgroundColor: Colors.transparent,
                child: Icon(
                  Icons.refresh,
                  color: AppColors.textSecondaryColor(context),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Top Player (Opponent)
              ShogiPlayerHeader(
                name: topPlayerName,
                rating: topPlayerRating,
                player: topPlayerSide,
                timeString: _isUnlimitedTimer
                    ? '∞ ${TimeFormatter.formatSeconds(topPlayerSide == ShogiPlayer.sente ? _senteTimerSeconds : _goteTimerSeconds)}'
                    : TimeFormatter.formatSeconds(
                        topPlayerSide == ShogiPlayer.sente
                            ? _senteTimerSeconds
                            : _goteTimerSeconds,
                      ),
                isCurrentTurn: _board.turn == topPlayerSide,
                isAi: widget.mode == GameMode.vsBot || widget.mode == GameMode.coach,
                handPieces: topPlayerSide == ShogiPlayer.sente
                    ? _board.senteHand
                    : _board.goteHand,
                selectedHandPiece: _selectedHandPiece,
                onHandPieceTap: _onHandPieceTap,
              ),
              if (_isCoachMode && _lastCoachAnalysis != null) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFEA580C).withValues(alpha: 0.6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEA580C).withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.psychology_rounded,
                          color: Color(0xFFFB923C),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang.tr('coach_feedback_bubble'),
                              style: GoogleFonts.cinzel(
                                color: const Color(0xFFFB923C),
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              lang.tr(_lastCoachAnalysis!.coachFeedbackKey),
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 11.5,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: ShogiBoardView(
                    board: _board,
                    selectedPosition: _selectedPosition,
                    validMoves: _validMoves,
                    onSquareTap: _onSquareTap,
                    lastMoveFrom: _lastMoveFrom,
                    lastMoveTo: _lastMoveTo,
                    animatedPiece: _animatedPiece,
                    playerPerspective: widget.playerSide,
                  ),
                ),
              ),
              // Bottom Player (You / Player Side at front bottom)
              ShogiPlayerHeader(
                name: bottomPlayerName,
                rating: bottomPlayerRating,
                player: bottomPlayerSide,
                timeString: _isUnlimitedTimer
                    ? '∞ ${TimeFormatter.formatSeconds(bottomPlayerSide == ShogiPlayer.sente ? _senteTimerSeconds : _goteTimerSeconds)}'
                    : TimeFormatter.formatSeconds(
                        bottomPlayerSide == ShogiPlayer.sente
                            ? _senteTimerSeconds
                            : _goteTimerSeconds,
                      ),
                isCurrentTurn: _board.turn == bottomPlayerSide,
                isAi: false,
                handPieces: bottomPlayerSide == ShogiPlayer.sente
                    ? _board.senteHand
                    : _board.goteHand,
                selectedHandPiece: _selectedHandPiece,
                onHandPieceTap: _onHandPieceTap,
                onUndoMove: (widget.mode == GameMode.vsBot || widget.mode == GameMode.coach) &&
                        _board.moveHistory.isNotEmpty &&
                        !_gameOver
                    ? _undoMove
                    : null,
              ),
              GameStatusBar(statusText: statusText, statusColor: statusColor),
            ],
          ),
        ),
      ),
    );
  }
}
