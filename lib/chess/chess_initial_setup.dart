import 'package:game_papan/chess/chess_piece.dart';

List<List<ChessPiece?>> createInitialChessBoard() {
  final b = List<List<ChessPiece?>>.generate(
    8,
    (_) => List<ChessPiece?>.filled(8, null),
  );

  // Black pieces (row 0 & 1)
  b[0][0] = const ChessPiece(type: ChessPieceType.rook, color: ChessColor.black);
  b[0][1] = const ChessPiece(type: ChessPieceType.knight, color: ChessColor.black);
  b[0][2] = const ChessPiece(type: ChessPieceType.bishop, color: ChessColor.black);
  b[0][3] = const ChessPiece(type: ChessPieceType.queen, color: ChessColor.black);
  b[0][4] = const ChessPiece(type: ChessPieceType.king, color: ChessColor.black);
  b[0][5] = const ChessPiece(type: ChessPieceType.bishop, color: ChessColor.black);
  b[0][6] = const ChessPiece(type: ChessPieceType.knight, color: ChessColor.black);
  b[0][7] = const ChessPiece(type: ChessPieceType.rook, color: ChessColor.black);
  for (int col = 0; col < 8; col++) {
    b[1][col] = const ChessPiece(type: ChessPieceType.pawn, color: ChessColor.black);
  }

  // White pieces (row 6 & 7)
  for (int col = 0; col < 8; col++) {
    b[6][col] = const ChessPiece(type: ChessPieceType.pawn, color: ChessColor.white);
  }
  b[7][0] = const ChessPiece(type: ChessPieceType.rook, color: ChessColor.white);
  b[7][1] = const ChessPiece(type: ChessPieceType.knight, color: ChessColor.white);
  b[7][2] = const ChessPiece(type: ChessPieceType.bishop, color: ChessColor.white);
  b[7][3] = const ChessPiece(type: ChessPieceType.queen, color: ChessColor.white);
  b[7][4] = const ChessPiece(type: ChessPieceType.king, color: ChessColor.white);
  b[7][5] = const ChessPiece(type: ChessPieceType.bishop, color: ChessColor.white);
  b[7][6] = const ChessPiece(type: ChessPieceType.knight, color: ChessColor.white);
  b[7][7] = const ChessPiece(type: ChessPieceType.rook, color: ChessColor.white);

  return b;
}
