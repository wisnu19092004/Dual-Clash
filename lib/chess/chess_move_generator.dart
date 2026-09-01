import 'package:game_papan/chess/chess_board.dart';
import 'package:game_papan/chess/chess_piece.dart';

class ChessMoveGenerator {
  static List<ChessMove> getPseudoLegalMoves(
    ChessBoard board,
    ChessPosition pos,
    ChessPiece piece, {
    bool forAttackCheck = false,
  }) {
    final moves = <ChessMove>[];
    final color = piece.color;
    final r = pos.row;
    final c = pos.col;

    switch (piece.type) {
      case ChessPieceType.pawn:
        _addPawnMoves(board, moves, pos, piece, forAttackCheck);
        break;

      case ChessPieceType.knight:
        const knightOffsets = [
          [-2, -1], [-2, 1], [-1, -2], [-1, 2],
          [1, -2], [1, 2], [2, -1], [2, 1]
        ];
        for (final offset in knightOffsets) {
          final target = ChessPosition(r + offset[0], c + offset[1]);
          if (target.isValid) {
            final targetPiece = board.getPiece(target);
            if (targetPiece == null || targetPiece.color != color || forAttackCheck) {
              moves.add(ChessMove(from: pos, to: target, capturedPiece: targetPiece));
            }
          }
        }
        break;

      case ChessPieceType.bishop:
        _addSlidingMoves(board, moves, pos, color, [[-1, -1], [-1, 1], [1, -1], [1, 1]], forAttackCheck);
        break;

      case ChessPieceType.rook:
        _addSlidingMoves(board, moves, pos, color, [[-1, 0], [1, 0], [0, -1], [0, 1]], forAttackCheck);
        break;

      case ChessPieceType.queen:
        _addSlidingMoves(board, moves, pos, color, [
          [-1, -1], [-1, 1], [1, -1], [1, 1],
          [-1, 0], [1, 0], [0, -1], [0, 1]
        ], forAttackCheck);
        break;

      case ChessPieceType.king:
        _addKingMoves(board, moves, pos, piece, forAttackCheck);
        break;
    }

    return moves;
  }

  static void _addPawnMoves(
    ChessBoard board,
    List<ChessMove> moves,
    ChessPosition pos,
    ChessPiece piece,
    bool forAttackCheck,
  ) {
    final color = piece.color;
    final r = pos.row;
    final c = pos.col;
    final forward = color == ChessColor.white ? -1 : 1;
    final startRow = color == ChessColor.white ? 6 : 1;
    final promoRow = color == ChessColor.white ? 0 : 7;

    if (!forAttackCheck) {
      // 1 step forward
      final oneStep = ChessPosition(r + forward, c);
      if (oneStep.isValid && board.getPiece(oneStep) == null) {
        if (oneStep.row == promoRow) {
          for (final promo in [
            ChessPieceType.queen,
            ChessPieceType.rook,
            ChessPieceType.bishop,
            ChessPieceType.knight
          ]) {
            moves.add(ChessMove(from: pos, to: oneStep, promotion: promo));
          }
        } else {
          moves.add(ChessMove(from: pos, to: oneStep));
        }

        // 2 steps forward
        if (r == startRow) {
          final twoStep = ChessPosition(r + 2 * forward, c);
          if (twoStep.isValid && board.getPiece(twoStep) == null) {
            moves.add(ChessMove(from: pos, to: twoStep));
          }
        }
      }
    }

    // Captures
    for (final dc in [-1, 1]) {
      final target = ChessPosition(r + forward, c + dc);
      if (target.isValid) {
        if (forAttackCheck) {
          moves.add(ChessMove(from: pos, to: target));
        } else {
          final targetPiece = board.getPiece(target);
          if (targetPiece != null && targetPiece.color != color) {
            if (target.row == promoRow) {
              for (final promo in [
                ChessPieceType.queen,
                ChessPieceType.rook,
                ChessPieceType.bishop,
                ChessPieceType.knight
              ]) {
                moves.add(ChessMove(from: pos, to: target, capturedPiece: targetPiece, promotion: promo));
              }
            } else {
              moves.add(ChessMove(from: pos, to: target, capturedPiece: targetPiece));
            }
          } else if (board.enPassantTarget != null && target == board.enPassantTarget) {
            moves.add(ChessMove(from: pos, to: target, isEnPassant: true));
          }
        }
      }
    }
  }

  static void _addKingMoves(
    ChessBoard board,
    List<ChessMove> moves,
    ChessPosition pos,
    ChessPiece piece,
    bool forAttackCheck,
  ) {
    final color = piece.color;
    final r = pos.row;
    final c = pos.col;

    const kingOffsets = [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1],           [0, 1],
      [1, -1],  [1, 0],  [1, 1]
    ];
    for (final offset in kingOffsets) {
      final target = ChessPosition(r + offset[0], c + offset[1]);
      if (target.isValid) {
        final targetPiece = board.getPiece(target);
        if (targetPiece == null || targetPiece.color != color || forAttackCheck) {
          moves.add(ChessMove(from: pos, to: target, capturedPiece: targetPiece));
        }
      }
    }

    // Castling (Not available in attack checks or if in check or has moved)
    if (!forAttackCheck && !piece.hasMoved && !board.isCheck) {
      final opp = color == ChessColor.white ? ChessColor.black : ChessColor.white;
      // Kingside
      final rookKing = board.getPiece(ChessPosition(r, 7));
      if (rookKing != null && rookKing.type == ChessPieceType.rook && !rookKing.hasMoved) {
        if (board.getPiece(ChessPosition(r, 5)) == null &&
            board.getPiece(ChessPosition(r, 6)) == null &&
            !board.isSquareAttacked(ChessPosition(r, 5), opp) &&
            !board.isSquareAttacked(ChessPosition(r, 6), opp)) {
          moves.add(ChessMove(from: pos, to: ChessPosition(r, 6), isCastling: true));
        }
      }
      // Queenside
      final rookQueen = board.getPiece(ChessPosition(r, 0));
      if (rookQueen != null && rookQueen.type == ChessPieceType.rook && !rookQueen.hasMoved) {
        if (board.getPiece(ChessPosition(r, 1)) == null &&
            board.getPiece(ChessPosition(r, 2)) == null &&
            board.getPiece(ChessPosition(r, 3)) == null &&
            !board.isSquareAttacked(ChessPosition(r, 2), opp) &&
            !board.isSquareAttacked(ChessPosition(r, 3), opp)) {
          moves.add(ChessMove(from: pos, to: ChessPosition(r, 2), isCastling: true));
        }
      }
    }
  }

  static void _addSlidingMoves(
    ChessBoard board,
    List<ChessMove> moves,
    ChessPosition pos,
    ChessColor color,
    List<List<int>> directions,
    bool forAttackCheck,
  ) {
    for (final dir in directions) {
      var currentR = pos.row + dir[0];
      var currentC = pos.col + dir[1];
      while (currentR >= 0 && currentR < 8 && currentC >= 0 && currentC < 8) {
        final target = ChessPosition(currentR, currentC);
        final targetPiece = board.getPiece(target);

        if (targetPiece == null) {
          moves.add(ChessMove(from: pos, to: target));
        } else {
          if (targetPiece.color != color || forAttackCheck) {
            moves.add(ChessMove(from: pos, to: target, capturedPiece: targetPiece));
          }
          break;
        }
        currentR += dir[0];
        currentC += dir[1];
      }
    }
  }
}
