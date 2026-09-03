import 'package:game_papan/chess/chess_board.dart';
import 'package:game_papan/chess/chess_evaluator.dart';
import 'package:game_papan/chess/chess_piece.dart';
import 'package:game_papan/shogi/shogi_board.dart';
import 'package:game_papan/shogi/shogi_evaluator.dart';
import 'package:game_papan/shogi/shogi_piece.dart';
import 'package:game_papan/shogi/shogi_move.dart';

enum MoveQuality { brilliant, best, good, inaccuracy, mistake, blunder }

class MoveAnalysis {
  final int moveNumber;
  final String moveNotation;
  final MoveQuality quality;
  final int evalBefore;
  final int evalAfter;
  final String coachFeedbackKey;
  final Map<String, String>? feedbackArgs;

  const MoveAnalysis({
    required this.moveNumber,
    required this.moveNotation,
    required this.quality,
    required this.evalBefore,
    required this.evalAfter,
    required this.coachFeedbackKey,
    this.feedbackArgs,
  });
}

class GameAnalysisReport {
  final double accuracyPlayer1;
  final double accuracyPlayer2;
  final int brilliantCount;
  final int bestCount;
  final int goodCount;
  final int inaccuracyCount;
  final int mistakeCount;
  final int blunderCount;
  final String summaryKey;
  final List<MoveAnalysis> moveAnalyses;

  const GameAnalysisReport({
    required this.accuracyPlayer1,
    required this.accuracyPlayer2,
    required this.brilliantCount,
    required this.bestCount,
    required this.goodCount,
    required this.inaccuracyCount,
    required this.mistakeCount,
    required this.blunderCount,
    required this.summaryKey,
    required this.moveAnalyses,
  });
}

class GameAnalysisEngine {
  /// Evaluates a single move in real-time for Chess Coach Mode
  static MoveAnalysis analyzeChessMove({
    required ChessBoard boardBeforeMove,
    required ChessMove move,
    required ChessColor playerColor,
    required int moveIndex,
  }) {
    final evalBefore = ChessEvaluator.evaluate(boardBeforeMove);
    final clonedBoard = boardBeforeMove.clone();
    clonedBoard.makeMove(move);
    final evalAfter = ChessEvaluator.evaluate(clonedBoard);

    // Delta from moving player's perspective
    final isWhite = boardBeforeMove.turn == ChessColor.white;
    final delta = isWhite ? (evalAfter - evalBefore) : (evalBefore - evalAfter);

    MoveQuality quality;
    String feedbackKey;

    if (clonedBoard.isCheckmate) {
      quality = MoveQuality.brilliant;
      feedbackKey = 'coach_chess_checkmate';
    } else if (move.isCastling) {
      quality = MoveQuality.best;
      final castlingKeys = [
        'coach_chess_castling_1',
        'coach_chess_castling_2',
        'coach_chess_castling_3',
      ];
      feedbackKey = castlingKeys[moveIndex % castlingKeys.length];
    } else if (move.promotion != null) {
      quality = MoveQuality.best;
      final promoKeys = [
        'coach_chess_promo_1',
        'coach_chess_promo_2',
      ];
      feedbackKey = promoKeys[moveIndex % promoKeys.length];
    } else if (clonedBoard.isCheck) {
      if (delta >= 100) {
        quality = MoveQuality.brilliant;
        feedbackKey = 'coach_chess_check_sharp';
      } else if (delta >= -80) {
        quality = MoveQuality.best;
        feedbackKey = 'coach_chess_check_good';
      } else {
        quality = MoveQuality.inaccuracy;
        feedbackKey = 'coach_chess_check_premature';
      }
    } else if (delta >= 280 && move.capturedPiece != null) {
      quality = MoveQuality.brilliant;
      final brilliantCaptures = [
        'coach_chess_capture_brilliant_1',
        'coach_chess_capture_brilliant_2',
      ];
      feedbackKey = brilliantCaptures[moveIndex % brilliantCaptures.length];
    } else if (move.capturedPiece != null) {
      if (delta >= 0) {
        quality = MoveQuality.best;
        final goodCaptures = [
          'coach_chess_capture_best_1',
          'coach_chess_capture_best_2',
        ];
        feedbackKey = goodCaptures[moveIndex % goodCaptures.length];
      } else if (delta >= -150) {
        quality = MoveQuality.good;
        feedbackKey = 'coach_chess_trade_fair';
      } else {
        quality = MoveQuality.blunder;
        feedbackKey = 'coach_chess_capture_bad_trade';
      }
    } else if (moveIndex < 6) {
      // Opening phase
      if (delta >= -20) {
        quality = MoveQuality.best;
        final openBest = [
          'coach_chess_open_best_1',
          'coach_chess_open_best_2',
          'coach_chess_open_best_3',
        ];
        feedbackKey = openBest[moveIndex % openBest.length];
      } else if (delta >= -100) {
        quality = MoveQuality.good;
        feedbackKey = 'coach_chess_open_good';
      } else {
        quality = MoveQuality.inaccuracy;
        feedbackKey = 'coach_chess_open_inaccurate';
      }
    } else if (delta >= -20) {
      quality = MoveQuality.best;
      final bestKeys = [
        'coach_chess_best_1',
        'coach_chess_best_2',
        'coach_chess_best_3',
        'coach_chess_best_4',
      ];
      feedbackKey = bestKeys[moveIndex % bestKeys.length];
    } else if (delta >= -110) {
      quality = MoveQuality.good;
      final goodKeys = [
        'coach_chess_good_1',
        'coach_chess_good_2',
        'coach_chess_good_3',
      ];
      feedbackKey = goodKeys[moveIndex % goodKeys.length];
    } else if (delta >= -260) {
      quality = MoveQuality.inaccuracy;
      final inaccKeys = [
        'coach_chess_inacc_1',
        'coach_chess_inacc_2',
        'coach_chess_inacc_3',
      ];
      feedbackKey = inaccKeys[moveIndex % inaccKeys.length];
    } else if (delta >= -520) {
      quality = MoveQuality.mistake;
      final mistakeKeys = [
        'coach_chess_mistake_1',
        'coach_chess_mistake_2',
        'coach_chess_mistake_3',
      ];
      feedbackKey = mistakeKeys[moveIndex % mistakeKeys.length];
    } else {
      quality = MoveQuality.blunder;
      final blunderKeys = [
        'coach_chess_blunder_1',
        'coach_chess_blunder_2',
        'coach_chess_blunder_3',
      ];
      feedbackKey = blunderKeys[moveIndex % blunderKeys.length];
    }

    return MoveAnalysis(
      moveNumber: moveIndex + 1,
      moveNotation: move.notation,
      quality: quality,
      evalBefore: evalBefore,
      evalAfter: evalAfter,
      coachFeedbackKey: feedbackKey,
    );
  }

  /// Evaluates a single move in real-time for Shogi Coach Mode
  static MoveAnalysis analyzeShogiMove({
    required ShogiBoard boardBeforeMove,
    required ShogiMove move,
    required ShogiPlayer playerSide,
    required int moveIndex,
  }) {
    final evalBefore = ShogiEvaluator.evaluate(boardBeforeMove);
    final clonedBoard = boardBeforeMove.clone();
    clonedBoard.makeMove(move);
    final evalAfter = ShogiEvaluator.evaluate(clonedBoard);

    // Delta from moving player's perspective
    final isSente = boardBeforeMove.turn == ShogiPlayer.sente;
    final delta = isSente ? (evalAfter - evalBefore) : (evalBefore - evalAfter);

    MoveQuality quality;
    String feedbackKey;

    if (clonedBoard.isCheckmate) {
      quality = MoveQuality.brilliant;
      feedbackKey = 'coach_shogi_tsumi';
    } else if (move.isDrop) {
      if (clonedBoard.isCheck) {
        quality = MoveQuality.brilliant;
        feedbackKey = 'coach_shogi_drop_check';
      } else if (delta >= 120) {
        quality = MoveQuality.brilliant;
        feedbackKey = 'coach_shogi_drop_vital';
      } else if (delta >= -40) {
        quality = MoveQuality.best;
        final dropBest = [
          'coach_shogi_drop_best_1',
          'coach_shogi_drop_best_2',
        ];
        feedbackKey = dropBest[moveIndex % dropBest.length];
      } else if (delta >= -140) {
        quality = MoveQuality.good;
        feedbackKey = 'coach_shogi_drop_good';
      } else {
        quality = MoveQuality.inaccuracy;
        feedbackKey = 'coach_shogi_drop_waste';
      }
    } else if (move.promote) {
      if (delta >= 150) {
        quality = MoveQuality.brilliant;
        feedbackKey = 'coach_shogi_promote_brilliant';
      } else {
        quality = MoveQuality.best;
        final promoteBest = [
          'coach_shogi_promote_best_1',
          'coach_shogi_promote_best_2',
        ];
        feedbackKey = promoteBest[moveIndex % promoteBest.length];
      }
    } else if (clonedBoard.isCheck) {
      if (delta >= 80) {
        quality = MoveQuality.brilliant;
        feedbackKey = 'coach_shogi_ote_sharp';
      } else {
        quality = MoveQuality.best;
        feedbackKey = 'coach_shogi_ote_standard';
      }
    } else if (delta >= 250 && move.capturedPiece != null) {
      quality = MoveQuality.brilliant;
      feedbackKey = 'coach_shogi_capture_brilliant';
    } else if (move.capturedPiece != null) {
      if (delta >= -30) {
        quality = MoveQuality.best;
        feedbackKey = 'coach_shogi_capture_best';
      } else {
        quality = MoveQuality.good;
        feedbackKey = 'coach_shogi_capture_good';
      }
    } else if (moveIndex < 8) {
      // Opening & Castle building phase in Shogi (Yagura, Mino, etc.)
      if (delta >= -20) {
        quality = MoveQuality.best;
        final openKeys = [
          'coach_shogi_open_best_1',
          'coach_shogi_open_best_2',
          'coach_shogi_open_best_3',
        ];
        feedbackKey = openKeys[moveIndex % openKeys.length];
      } else if (delta >= -110) {
        quality = MoveQuality.good;
        feedbackKey = 'coach_shogi_open_good';
      } else {
        quality = MoveQuality.inaccuracy;
        feedbackKey = 'coach_shogi_open_inaccurate';
      }
    } else if (delta >= -20) {
      quality = MoveQuality.best;
      final bestKeys = [
        'coach_shogi_best_1',
        'coach_shogi_best_2',
        'coach_shogi_best_3',
        'coach_shogi_best_4',
      ];
      feedbackKey = bestKeys[moveIndex % bestKeys.length];
    } else if (delta >= -110) {
      quality = MoveQuality.good;
      final goodKeys = [
        'coach_shogi_good_1',
        'coach_shogi_good_2',
      ];
      feedbackKey = goodKeys[moveIndex % goodKeys.length];
    } else if (delta >= -260) {
      quality = MoveQuality.inaccuracy;
      final inaccKeys = [
        'coach_shogi_inacc_1',
        'coach_shogi_inacc_2',
      ];
      feedbackKey = inaccKeys[moveIndex % inaccKeys.length];
    } else if (delta >= -520) {
      quality = MoveQuality.mistake;
      final mistakeKeys = [
        'coach_shogi_mistake_1',
        'coach_shogi_mistake_2',
      ];
      feedbackKey = mistakeKeys[moveIndex % mistakeKeys.length];
    } else {
      quality = MoveQuality.blunder;
      final blunderKeys = [
        'coach_shogi_blunder_1',
        'coach_shogi_blunder_2',
      ];
      feedbackKey = blunderKeys[moveIndex % blunderKeys.length];
    }

    return MoveAnalysis(
      moveNumber: moveIndex + 1,
      moveNotation: move.notation,
      quality: quality,
      evalBefore: evalBefore,
      evalAfter: evalAfter,
      coachFeedbackKey: feedbackKey,
    );
  }

  /// Complete post-game analysis for Chess
  static GameAnalysisReport analyzeFullChessGame({
    required List<ChessMove> moveHistory,
    required ChessColor playerColor,
  }) {
    final replayBoard = ChessBoard();
    final analyses = <MoveAnalysis>[];

    int brilliant = 0;
    int best = 0;
    int good = 0;
    int inaccuracy = 0;
    int mistake = 0;
    int blunder = 0;

    int p1ScoreTotal = 0;
    int p1MoveCount = 0;
    int p2ScoreTotal = 0;
    int p2MoveCount = 0;

    for (int i = 0; i < moveHistory.length; i++) {
      final move = moveHistory[i];
      final isWhiteMove = replayBoard.turn == ChessColor.white;
      final analysis = analyzeChessMove(
        boardBeforeMove: replayBoard,
        move: move,
        playerColor: isWhiteMove ? ChessColor.white : ChessColor.black,
        moveIndex: i,
      );

      analyses.add(analysis);

      int moveAccuracy = 100;
      switch (analysis.quality) {
        case MoveQuality.brilliant:
          brilliant++;
          moveAccuracy = 100;
          break;
        case MoveQuality.best:
          best++;
          moveAccuracy = 100;
          break;
        case MoveQuality.good:
          good++;
          moveAccuracy = 85;
          break;
        case MoveQuality.inaccuracy:
          inaccuracy++;
          moveAccuracy = 65;
          break;
        case MoveQuality.mistake:
          mistake++;
          moveAccuracy = 40;
          break;
        case MoveQuality.blunder:
          blunder++;
          moveAccuracy = 15;
          break;
      }

      if (isWhiteMove) {
        p1ScoreTotal += moveAccuracy;
        p1MoveCount++;
      } else {
        p2ScoreTotal += moveAccuracy;
        p2MoveCount++;
      }

      replayBoard.makeMove(move);
    }

    final rawP1 = p1MoveCount == 0 ? 50.0 : (p1ScoreTotal / p1MoveCount);
    final rawP2 = p2MoveCount == 0 ? 50.0 : (p2ScoreTotal / p2MoveCount);

    final sumRaw = rawP1 + rawP2;
    final accP1 = sumRaw == 0 ? 50.0 : (rawP1 / sumRaw) * 100.0;
    final accP2 = 100.0 - accP1;

    String summaryKey = 'analysis_summary_balanced';
    if (accP1 >= 65.0 || accP2 >= 65.0) {
      summaryKey = 'analysis_summary_mastery';
    } else if (blunder > 2) {
      summaryKey = 'analysis_summary_blunders';
    } else if (mistake > 2) {
      summaryKey = 'analysis_summary_tactical';
    }

    return GameAnalysisReport(
      accuracyPlayer1: double.parse(accP1.toStringAsFixed(1)),
      accuracyPlayer2: double.parse(accP2.toStringAsFixed(1)),
      brilliantCount: brilliant,
      bestCount: best,
      goodCount: good,
      inaccuracyCount: inaccuracy,
      mistakeCount: mistake,
      blunderCount: blunder,
      summaryKey: summaryKey,
      moveAnalyses: analyses,
    );
  }

  /// Complete post-game analysis for Shogi
  static GameAnalysisReport analyzeFullShogiGame({
    required List<ShogiMove> moveHistory,
    required ShogiPlayer playerSide,
  }) {
    final replayBoard = ShogiBoard();
    final analyses = <MoveAnalysis>[];

    int brilliant = 0;
    int best = 0;
    int good = 0;
    int inaccuracy = 0;
    int mistake = 0;
    int blunder = 0;

    int p1ScoreTotal = 0;
    int p1MoveCount = 0;
    int p2ScoreTotal = 0;
    int p2MoveCount = 0;

    for (int i = 0; i < moveHistory.length; i++) {
      final move = moveHistory[i];
      final isSenteMove = replayBoard.turn == ShogiPlayer.sente;
      final analysis = analyzeShogiMove(
        boardBeforeMove: replayBoard,
        move: move,
        playerSide: isSenteMove ? ShogiPlayer.sente : ShogiPlayer.gote,
        moveIndex: i,
      );

      analyses.add(analysis);

      int moveAccuracy = 100;
      switch (analysis.quality) {
        case MoveQuality.brilliant:
          brilliant++;
          moveAccuracy = 100;
          break;
        case MoveQuality.best:
          best++;
          moveAccuracy = 100;
          break;
        case MoveQuality.good:
          good++;
          moveAccuracy = 85;
          break;
        case MoveQuality.inaccuracy:
          inaccuracy++;
          moveAccuracy = 65;
          break;
        case MoveQuality.mistake:
          mistake++;
          moveAccuracy = 40;
          break;
        case MoveQuality.blunder:
          blunder++;
          moveAccuracy = 15;
          break;
      }

      if (isSenteMove) {
        p1ScoreTotal += moveAccuracy;
        p1MoveCount++;
      } else {
        p2ScoreTotal += moveAccuracy;
        p2MoveCount++;
      }

      replayBoard.makeMove(move);
    }

    final rawShogiP1 = p1MoveCount == 0 ? 50.0 : (p1ScoreTotal / p1MoveCount);
    final rawShogiP2 = p2MoveCount == 0 ? 50.0 : (p2ScoreTotal / p2MoveCount);

    final sumShogiRaw = rawShogiP1 + rawShogiP2;
    final accShogiP1 = sumShogiRaw == 0 ? 50.0 : (rawShogiP1 / sumShogiRaw) * 100.0;
    final accShogiP2 = 100.0 - accShogiP1;

    String summaryKey = 'analysis_summary_balanced';
    if (accShogiP1 >= 65.0 || accShogiP2 >= 65.0) {
      summaryKey = 'analysis_summary_mastery';
    } else if (blunder > 2) {
      summaryKey = 'analysis_summary_blunders';
    } else if (mistake > 2) {
      summaryKey = 'analysis_summary_tactical';
    }

    return GameAnalysisReport(
      accuracyPlayer1: double.parse(accShogiP1.toStringAsFixed(1)),
      accuracyPlayer2: double.parse(accShogiP2.toStringAsFixed(1)),
      brilliantCount: brilliant,
      bestCount: best,
      goodCount: good,
      inaccuracyCount: inaccuracy,
      mistakeCount: mistake,
      blunderCount: blunder,
      summaryKey: summaryKey,
      moveAnalyses: analyses,
    );
  }
}
