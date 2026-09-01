import 'package:game_papan/shogi/shogi_piece.dart';

List<List<ShogiPiece?>> createInitialShogiBoard() {
  final b = List<List<ShogiPiece?>>.generate(
    9,
    (_) => List<ShogiPiece?>.filled(9, null),
  );

  // Row 0: Gote back row
  b[0][0] = const ShogiPiece(type: ShogiPieceType.lance, player: ShogiPlayer.gote);
  b[0][1] = const ShogiPiece(type: ShogiPieceType.knight, player: ShogiPlayer.gote);
  b[0][2] = const ShogiPiece(type: ShogiPieceType.silver, player: ShogiPlayer.gote);
  b[0][3] = const ShogiPiece(type: ShogiPieceType.gold, player: ShogiPlayer.gote);
  b[0][4] = const ShogiPiece(type: ShogiPieceType.king, player: ShogiPlayer.gote);
  b[0][5] = const ShogiPiece(type: ShogiPieceType.gold, player: ShogiPlayer.gote);
  b[0][6] = const ShogiPiece(type: ShogiPieceType.silver, player: ShogiPlayer.gote);
  b[0][7] = const ShogiPiece(type: ShogiPieceType.knight, player: ShogiPlayer.gote);
  b[0][8] = const ShogiPiece(type: ShogiPieceType.lance, player: ShogiPlayer.gote);

  // Row 1: Gote bishop & rook
  b[1][1] = const ShogiPiece(type: ShogiPieceType.rook, player: ShogiPlayer.gote);
  b[1][7] = const ShogiPiece(type: ShogiPieceType.bishop, player: ShogiPlayer.gote);

  // Row 2: Gote pawns
  for (int c = 0; c < 9; c++) {
    b[2][c] = const ShogiPiece(type: ShogiPieceType.pawn, player: ShogiPlayer.gote);
  }

  // Row 6: Sente pawns
  for (int c = 0; c < 9; c++) {
    b[6][c] = const ShogiPiece(type: ShogiPieceType.pawn, player: ShogiPlayer.sente);
  }

  // Row 7: Sente bishop & rook
  b[7][1] = const ShogiPiece(type: ShogiPieceType.bishop, player: ShogiPlayer.sente);
  b[7][7] = const ShogiPiece(type: ShogiPieceType.rook, player: ShogiPlayer.sente);

  // Row 8: Sente back row
  b[8][0] = const ShogiPiece(type: ShogiPieceType.lance, player: ShogiPlayer.sente);
  b[8][1] = const ShogiPiece(type: ShogiPieceType.knight, player: ShogiPlayer.sente);
  b[8][2] = const ShogiPiece(type: ShogiPieceType.silver, player: ShogiPlayer.sente);
  b[8][3] = const ShogiPiece(type: ShogiPieceType.gold, player: ShogiPlayer.sente);
  b[8][4] = const ShogiPiece(type: ShogiPieceType.king, player: ShogiPlayer.sente);
  b[8][5] = const ShogiPiece(type: ShogiPieceType.gold, player: ShogiPlayer.sente);
  b[8][6] = const ShogiPiece(type: ShogiPieceType.silver, player: ShogiPlayer.sente);
  b[8][7] = const ShogiPiece(type: ShogiPieceType.knight, player: ShogiPlayer.sente);
  b[8][8] = const ShogiPiece(type: ShogiPieceType.lance, player: ShogiPlayer.sente);

  return b;
}
