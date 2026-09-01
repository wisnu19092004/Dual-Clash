import 'package:game_papan/shogi/shogi_board.dart';
import 'package:game_papan/shogi/shogi_piece.dart';
import 'package:game_papan/shogi/shogi_move.dart';

class ShogiMoveGenerator {
  static List<ShogiMove> getPseudoMoves(ShogiBoard board, ShogiPosition pos, ShogiPiece piece) {
    final moves = <ShogiMove>[];
    final dir = piece.player == ShogiPlayer.sente ? -1 : 1;
    final r = pos.row;
    final c = pos.col;

    bool canEnterPromo(int targetRow) =>
        piece.player == ShogiPlayer.sente ? (r <= 2 || targetRow <= 2) : (r >= 6 || targetRow >= 6);

    bool mustPromote(int targetRow, ShogiPieceType type) {
      if (type == ShogiPieceType.pawn || type == ShogiPieceType.lance) {
        return piece.player == ShogiPlayer.sente ? targetRow == 0 : targetRow == 8;
      }
      if (type == ShogiPieceType.knight) {
        return piece.player == ShogiPlayer.sente ? targetRow <= 1 : targetRow >= 7;
      }
      return false;
    }

    void addStep(int tr, int tc) {
      final target = ShogiPosition(tr, tc);
      if (!target.isValid) return;
      final targetP = board.getPiece(target);
      if (targetP == null || targetP.player != piece.player) {
        final promoAvailable = piece.canPromote && canEnterPromo(tr);
        final forcePromo = mustPromote(tr, piece.type);

        if (forcePromo) {
          moves.add(ShogiMove(from: pos, to: target, capturedPiece: targetP, promote: true));
        } else if (promoAvailable) {
          moves.add(ShogiMove(from: pos, to: target, capturedPiece: targetP, promote: true));
          moves.add(ShogiMove(from: pos, to: target, capturedPiece: targetP, promote: false));
        } else {
          moves.add(ShogiMove(from: pos, to: target, capturedPiece: targetP, promote: false));
        }
      }
    }

    void addRay(int dr, int dc) {
      var currR = r + dr;
      var currC = c + dc;
      while (currR >= 0 && currR < 9 && currC >= 0 && currC < 9) {
        final target = ShogiPosition(currR, currC);
        final targetP = board.getPiece(target);
        if (targetP == null) {
          final promoAvailable = piece.canPromote && canEnterPromo(currR);
          final forcePromo = mustPromote(currR, piece.type);
          if (forcePromo) {
            moves.add(ShogiMove(from: pos, to: target, promote: true));
          } else if (promoAvailable) {
            moves.add(ShogiMove(from: pos, to: target, promote: true));
            moves.add(ShogiMove(from: pos, to: target, promote: false));
          } else {
            moves.add(ShogiMove(from: pos, to: target, promote: false));
          }
        } else {
          if (targetP.player != piece.player) {
            final promoAvailable = piece.canPromote && canEnterPromo(currR);
            final forcePromo = mustPromote(currR, piece.type);
            if (forcePromo) {
              moves.add(ShogiMove(from: pos, to: target, capturedPiece: targetP, promote: true));
            } else if (promoAvailable) {
              moves.add(ShogiMove(from: pos, to: target, capturedPiece: targetP, promote: true));
              moves.add(ShogiMove(from: pos, to: target, capturedPiece: targetP, promote: false));
            } else {
              moves.add(ShogiMove(from: pos, to: target, capturedPiece: targetP, promote: false));
            }
          }
          break;
        }
        currR += dr;
        currC += dc;
      }
    }

    switch (piece.type) {
      case ShogiPieceType.pawn:
        addStep(r + dir, c);
        break;

      case ShogiPieceType.lance:
        addRay(dir, 0);
        break;

      case ShogiPieceType.knight:
        addStep(r + 2 * dir, c - 1);
        addStep(r + 2 * dir, c + 1);
        break;

      case ShogiPieceType.silver:
        addStep(r + dir, c - 1);
        addStep(r + dir, c);
        addStep(r + dir, c + 1);
        addStep(r - dir, c - 1);
        addStep(r - dir, c + 1);
        break;

      case ShogiPieceType.gold:
      case ShogiPieceType.promotedSilver:
      case ShogiPieceType.promotedKnight:
      case ShogiPieceType.promotedLance:
      case ShogiPieceType.promotedPawn:
        addStep(r + dir, c - 1);
        addStep(r + dir, c);
        addStep(r + dir, c + 1);
        addStep(r, c - 1);
        addStep(r, c + 1);
        addStep(r - dir, c);
        break;

      case ShogiPieceType.king:
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            addStep(r + dr, c + dc);
          }
        }
        break;

      case ShogiPieceType.bishop:
        addRay(-1, -1);
        addRay(-1, 1);
        addRay(1, -1);
        addRay(1, 1);
        break;

      case ShogiPieceType.promotedBishop:
        addRay(-1, -1);
        addRay(-1, 1);
        addRay(1, -1);
        addRay(1, 1);
        addStep(r - 1, c);
        addStep(r + 1, c);
        addStep(r, c - 1);
        addStep(r, c + 1);
        break;

      case ShogiPieceType.rook:
        addRay(-1, 0);
        addRay(1, 0);
        addRay(0, -1);
        addRay(0, 1);
        break;

      case ShogiPieceType.promotedRook:
        addRay(-1, 0);
        addRay(1, 0);
        addRay(0, -1);
        addRay(0, 1);
        addStep(r - 1, c - 1);
        addStep(r - 1, c + 1);
        addStep(r + 1, c - 1);
        addStep(r + 1, c + 1);
        break;
    }

    return moves;
  }
}
