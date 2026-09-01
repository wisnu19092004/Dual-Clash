import 'package:game_papan/chess/chess_board.dart';
import 'package:game_papan/chess/chess_piece.dart';
import 'package:game_papan/chess/chess_evaluation_tables.dart';

class ChessEvaluator {
  static int evaluate(ChessBoard board) {
    if (board.isCheckmate) {
      return board.turn == ChessColor.white ? -999999 : 999999;
    }
    if (board.isStalemate) return 0;

    int totalScore = 0;

    // Extra evaluation for bishop pair, rook on open files, and center control
    int whiteBishops = 0;
    int blackBishops = 0;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.board[r][c];
        if (piece == null) continue;

        if (piece.type == ChessPieceType.bishop) {
          if (piece.color == ChessColor.white) {
            whiteBishops++;
          } else {
            blackBishops++;
          }
        }

        int pieceVal = piece.baseValue;
        int posVal = getPositionalValue(piece, r, c);
        int pieceTotal = pieceVal + posVal;

        if (piece.color == ChessColor.white) {
          totalScore += pieceTotal;
        } else {
          totalScore -= pieceTotal;
        }
      }
    }

    if (whiteBishops >= 2) totalScore += 50; // Bishop pair advantage
    if (blackBishops >= 2) totalScore -= 50;

    return totalScore;
  }

  static int getPositionalValue(ChessPiece piece, int row, int col) {
    final r = piece.color == ChessColor.white ? row : 7 - row;
    final c = piece.color == ChessColor.white ? col : 7 - col;

    switch (piece.type) {
      case ChessPieceType.pawn:
        return ChessEvaluationTables.pawnTable[r][c];
      case ChessPieceType.knight:
        return ChessEvaluationTables.knightTable[r][c];
      case ChessPieceType.bishop:
        return ChessEvaluationTables.bishopTable[r][c];
      case ChessPieceType.rook:
        return ChessEvaluationTables.rookTable[r][c];
      case ChessPieceType.queen:
        return ChessEvaluationTables.queenTable[r][c];
      case ChessPieceType.king:
        return ChessEvaluationTables.kingTable[r][c];
    }
  }
}
