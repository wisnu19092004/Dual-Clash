import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:game_papan/chess/chess_board.dart';
import 'package:game_papan/chess/chess_piece.dart';
import 'package:game_papan/chess/chess_evaluator.dart';
import 'package:game_papan/models/bot_difficulty.dart';

class ChessAiEngine {
  static final Random _random = Random();

  /// Asynchronously finds best move using compute / background Isolate to never freeze the UI thread or timers.
  static Future<ChessMove?> getBestMoveAsync(ChessBoard board, BotDifficulty difficulty) async {
    // Clone before passing to compute
    final clonedBoard = board.clone();
    return compute(_computeBestMoveWorker, {
      'board': clonedBoard,
      'difficulty': difficulty,
    });
  }

  static ChessMove? _computeBestMoveWorker(Map<String, dynamic> params) {
    final board = params['board'] as ChessBoard;
    final difficulty = params['difficulty'] as BotDifficulty;
    return getBestMove(board, difficulty);
  }

  static ChessMove? getBestMove(ChessBoard board, BotDifficulty difficulty) {
    final legalMoves = board.getAllLegalMoves(board.turn);
    if (legalMoves.isEmpty) return null;

    // Beginner Bot (Rating 800) - 70% random, 30% capture greedy
    if (difficulty == BotDifficulty.beginner) {
      if (_random.nextDouble() < 0.7) {
        return legalMoves[_random.nextInt(legalMoves.length)];
      }
      final captures = legalMoves.where((m) => m.capturedPiece != null).toList();
      if (captures.isNotEmpty) {
        return captures[_random.nextInt(captures.length)];
      }
      return legalMoves[_random.nextInt(legalMoves.length)];
    }

    // Novice Bot (Rating 1000) - Depth 1 search with noise
    if (difficulty == BotDifficulty.novice) {
      if (_random.nextDouble() < 0.3) {
        return legalMoves[_random.nextInt(legalMoves.length)];
      }
      return _getAlphaBetaMove(board, depth: 1, addNoise: true);
    }

    // Intermediate Bot (Rating 1300) - Depth 2 search
    if (difficulty == BotDifficulty.intermediate) {
      return _getAlphaBetaMove(board, depth: 2, addNoise: true);
    }

    // Advanced Bot (Rating 1600) - Depth 3 search with smart pruning
    if (difficulty == BotDifficulty.advanced) {
      return _getAlphaBetaMove(board, depth: 3, addNoise: false, smartOrder: true, maxBranching: 30);
    }

    // Expert Bot (Rating 2000) - Depth 4 + Move Ordering
    if (difficulty == BotDifficulty.expert) {
      return _getAlphaBetaMove(board, depth: 4, addNoise: false, smartOrder: true, maxBranching: 25);
    }

    // Grandmaster Bot (Rating 2400) - Depth 5 search with highly disciplined move ordering
    return _getAlphaBetaMove(board, depth: 5, addNoise: false, smartOrder: true, maxBranching: 22);
  }

  static ChessMove _getAlphaBetaMove(
    ChessBoard board, {
    required int depth,
    bool addNoise = false,
    bool smartOrder = false,
    int? maxBranching,
  }) {
    final isWhite = board.turn == ChessColor.white;
    int bestScore = isWhite ? -9999999 : 9999999;
    ChessMove? bestMove;

    var moves = board.getAllLegalMoves(board.turn);
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
        !isWhite,
        maxBranching,
      );

      if (addNoise) {
        score += _random.nextInt(40) - 20;
      }

      if (isWhite) {
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
    ChessBoard board,
    int depth,
    int alpha,
    int beta,
    bool isMaximizing,
    int? maxBranching,
  ) {
    if (depth <= 0 || board.isCheckmate || board.isStalemate) {
      return ChessEvaluator.evaluate(board);
    }

    var moves = _orderMoves(board.getAllLegalMoves(board.turn));
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

  static List<ChessMove> _orderMoves(List<ChessMove> moves) {
    final sorted = List<ChessMove>.from(moves);
    sorted.sort((a, b) {
      int scoreA = 0;
      int scoreB = 0;

      if (a.capturedPiece != null) scoreA += a.capturedPiece!.baseValue * 10;
      if (a.promotion != null) scoreA += 800;

      if (b.capturedPiece != null) scoreB += b.capturedPiece!.baseValue * 10;
      if (b.promotion != null) scoreB += 800;

      return scoreB.compareTo(scoreA);
    });
    return sorted;
  }
}
