import 'package:game_papan/chess/chess_piece.dart';
import 'package:game_papan/chess/chess_initial_setup.dart';
import 'package:game_papan/chess/chess_move_generator.dart';

class ChessBoard {
  final List<List<ChessPiece?>> board;
  ChessColor turn;
  ChessPosition? enPassantTarget;
  List<ChessPiece> capturedWhite;
  List<ChessPiece> capturedBlack;
  List<ChessMove> moveHistory;
  bool isCheck;
  bool isCheckmate;
  bool isStalemate;

  ChessBoard({
    List<List<ChessPiece?>>? board,
    this.turn = ChessColor.white,
    this.enPassantTarget,
    List<ChessPiece>? capturedWhite,
    List<ChessPiece>? capturedBlack,
    List<ChessMove>? moveHistory,
    this.isCheck = false,
    this.isCheckmate = false,
    this.isStalemate = false,
  })  : board = board ?? createInitialChessBoard(),
        capturedWhite = capturedWhite ?? [],
        capturedBlack = capturedBlack ?? [],
        moveHistory = moveHistory ?? [];

  ChessBoard clone() {
    final newBoard = List<List<ChessPiece?>>.generate(
      8,
      (r) => List<ChessPiece?>.generate(8, (c) => board[r][c]),
    );
    return ChessBoard(
      board: newBoard,
      turn: turn,
      enPassantTarget: enPassantTarget,
      capturedWhite: List.from(capturedWhite),
      capturedBlack: List.from(capturedBlack),
      moveHistory: List.from(moveHistory),
      isCheck: isCheck,
      isCheckmate: isCheckmate,
      isStalemate: isStalemate,
    );
  }

  ChessPiece? getPiece(ChessPosition pos) {
    if (!pos.isValid) return null;
    return board[pos.row][pos.col];
  }

  void setPiece(ChessPosition pos, ChessPiece? piece) {
    if (!pos.isValid) return;
    board[pos.row][pos.col] = piece;
  }

  ChessPosition? findKing(ChessColor color) {
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = board[r][c];
        if (p != null && p.type == ChessPieceType.king && p.color == color) {
          return ChessPosition(r, c);
        }
      }
    }
    return null;
  }

  bool isSquareAttacked(ChessPosition pos, ChessColor attackerColor) {
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board[r][c];
        if (piece != null && piece.color == attackerColor) {
          final pseudoMoves = ChessMoveGenerator.getPseudoLegalMoves(
            this,
            ChessPosition(r, c),
            piece,
            forAttackCheck: true,
          );
          for (final move in pseudoMoves) {
            if (move.to == pos) return true;
          }
        }
      }
    }
    return false;
  }

  List<ChessMove> getLegalMovesForPosition(ChessPosition pos) {
    final piece = getPiece(pos);
    if (piece == null || piece.color != turn) return [];
    final pseudoMoves = ChessMoveGenerator.getPseudoLegalMoves(this, pos, piece);
    final legalMoves = <ChessMove>[];

    for (final move in pseudoMoves) {
      if (_isMoveLegal(move)) {
        legalMoves.add(move);
      }
    }
    return legalMoves;
  }

  List<ChessMove> getAllLegalMoves(ChessColor color) {
    final moves = <ChessMove>[];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board[r][c];
        if (piece != null && piece.color == color) {
          final pseudoMoves = ChessMoveGenerator.getPseudoLegalMoves(
            this,
            ChessPosition(r, c),
            piece,
          );
          for (final move in pseudoMoves) {
            if (_isMoveLegal(move)) {
              moves.add(move);
            }
          }
        }
      }
    }
    return moves;
  }

  bool _isMoveLegal(ChessMove move) {
    final cloneBoard = clone();
    cloneBoard._applyMoveRaw(move);
    final kingPos = cloneBoard.findKing(turn);
    if (kingPos == null) return false;
    final opponentColor = turn == ChessColor.white ? ChessColor.black : ChessColor.white;
    return !cloneBoard.isSquareAttacked(kingPos, opponentColor);
  }

  void _applyMoveRaw(ChessMove move) {
    final piece = getPiece(move.from);
    if (piece == null) return;

    if (move.isCastling) {
      setPiece(move.from, null);
      setPiece(move.to, piece.copyWith(hasMoved: true));
      if (move.to.col == 6) {
        final rook = getPiece(ChessPosition(move.from.row, 7));
        setPiece(ChessPosition(move.from.row, 7), null);
        setPiece(ChessPosition(move.from.row, 5), rook?.copyWith(hasMoved: true));
      } else if (move.to.col == 2) {
        final rook = getPiece(ChessPosition(move.from.row, 0));
        setPiece(ChessPosition(move.from.row, 0), null);
        setPiece(ChessPosition(move.from.row, 3), rook?.copyWith(hasMoved: true));
      }
    } else if (move.isEnPassant) {
      setPiece(move.from, null);
      setPiece(move.to, piece.copyWith(hasMoved: true));
      final capturedPawnRow = move.from.row;
      final capturedPawnCol = move.to.col;
      setPiece(ChessPosition(capturedPawnRow, capturedPawnCol), null);
    } else {
      setPiece(move.from, null);
      if (move.promotion != null) {
        setPiece(move.to, ChessPiece(type: move.promotion!, color: piece.color, hasMoved: true));
      } else {
        setPiece(move.to, piece.copyWith(hasMoved: true));
      }
    }
  }

  bool makeMove(ChessMove move) {
    final legalMoves = getLegalMovesForPosition(move.from);
    final matchingMove = legalMoves.where((m) =>
        m.to == move.to &&
        (m.promotion == null || m.promotion == move.promotion || move.promotion == null)).firstOrNull;

    if (matchingMove == null) return false;

    final actualMove = matchingMove.promotion != null && move.promotion != null
        ? ChessMove(
            from: matchingMove.from,
            to: matchingMove.to,
            capturedPiece: matchingMove.capturedPiece,
            promotion: move.promotion,
            isCastling: matchingMove.isCastling,
            isEnPassant: matchingMove.isEnPassant,
          )
        : matchingMove;

    final piece = getPiece(actualMove.from)!;
    final destPiece = getPiece(actualMove.to);

    if (destPiece != null) {
      if (destPiece.color == ChessColor.white) {
        capturedWhite.add(destPiece);
      } else {
        capturedBlack.add(destPiece);
      }
    } else if (actualMove.isEnPassant) {
      final captured = piece.color == ChessColor.white
          ? const ChessPiece(type: ChessPieceType.pawn, color: ChessColor.black)
          : const ChessPiece(type: ChessPieceType.pawn, color: ChessColor.white);
      if (captured.color == ChessColor.white) {
        capturedWhite.add(captured);
      } else {
        capturedBlack.add(captured);
      }
    }

    _applyMoveRaw(actualMove);
    moveHistory.add(actualMove);

    if (piece.type == ChessPieceType.pawn && (actualMove.from.row - actualMove.to.row).abs() == 2) {
      final middleRow = (actualMove.from.row + actualMove.to.row) ~/ 2;
      enPassantTarget = ChessPosition(middleRow, actualMove.from.col);
    } else {
      enPassantTarget = null;
    }

    turn = turn == ChessColor.white ? ChessColor.black : ChessColor.white;

    final kingPos = findKing(turn);
    final opponentColor = turn == ChessColor.white ? ChessColor.black : ChessColor.white;
    isCheck = kingPos != null && isSquareAttacked(kingPos, opponentColor);

    final nextLegalMoves = getAllLegalMoves(turn);
    if (nextLegalMoves.isEmpty) {
      if (isCheck) {
        isCheckmate = true;
      } else {
        isStalemate = true;
      }
    }

    return true;
  }

  /// Rebuilds the board state from the beginning up to [moveCount] moves.
  /// Used for Undo / Takeback feature.
  void rebuildFromHistory(int targetMoveCount) {
    if (targetMoveCount < 0 || targetMoveCount > moveHistory.length) return;
    final movesToReplay = moveHistory.sublist(0, targetMoveCount);

    final fresh = ChessBoard();
    board.setRange(0, 8, fresh.board);
    turn = ChessColor.white;
    enPassantTarget = null;
    capturedWhite.clear();
    capturedBlack.clear();
    moveHistory.clear();
    isCheck = false;
    isCheckmate = false;
    isStalemate = false;

    for (final move in movesToReplay) {
      makeMove(move);
    }
  }
}
