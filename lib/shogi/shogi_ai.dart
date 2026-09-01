import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:game_papan/models/bot_difficulty.dart';
import 'package:game_papan/shogi/shogi_board.dart';
import 'package:game_papan/shogi/shogi_piece.dart';
import 'package:game_papan/shogi/shogi_move.dart';
import 'package:game_papan/shogi/shogi_evaluator.dart';

class ShogiAiEngine {
  static final Random _random = Random();

  /// Asynchronously finds best move using compute / background Isolate to prevent UI thread freezing.
  static Future<ShogiMove?> getBestMoveAsync(ShogiBoard board, BotDifficulty difficulty) async {
    final clonedBoard = board.clone();
    return compute(_computeBestMoveWorker, {
      'board': clonedBoard,
      'difficulty': difficulty,
    });
  }

  static ShogiMove? _computeBestMoveWorker(Map<String, dynamic> params) {
    final board = params['board'] as ShogiBoard;
    final difficulty = params['difficulty'] as BotDifficulty;
    return getBestMove(board, difficulty);
  }

  static ShogiMove? getBestMove(ShogiBoard board, BotDifficulty difficulty) {
    final legalMoves = board.getAllLegalMoves();
    if (legalMoves.isEmpty) return null;

    if (difficulty == BotDifficulty.beginner) {
      if (_random.nextDouble() < 0.7) {
        return legalMoves[_random.nextInt(legalMoves.length)];
      }
      final captures = legalMoves.where((m) => m.capturedPiece != null || m.promote).toList();
      if (captures.isNotEmpty) {
        return captures[_random.nextInt(captures.length)];
      }
      return legalMoves[_random.nextInt(legalMoves.length)];
    }

    if (difficulty == BotDifficulty.novice) {
      if (_random.nextDouble() < 0.35) {
        return legalMoves[_random.nextInt(legalMoves.length)];
      }
      return _getAlphaBetaMove(board, depth: 1, addNoise: true);
    }

    if (difficulty == BotDifficulty.intermediate) {
      return _getAlphaBetaMove(board, depth: 2, addNoise: true, maxBranching: 20);
    }

    if (difficulty == BotDifficulty.advanced) {
      return _getAlphaBetaMove(board, depth: 2, addNoise: false, smartOrder: true, maxBranching: 25);
    }

    if (difficulty == BotDifficulty.expert) {
      return _getAlphaBetaMove(board, depth: 3, addNoise: false, smartOrder: true, maxBranching: 20);
    }

    // Grandmaster Bot
    return _getAlphaBetaMove(board, depth: 3, addNoise: false, smartOrder: true, maxBranching: 22);
  }

  static ShogiMove _getAlphaBetaMove(
    ShogiBoard board, {
    required int depth,
    bool addNoise = false,
    bool smartOrder = false,
    int? maxBranching,
  }) {
    final isSente = board.turn == ShogiPlayer.sente;
    int bestScore = isSente ? -9999999 : 9999999;
    ShogiMove? bestMove;

    var moves = board.getAllLegalMoves();
    if (smartOrder) {
      moves = _orderMoves(moves);
    } else {
      moves.shuffle(_random);
    }

    if (maxBranching != null && moves.length > maxBranching) {
      moves = moves.sublist(0, maxBranching);
    }

    for (final move in moves) {
      final cloneBoard = board.clone();
      cloneBoard.makeMove(move);

      int score = _minimax(
        cloneBoard,
        depth - 1,
        -9999999,
        9999999,
        !isSente,
        maxBranching,
      );

      if (addNoise) {
        score += _random.nextInt(50) - 25;
      }

      if (isSente) {
        if (score > bestScore) {
          bestScore = score;
          bestMove = move;
        }
      } else {
        if (score < bestScore) {
          bestScore = score;
          bestMove = move;
        }
      }
    }

    return bestMove ?? moves.first;
  }

  static int _minimax(
    ShogiBoard board,
    int depth,
    int alpha,
    int beta,
    bool isMaximizing,
    int? maxBranching,
  ) {
    if (depth <= 0 || board.isCheckmate) {
      return ShogiEvaluator.evaluate(board);
    }

    var moves = _orderMoves(board.getAllLegalMoves());
    if (maxBranching != null && moves.length > maxBranching) {
      moves = moves.sublist(0, maxBranching);
    }

    if (isMaximizing) {
      int maxEval = -9999999;
      for (final move in moves) {
        final clone = board.clone();
        clone.makeMove(move);
        final eval = _minimax(clone, depth - 1, alpha, beta, false, maxBranching);
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      int minEval = 9999999;
      for (final move in moves) {
        final clone = board.clone();
        clone.makeMove(move);
        final eval = _minimax(clone, depth - 1, alpha, beta, true, maxBranching);
        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }

  static List<ShogiMove> _orderMoves(List<ShogiMove> moves) {
    final sorted = List<ShogiMove>.from(moves);
    sorted.sort((a, b) {
      int scoreA = 0;
      int scoreB = 0;

      if (a.capturedPiece != null) scoreA += a.capturedPiece!.baseValue * 10;
      if (a.promote) scoreA += 500;
      if (a.isDrop) scoreA += 100;

      if (b.capturedPiece != null) scoreB += b.capturedPiece!.baseValue * 10;
      if (b.promote) scoreB += 500;
      if (b.isDrop) scoreB += 100;

      return scoreB.compareTo(scoreA);
    });
    return sorted;
  }
}
