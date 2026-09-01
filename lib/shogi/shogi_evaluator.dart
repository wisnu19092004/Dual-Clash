import 'package:game_papan/shogi/shogi_board.dart';
import 'package:game_papan/shogi/shogi_piece.dart';

class ShogiEvaluator {
  static int evaluate(ShogiBoard board) {
    if (board.isCheckmate) {
      return board.turn == ShogiPlayer.sente ? -999999 : 999999;
    }

    int totalScore = 0;

    // Board pieces
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final piece = board.board[r][c];
        if (piece == null) continue;

        int pieceVal = piece.baseValue;
        int posBonus = (piece.player == ShogiPlayer.sente ? (8 - r) : r) * 10;
        int total = pieceVal + posBonus;

        if (piece.player == ShogiPlayer.sente) {
          totalScore += total;
        } else {
          totalScore -= total;
        }
      }
    }

    // In-hand pieces (Hand pieces have strong tactical flexibility, worth 1.25x)
    for (final pType in board.senteHand) {
      totalScore += (getBaseValueOfPiece(pType) * 1.25).round();
    }
    for (final pType in board.goteHand) {
      totalScore -= (getBaseValueOfPiece(pType) * 1.25).round();
    }

    return totalScore;
  }

  static int getBaseValueOfPiece(ShogiPieceType type) {
    switch (type) {
      case ShogiPieceType.king:
        return 20000;
      case ShogiPieceType.rook:
      case ShogiPieceType.promotedRook:
        return 1000;
      case ShogiPieceType.bishop:
      case ShogiPieceType.promotedBishop:
        return 850;
      case ShogiPieceType.gold:
      case ShogiPieceType.promotedSilver:
      case ShogiPieceType.promotedKnight:
      case ShogiPieceType.promotedLance:
      case ShogiPieceType.promotedPawn:
        return 600;
      case ShogiPieceType.silver:
        return 500;
      case ShogiPieceType.knight:
        return 350;
      case ShogiPieceType.lance:
        return 300;
      case ShogiPieceType.pawn:
        return 100;
    }
  }
}
