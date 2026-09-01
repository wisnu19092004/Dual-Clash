import 'package:flutter_test/flutter_test.dart';
import 'package:game_papan/chess/chess_ai.dart';
import 'package:game_papan/chess/chess_board.dart';
import 'package:game_papan/chess/chess_piece.dart';
import 'package:game_papan/models/bot_difficulty.dart';
import 'package:game_papan/models/game_enums.dart';
import 'package:game_papan/services/elo_calculator.dart';
import 'package:game_papan/services/game_analysis_engine.dart';
import 'package:game_papan/shogi/shogi_ai.dart';
import 'package:game_papan/shogi/shogi_board.dart';
import 'package:game_papan/shogi/shogi_piece.dart';

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

    test('Pawn promotion moves generated include Queen, Rook, Bishop, Knight', () {
      final board = ChessBoard();
      // Clear board and place a white pawn at row 1 (a7) ready to promote at row 0 (a8)
      for (int r = 0; r < 8; r++) {
        for (int c = 0; c < 8; c++) {
          board.setPiece(ChessPosition(r, c), null);
        }
      }
      board.setPiece(const ChessPosition(7, 4), const ChessPiece(type: ChessPieceType.king, color: ChessColor.white));
      board.setPiece(const ChessPosition(0, 4), const ChessPiece(type: ChessPieceType.king, color: ChessColor.black));
      board.setPiece(const ChessPosition(1, 0), const ChessPiece(type: ChessPieceType.pawn, color: ChessColor.white));
      board.turn = ChessColor.white;

      final moves = board.getLegalMovesForPosition(const ChessPosition(1, 0));
      expect(moves.length, equals(4));
      expect(moves.map((m) => m.promotion).toSet(), equals({
        ChessPieceType.queen,
        ChessPieceType.rook,
        ChessPieceType.bishop,
        ChessPieceType.knight,
      }));

      // Test promoting to Knight
      final knightMove = moves.firstWhere((m) => m.promotion == ChessPieceType.knight);
      board.makeMove(knightMove);
      expect(board.getPiece(const ChessPosition(0, 0))?.type, equals(ChessPieceType.knight));
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

  group('Game Analysis Engine Tests', () {
    test('Chess full game analysis produces valid accuracy and metrics', () {
      final board = ChessBoard();
      // Execute 2 legal moves
      final moves = board.getAllLegalMoves(ChessColor.white);
      final move1 = moves.first;
      board.makeMove(move1);
      final blackMoves = board.getAllLegalMoves(ChessColor.black);
      final move2 = blackMoves.first;
      board.makeMove(move2);

      final report = GameAnalysisEngine.analyzeFullChessGame(
        moveHistory: board.moveHistory,
        playerColor: ChessColor.white,
      );

      expect(report.moveAnalyses.length, equals(2));
      expect(report.accuracyPlayer1, greaterThanOrEqualTo(0));
      expect(report.accuracyPlayer1, lessThanOrEqualTo(100));
    });

    test('Shogi full game analysis produces valid accuracy and metrics', () {
      final board = ShogiBoard();
      final moves = board.getAllLegalMoves();
      final move1 = moves.first;
      board.makeMove(move1);

      final report = GameAnalysisEngine.analyzeFullShogiGame(
        moveHistory: board.moveHistory,
        playerSide: ShogiPlayer.sente,
      );

      expect(report.moveAnalyses.length, equals(1));
      expect(report.accuracyPlayer1, greaterThanOrEqualTo(0));
    });
    test('Chess board rebuildFromHistory handles undo correctly', () {
      final board = ChessBoard();
      final moves = board.getAllLegalMoves(ChessColor.white);
      board.makeMove(moves.first);
      expect(board.moveHistory.length, equals(1));

      board.rebuildFromHistory(0);
      expect(board.moveHistory.length, equals(0));
      expect(board.turn, equals(ChessColor.white));
    });

    test('Shogi board rebuildFromHistory handles undo correctly', () {
      final board = ShogiBoard();
      final moves = board.getAllLegalMoves();
      board.makeMove(moves.first);
      expect(board.moveHistory.length, equals(1));

      board.rebuildFromHistory(0);
      expect(board.moveHistory.length, equals(0));
      expect(board.turn, equals(ShogiPlayer.sente));
    });
  });
}
