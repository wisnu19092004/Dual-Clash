import 'package:game_papan/shogi/shogi_piece.dart';
import 'package:game_papan/shogi/shogi_move.dart';
import 'package:game_papan/shogi/shogi_initial_setup.dart';
import 'package:game_papan/shogi/shogi_move_generator.dart';
import 'package:game_papan/shogi/shogi_drop_rules.dart';

class ShogiBoard {
  final List<List<ShogiPiece?>> board;
  ShogiPlayer turn;
  final List<ShogiPieceType> senteHand;
  final List<ShogiPieceType> goteHand;
  final List<ShogiMove> moveHistory;
  bool isCheck;
  bool isCheckmate;

  ShogiBoard({
    List<List<ShogiPiece?>>? board,
    this.turn = ShogiPlayer.sente,
    List<ShogiPieceType>? senteHand,
    List<ShogiPieceType>? goteHand,
    List<ShogiMove>? moveHistory,
    this.isCheck = false,
    this.isCheckmate = false,
  })  : board = board ?? createInitialShogiBoard(),
        senteHand = senteHand ?? [],
        goteHand = goteHand ?? [],
        moveHistory = moveHistory ?? [];

  ShogiBoard clone() {
    final newBoard = List<List<ShogiPiece?>>.generate(
      9,
      (r) => List<ShogiPiece?>.generate(9, (c) => board[r][c]),
    );
    return ShogiBoard(
      board: newBoard,
      turn: turn,
      senteHand: List.from(senteHand),
      goteHand: List.from(goteHand),
      moveHistory: List.from(moveHistory),
      isCheck: isCheck,
      isCheckmate: isCheckmate,
    );
  }

  ShogiPiece? getPiece(ShogiPosition pos) {
    if (!pos.isValid) return null;
    return board[pos.row][pos.col];
  }

  void setPiece(ShogiPosition pos, ShogiPiece? piece) {
    if (!pos.isValid) return;
    board[pos.row][pos.col] = piece;
  }

  ShogiPosition? findKing(ShogiPlayer player) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final p = board[r][c];
        if (p != null && p.type == ShogiPieceType.king && p.player == player) {
          return ShogiPosition(r, c);
        }
      }
    }
    return null;
  }

  bool isSquareAttacked(ShogiPosition pos, ShogiPlayer attacker) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final p = board[r][c];
        if (p != null && p.player == attacker) {
          final pseudoMoves = ShogiMoveGenerator.getPseudoMoves(this, ShogiPosition(r, c), p);
          for (final move in pseudoMoves) {
            if (move.to == pos) return true;
          }
        }
      }
    }
    return false;
  }

  List<ShogiMove> getLegalMovesForPosition(ShogiPosition pos) {
    final p = getPiece(pos);
    if (p == null || p.player != turn) return [];
    final pseudo = ShogiMoveGenerator.getPseudoMoves(this, pos, p);
    final legal = <ShogiMove>[];

    for (final move in pseudo) {
      if (isMoveLegal(move)) {
        legal.add(move);
      }
    }
    return legal;
  }

  List<ShogiMove> getLegalDropsForPiece(ShogiPieceType pieceType) {
    return ShogiDropRules.getLegalDropsForPiece(this, pieceType);
  }

  bool isCheckmateFor(ShogiPlayer player) {
    final kingPos = findKing(player);
    final opp = player == ShogiPlayer.sente ? ShogiPlayer.gote : ShogiPlayer.sente;
    if (kingPos == null || !isSquareAttacked(kingPos, opp)) return false;

    final prevTurn = turn;
    turn = player;
    final allLegal = getAllLegalMoves();
    turn = prevTurn;

    return allLegal.isEmpty;
  }

  List<ShogiMove> getAllLegalMoves() {
    final moves = <ShogiMove>[];
    // 1. Board moves
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final p = board[r][c];
        if (p != null && p.player == turn) {
          final pseudo = ShogiMoveGenerator.getPseudoMoves(this, ShogiPosition(r, c), p);
          for (final move in pseudo) {
            if (isMoveLegal(move)) {
              moves.add(move);
            }
          }
        }
      }
    }

    // 2. Drop moves from hand
    final hand = turn == ShogiPlayer.sente ? senteHand : goteHand;
    final uniqueInHand = hand.toSet();
    for (final pieceType in uniqueInHand) {
      moves.addAll(getLegalDropsForPiece(pieceType));
    }

    return moves;
  }

  bool isMoveLegal(ShogiMove move) {
    final cloneBoard = clone();
    cloneBoard.applyMoveRaw(move);
    final kingPos = cloneBoard.findKing(turn);
    if (kingPos == null) return false;
    final opp = turn == ShogiPlayer.sente ? ShogiPlayer.gote : ShogiPlayer.sente;
    return !cloneBoard.isSquareAttacked(kingPos, opp);
  }

  void applyMoveRaw(ShogiMove move) {
    if (move.isDrop) {
      final hand = turn == ShogiPlayer.sente ? senteHand : goteHand;
      hand.remove(move.dropPieceType!);
      setPiece(move.to, ShogiPiece(type: move.dropPieceType!, player: turn));
    } else {
      final p = getPiece(move.from!)!;
      final destP = getPiece(move.to);

      if (destP != null) {
        final unpromoted = destP.unpromotedType;
        if (turn == ShogiPlayer.sente) {
          senteHand.add(unpromoted);
        } else {
          goteHand.add(unpromoted);
        }
      }

      setPiece(move.from!, null);
      if (move.promote) {
        setPiece(move.to, ShogiPiece(type: p.promotedType, player: turn));
      } else {
        setPiece(move.to, p);
      }
    }
  }

  bool makeMove(ShogiMove move) {
    applyMoveRaw(move);
    moveHistory.add(move);

    turn = turn == ShogiPlayer.sente ? ShogiPlayer.gote : ShogiPlayer.sente;

    final kingPos = findKing(turn);
    final opp = turn == ShogiPlayer.sente ? ShogiPlayer.gote : ShogiPlayer.sente;
    isCheck = kingPos != null && isSquareAttacked(kingPos, opp);

    final legalMoves = getAllLegalMoves();
    if (legalMoves.isEmpty) {
      if (isCheck) {
        isCheckmate = true;
      }
    }

    return true;
  }

  /// Rebuilds the board state from the beginning up to [targetMoveCount] moves.
  /// Used for Undo / Takeback feature.
  void rebuildFromHistory(int targetMoveCount) {
    if (targetMoveCount < 0 || targetMoveCount > moveHistory.length) return;
    final movesToReplay = moveHistory.sublist(0, targetMoveCount);

    final fresh = ShogiBoard();
    board.setRange(0, 9, fresh.board);
    turn = ShogiPlayer.sente;
    senteHand.clear();
    goteHand.clear();
    moveHistory.clear();
    isCheck = false;
    isCheckmate = false;

    for (final move in movesToReplay) {
      makeMove(move);
    }
  }
}
