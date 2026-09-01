import 'package:flutter_test/flutter_test.dart';
import 'package:game_papan/chess/chess_ai.dart';
import 'package:game_papan/chess/chess_board.dart';
import 'package:game_papan/chess/chess_piece.dart';
import 'package:game_papan/models/bot_difficulty.dart';
import 'package:game_papan/models/game_enums.dart';
import 'package:game_papan/services/elo_calculator.dart';
import 'package:game_papan/shogi/shogi_ai.dart';
import 'package:game_papan/shogi/shogi_board.dart';

void main() {
  group('ELO Rating System Tests', () {
    test('Rating stays unchanged when playing vs Bot', () {
      final deltaWin = EloCalculator.calculateRatingDelta(
        playerRating: 1200,
        opponentRating: 1600,
        outcome: MatchOutcome.win,
        gameMode: GameMode.vsBot,
      );
      expect(deltaWin, equals(0));

      final deltaLoss = EloCalculator.calculateRatingDelta(
        playerRating: 1200,
        opponentRating: 800,
        outcome: MatchOutcome.loss,
        gameMode: GameMode.vsBot,
      );
      expect(deltaLoss, equals(0));
    });

    test('Rating increases on win and decreases on loss in vs Player mode', () {
      final deltaWin = EloCalculator.calculateRatingDelta(
        playerRating: 1200,
        opponentRating: 1200,
        outcome: MatchOutcome.win,
        gameMode: GameMode.vsPlayer,
      );
      expect(deltaWin, greaterThan(0));

      final deltaLoss = EloCalculator.calculateRatingDelta(
        playerRating: 1200,
        opponentRating: 1200,
        outcome: MatchOutcome.loss,
        gameMode: GameMode.vsPlayer,
      );
      expect(deltaLoss, lessThan(0));
    });
  });

  group('Chess Core Logic Tests', () {
    test('Initial Chess Board has 20 legal moves for White', () {
      final board = ChessBoard();
      final moves = board.getAllLegalMoves(ChessColor.white);
      // 16 pawn moves (8 single, 8 double) + 4 knight moves = 20 moves
      expect(moves.length, equals(20));
    });

    test('Chess AI selects a legal move', () {
      final board = ChessBoard();
      final move = ChessAiEngine.getBestMove(board, BotDifficulty.intermediate);
      expect(move, isNotNull);
      expect(board.getPiece(move!.from)?.color, equals(ChessColor.white));
    });
  });

  group('Shogi Core Logic Tests', () {
    test('Initial Shogi Board has 30 legal moves for Sente', () {
      final board = ShogiBoard();
      final moves = board.getAllLegalMoves();
      // 9 pawns + 4 lances/knights/silvers/golds/king/bishop/rook = 30 opening options
      expect(moves.length, equals(30));
    });

    test('Shogi AI selects a legal move', () {
      final board = ShogiBoard();
      final move = ShogiAiEngine.getBestMove(board, BotDifficulty.beginner);
      expect(move, isNotNull);
      expect(move!.to.isValid, isTrue);
    });
  });
}
