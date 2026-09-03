import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:game_papan/chess/chess_ai.dart';
import 'package:game_papan/chess/chess_board.dart';
import 'package:game_papan/chess/chess_piece.dart';
import 'package:game_papan/models/bot_difficulty.dart';
import 'package:game_papan/models/game_enums.dart';
import 'package:game_papan/services/ad_service.dart';
import 'package:game_papan/services/auth_service.dart';
import 'package:game_papan/services/language_provider.dart';
import 'package:game_papan/services/sound_effects.dart';
import 'package:game_papan/theme/app_colors.dart';
import 'package:game_papan/theme/theme_provider.dart';
import 'package:game_papan/utils/time_formatter.dart';
import 'package:game_papan/widgets/game_emblem_icon.dart';
import 'package:game_papan/widgets/chess_board_view.dart';
import 'package:game_papan/widgets/chess_player_header.dart';
import 'package:game_papan/widgets/game_status_bar.dart';
import 'package:game_papan/widgets/match_end_dialog.dart';
import 'package:game_papan/widgets/confirm_dialog.dart';
import 'package:game_papan/services/game_analysis_engine.dart';
import 'package:game_papan/services/online_multiplayer_service.dart';
import 'package:game_papan/widgets/game_analysis_dialog.dart';
import 'package:game_papan/widgets/chess_promotion_choice_dialog.dart';
import 'package:game_papan/widgets/interactive_button.dart';

class ChessGameScreen extends StatefulWidget {
  final GameMode mode;
  final BotDifficulty botDifficulty;
  final CoachLevel? coachLevel;
  final ChessColor playerColor;
  final int durationMinutes; // 0 = unlimited

  const ChessGameScreen({
    super.key,
    required this.mode,
    this.botDifficulty = BotDifficulty.intermediate,
    this.coachLevel,
    this.playerColor = ChessColor.white,
    this.durationMinutes = 10,
  });

  @override
  State<ChessGameScreen> createState() => _ChessGameScreenState();
}

class _ChessGameScreenState extends State<ChessGameScreen> {
  late ChessBoard _board;
  ChessPosition? _selectedPosition;
  List<ChessMove> _validMovesForSelected = [];
  bool _isAiThinking = false;
  bool _gameOver = false;
  late int _whiteTimerSeconds;
  late int _blackTimerSeconds;
  Timer? _matchTimer;
  ChessPosition? _lastMoveFrom;
  ChessPosition? _lastMoveTo;
  ChessPiece? _animatedPiece;
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
      if (event.containsKey('fromCol') && event.containsKey('toCol')) {
        final from = ChessPosition(event['fromCol'], event['fromRow']);
        final to = ChessPosition(event['toCol'], event['toRow']);
        final promoType = event['promotion'] != null
            ? ChessPieceType.values.byName(event['promotion'])
            : null;

        final legalMoves = _board.getAllLegalMoves(_board.turn);
        final matchMove = legalMoves.firstWhere(
          (m) => m.from == from && m.to == to,
          orElse: () => ChessMove(
            from: from,
            to: to,
            promotion: promoType,
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
      _board = ChessBoard();
      _selectedPosition = null;
      _validMovesForSelected = [];
      _isAiThinking = false;
      _gameOver = false;
      _whiteTimerSeconds = initialSeconds;
      _blackTimerSeconds = initialSeconds;
      _lastMoveFrom = null;
      _lastMoveTo = null;
      _animatedPiece = null;
      _lastCoachAnalysis = null;
    });

    _startTimer();

    if ((widget.mode == GameMode.vsBot || widget.mode == GameMode.coach) &&
        widget.playerColor == ChessColor.black) {
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
          if (_board.turn == ChessColor.white) {
            _whiteTimerSeconds++;
          } else {
            _blackTimerSeconds++;
          }
        } else {
          if (_board.turn == ChessColor.white) {
            if (_whiteTimerSeconds > 0) _whiteTimerSeconds--;
            if (_whiteTimerSeconds == 0) _handleTimeout(ChessColor.white);
          } else {
            if (_blackTimerSeconds > 0) _blackTimerSeconds--;
            if (_blackTimerSeconds == 0) _handleTimeout(ChessColor.black);
          }
        }
      });
    });
  }

  void _handleTimeout(ChessColor timedOutColor) {
    if (_gameOver) return;
    _gameOver = true;
    _matchTimer?.cancel();

    final winnerColor = timedOutColor == ChessColor.white
        ? ChessColor.black
        : ChessColor.white;
    final isPlayerWin =
        widget.mode == GameMode.vsPlayer || widget.playerColor == winnerColor;

    _onGameEnded(
      outcome: isPlayerWin ? MatchOutcome.win : MatchOutcome.loss,
      title: 'Waktu Habis!',
      message:
          '${timedOutColor == ChessColor.white ? "Putih" : "Hitam"} kehabisan waktu.',
    );
  }

  void _onSquareTap(int row, int col) {
    if (_gameOver || _isAiThinking) return;

    if ((widget.mode == GameMode.vsBot ||
            widget.mode == GameMode.coach ||
            widget.mode == GameMode.onlineMatch) &&
        _board.turn != widget.playerColor) {
      return;
    }

    final tappedPos = ChessPosition(row, col);
    final tappedPiece = _board.getPiece(tappedPos);

    if (_selectedPosition == tappedPos) {
      setState(() {
        _selectedPosition = null;
        _validMovesForSelected = [];
      });
      return;
    }

    if (_selectedPosition != null) {
      final matchingMoves = _validMovesForSelected
          .where((m) => m.to == tappedPos)
          .toList();

      if (matchingMoves.isNotEmpty) {
        final movingPiece = _board.getPiece(_selectedPosition!);
        final isPawn = movingPiece?.type == ChessPieceType.pawn;
        final isPromotionRank = (movingPiece?.color == ChessColor.white && tappedPos.row == 0) ||
            (movingPiece?.color == ChessColor.black && tappedPos.row == 7);

        if (isPawn && isPromotionRank) {
          _showPromotionChoiceDialog(matchingMoves, movingPiece!.color);
          return;
        }

        _executePlayerMove(matchingMoves.first);
        return;
      }
    }

    if (tappedPiece != null && tappedPiece.color == _board.turn) {
      SoundEffects.playButtonClick();
      setState(() {
        _selectedPosition = tappedPos;
        _validMovesForSelected = _board.getLegalMovesForPosition(tappedPos);
      });
    } else {
      setState(() {
        _selectedPosition = null;
        _validMovesForSelected = [];
      });
    }
  }

  void _showPromotionChoiceDialog(
    List<ChessMove> moves,
    ChessColor pawnColor,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ChessPromotionChoiceDialog(
        color: pawnColor,
        onPieceSelected: (selectedPieceType) {
          final chosenMove = moves.firstWhere(
            (m) => m.promotion == selectedPieceType,
            orElse: () => moves.firstWhere(
              (m) => m.promotion != null,
              orElse: () => moves.first,
            ),
          );

          final actualMove = chosenMove.promotion != null
              ? chosenMove
              : ChessMove(
                  from: chosenMove.from,
                  to: chosenMove.to,
                  capturedPiece: chosenMove.capturedPiece,
                  promotion: selectedPieceType,
                  isCastling: chosenMove.isCastling,
                  isEnPassant: chosenMove.isEnPassant,
                );

          _executePlayerMove(actualMove);
        },
      ),
    );
  }

  void _executePlayerMove(ChessMove move) {
    _applyMove(move, isFromOnline: false);
  }

  void _applyMove(ChessMove move, {bool isFromOnline = false}) {
    final movingPiece = _board.getPiece(move.from);
    ChessMove finalMove = move;
    if (move.promotion == null) {
      final piece = _board.getPiece(move.from);
      if (piece?.type == ChessPieceType.pawn) {
        if ((piece!.color == ChessColor.white && move.to.row == 0) ||
            (piece.color == ChessColor.black && move.to.row == 7)) {
          finalMove = ChessMove(
            from: move.from,
            to: move.to,
            capturedPiece: move.capturedPiece,
            promotion: ChessPieceType.queen,
            isCastling: move.isCastling,
            isEnPassant: move.isEnPassant,
          );
        }
      }
    }

    if (finalMove.capturedPiece != null || finalMove.isEnPassant) {
      SoundEffects.playCapturePiece();
    } else {
      SoundEffects.playMovePiece();
    }

    MoveAnalysis? coachAnalysis;
    if (_isCoachMode && movingPiece != null) {
      coachAnalysis = GameAnalysisEngine.analyzeChessMove(
        boardBeforeMove: _board,
        move: finalMove,
        playerColor: movingPiece.color,
        moveIndex: _board.moveHistory.length,
      );
    }

    setState(() {
      _lastMoveFrom = finalMove.from;
      _lastMoveTo = finalMove.to;
      _animatedPiece = movingPiece;
      _lastCoachAnalysis = coachAnalysis;
      _board.makeMove(finalMove);
      _selectedPosition = null;
      _validMovesForSelected = [];
    });

    // Broadcast move to opponent if playing online
    if (widget.mode == GameMode.onlineMatch && !isFromOnline) {
      OnlineMultiplayerService.sendMove({
        'fromCol': finalMove.from.col,
        'fromRow': finalMove.from.row,
        'toCol': finalMove.to.col,
        'toRow': finalMove.to.row,
        'promotion': finalMove.promotion?.name,
      });
    }

    _checkGameOverState();

    if (!_gameOver &&
        (widget.mode == GameMode.vsBot || widget.mode == GameMode.coach) &&
        _board.turn != widget.playerColor) {
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
    final aiComputation = ChessAiEngine.getBestMoveAsync(
      _board,
      widget.botDifficulty,
    );

    final results = await Future.wait([minDelay, aiComputation]);
    if (!mounted || _gameOver) return;

    final bestMove = results[1] as ChessMove?;

    if (bestMove != null) {
      final movingPiece = _board.getPiece(bestMove.from);
      if (bestMove.capturedPiece != null || bestMove.isEnPassant) {
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
      final winnerColor = _board.turn == ChessColor.white
          ? ChessColor.black
          : ChessColor.white;
      final isPlayerWinner =
          widget.mode == GameMode.vsPlayer || widget.playerColor == winnerColor;

      _onGameEnded(
        outcome: isPlayerWinner ? MatchOutcome.win : MatchOutcome.loss,
        title: 'Checkmate! (Skakmat)',
        message:
            '${winnerColor == ChessColor.white ? "Putih" : "Hitam"} memenangkan pertandingan catur!',
      );
    } else if (_board.isStalemate) {
      _gameOver = true;
      _matchTimer?.cancel();
      _onGameEnded(
        outcome: MatchOutcome.draw,
        title: 'Draw (Remis / Stalemate)',
        message: 'Permainan berakhir seri tanpa pemenang.',
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
        gameType: GameType.chess,
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
      gameType: GameType.chess,
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
    final report = GameAnalysisEngine.analyzeFullChessGame(
      moveHistory: _board.moveHistory,
      playerColor: widget.playerColor,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameAnalysisDialog(
        report: report,
        gameType: GameType.chess,
        player1Name: widget.playerColor == ChessColor.white ? 'Putih (Anda)' : 'Putih (Lawan)',
        player2Name: widget.playerColor == ChessColor.black ? 'Hitam (Anda)' : 'Hitam (Lawan)',
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
    // If vsBot or Coach mode, undo both the Bot's move and the Player's move (2 moves)
    // If it's already player's turn, undo 2 moves to get back to previous player move.
    // If only 1 move has been played (e.g. White just played first move), undo 1 move.
    int movesToUndo = 2;
    if (widget.playerColor == ChessColor.white) {
      if (historyLen == 1) {
        movesToUndo = 1;
      } else if (_board.turn != widget.playerColor) {
        // AI hasn't moved yet or currently player's turn right after AI
        movesToUndo = 1;
      }
    } else {
      // Player is Black
      if (historyLen <= 2) {
        movesToUndo = 1;
      } else if (_board.turn != widget.playerColor) {
        movesToUndo = 1;
      }
    }

    final targetMoveCount = (historyLen - movesToUndo).clamp(0, historyLen);
    SoundEffects.playMovePiece();

    setState(() {
      _board.rebuildFromHistory(targetMoveCount);
      _selectedPosition = null;
      _validMovesForSelected = [];
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

    final isBlackPerspective = widget.playerColor == ChessColor.black;

    // Top player is the opponent relative to active player perspective
    final topPlayerColor = isBlackPerspective
        ? ChessColor.white
        : ChessColor.black;
    final bottomPlayerColor = isBlackPerspective
        ? ChessColor.black
        : ChessColor.white;

    final topPlayerName = widget.mode == GameMode.coach
        ? 'Pelatih (${lang.tr("coach_${widget.coachLevel?.name ?? 'medium'}")})'
        : (widget.mode == GameMode.vsBot
            ? widget.botDifficulty.title
            : (isBlackPerspective ? 'Pemain 1 (Putih)' : 'Pemain 2 (Hitam)'));

    final topPlayerRating = (widget.mode == GameMode.vsBot || widget.mode == GameMode.coach)
        ? widget.botDifficulty.rating
        : 1200;

    final bottomPlayerName = (widget.mode == GameMode.vsBot || widget.mode == GameMode.coach)
        ? (user?.displayName ?? 'Player (Anda)')
        : (isBlackPerspective
              ? (user?.displayName ?? 'Pemain 2 (Hitam)')
              : (user?.displayName ?? 'Pemain 1 (Putih)'));

    final bottomPlayerRating = user?.chessRating ?? 1200;

    String statusText;
    Color statusColor = AppColors.textColor(context);

    if (_gameOver) {
      statusText = 'Permainan Berakhir';
      statusColor = AppColors.warning;
    } else if (_isAiThinking) {
      statusText =
          'Bot (${widget.botDifficulty.title}) sedang menganalisis langkah...';
      statusColor = AppColors.secondary;
    } else if (_board.isCheck) {
      statusText =
          'SKAK! Raja ${_board.turn == ChessColor.white ? "Putih" : "Hitam"} Terancam!';
      statusColor = AppColors.error;
    } else {
      final isMyTurn =
          widget.mode == GameMode.vsPlayer || _board.turn == widget.playerColor;
      statusText = isMyTurn
          ? 'Giliran Anda (${_board.turn == ChessColor.white ? "Putih" : "Hitam"})'
          : 'Giliran ${_board.turn == ChessColor.white ? "Putih" : "Hitam"}';
      statusColor = _board.turn == ChessColor.white
          ? const Color(0xFFFBBF24)
          : const Color(0xFFD97706);
    }

    String titleMode;
    if (widget.mode == GameMode.coach) {
      titleMode = 'Catur vs ${lang.tr("coach_${widget.coachLevel?.name ?? 'medium'}")}';
    } else if (widget.mode == GameMode.vsBot) {
      titleMode = 'Catur vs ${widget.botDifficulty.title}';
    } else {
      titleMode = 'Catur Pass & Play';
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
              const GameEmblemIcon(isChess: true, size: 22),
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
                  color: isDark ? const Color(0xFFFBBF24) : AppColors.primary,
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
                      confirmColor: AppColors.primary,
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
              ChessPlayerHeader(
                name: topPlayerName,
                rating: topPlayerRating,
                color: topPlayerColor,
                timeString: _isUnlimitedTimer
                    ? '∞ ${TimeFormatter.formatSeconds(topPlayerColor == ChessColor.white ? _whiteTimerSeconds : _blackTimerSeconds)}'
                    : TimeFormatter.formatSeconds(
                        topPlayerColor == ChessColor.white
                            ? _whiteTimerSeconds
                            : _blackTimerSeconds,
                      ),
                isCurrentTurn: _board.turn == topPlayerColor,
                isAi: widget.mode == GameMode.vsBot || widget.mode == GameMode.coach,
                capturedPieces: topPlayerColor == ChessColor.white
                    ? _board.capturedBlack
                    : _board.capturedWhite,
              ),
              if (_isCoachMode && _lastCoachAnalysis != null) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
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
                          color: const Color(0xFFD97706).withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.psychology_rounded,
                          color: Color(0xFFFBBF24),
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
                                color: const Color(0xFFFBBF24),
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
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: ChessBoardView(
                    board: _board,
                    selectedPosition: _selectedPosition,
                    validMovesForSelected: _validMovesForSelected,
                    onSquareTap: _onSquareTap,
                    lastMoveFrom: _lastMoveFrom,
                    lastMoveTo: _lastMoveTo,
                    animatedPiece: _animatedPiece,
                    playerPerspective: widget.playerColor,
                  ),
                ),
              ),
              // Bottom Player (You / Player Side at front bottom)
              ChessPlayerHeader(
                name: bottomPlayerName,
                rating: bottomPlayerRating,
                color: bottomPlayerColor,
                timeString: _isUnlimitedTimer
                    ? '∞ ${TimeFormatter.formatSeconds(bottomPlayerColor == ChessColor.white ? _whiteTimerSeconds : _blackTimerSeconds)}'
                    : TimeFormatter.formatSeconds(
                        bottomPlayerColor == ChessColor.white
                            ? _whiteTimerSeconds
                            : _blackTimerSeconds,
                      ),
                isCurrentTurn: _board.turn == bottomPlayerColor,
                isAi: false,
                capturedPieces: bottomPlayerColor == ChessColor.white
                    ? _board.capturedBlack
                    : _board.capturedWhite,
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
