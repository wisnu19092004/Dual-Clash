import 'package:game_papan/shogi/shogi_piece.dart';

class ShogiPosition {
  final int row; // 0 to 8 (0 is top row for Gote, 8 is bottom row for Sente)
  final int col; // 0 to 8 (0 is column 9 to column 1 in Japanese notation)

  const ShogiPosition(this.row, this.col);

  bool get isValid => row >= 0 && row < 9 && col >= 0 && col < 9;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShogiPosition &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => '($row,$col)';
}

class ShogiMove {
  final ShogiPosition? from; // null if piece drop (komadai)
  final ShogiPosition to;
  final ShogiPieceType? dropPieceType;
  final ShogiPiece? capturedPiece;
  final bool promote;

  const ShogiMove({
    this.from,
    required this.to,
    this.dropPieceType,
    this.capturedPiece,
    this.promote = false,
  });

  bool get isDrop => from == null && dropPieceType != null;

  @override
  String toString() {
    if (isDrop) {
      return 'Drop ${dropPieceType!.name} at $to';
    }
    return '$from->$to${promote ? " (Promote)" : ""}';
  }
}
