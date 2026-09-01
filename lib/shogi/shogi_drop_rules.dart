import 'package:game_papan/shogi/shogi_board.dart';
import 'package:game_papan/shogi/shogi_piece.dart';
import 'package:game_papan/shogi/shogi_move.dart';

class ShogiDropRules {
  static List<ShogiMove> getLegalDropsForPiece(ShogiBoard board, ShogiPieceType pieceType) {
    final moves = <ShogiMove>[];
    final hand = board.turn == ShogiPlayer.sente ? board.senteHand : board.goteHand;
    if (!hand.contains(pieceType)) return [];

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final pos = ShogiPosition(r, c);
        if (board.getPiece(pos) == null) {
          // Rule 1: Pawn/Lance cannot drop on the furthest rank
          if (pieceType == ShogiPieceType.pawn || pieceType == ShogiPieceType.lance) {
            if (board.turn == ShogiPlayer.sente && r == 0) continue;
            if (board.turn == ShogiPlayer.gote && r == 8) continue;
          }
          // Rule 2: Knight cannot drop on the furthest 2 ranks
          if (pieceType == ShogiPieceType.knight) {
            if (board.turn == ShogiPlayer.sente && (r == 0 || r == 1)) continue;
            if (board.turn == ShogiPlayer.gote && (r == 8 || r == 7)) continue;
          }
          // Rule 3: Nifu (Two unpromoted Pawns in same column)
          if (pieceType == ShogiPieceType.pawn) {
            bool hasPawnInCol = false;
            for (int rowCheck = 0; rowCheck < 9; rowCheck++) {
              final checkP = board.board[rowCheck][c];
              if (checkP != null && checkP.player == board.turn && checkP.type == ShogiPieceType.pawn) {
                hasPawnInCol = true;
                break;
              }
            }
            if (hasPawnInCol) continue;
          }

          final move = ShogiMove(to: pos, dropPieceType: pieceType);
          if (board.isMoveLegal(move)) {
            // Rule 4: Drop pawn mate rule (Uchifuzume is illegal)
            if (pieceType == ShogiPieceType.pawn) {
              final cloneB = board.clone();
              cloneB.applyMoveRaw(move);
              final opp = board.turn == ShogiPlayer.sente ? ShogiPlayer.gote : ShogiPlayer.sente;
              if (cloneB.isCheckmateFor(opp)) {
                continue; // Uchifuzume is forbidden
              }
            }
            moves.add(move);
          }
        }
      }
    }
    return moves;
  }
}
