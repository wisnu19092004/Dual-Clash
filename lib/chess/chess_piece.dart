enum ChessColor { white, black }

enum ChessPieceType { king, queen, rook, bishop, knight, pawn }

class ChessPosition {
  final int row; // 0 to 7 (0 is row 8 for black, 7 is row 1 for white)
  final int col; // 0 to 7 (a to h)

  const ChessPosition(this.row, this.col);

  bool get isValid => row >= 0 && row < 8 && col >= 0 && col < 8;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChessPosition &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  String get notation {
    final file = String.fromCharCode('a'.codeUnitAt(0) + col);
    final rank = (8 - row).toString();
    return '$file$rank';
  }

  @override
  String toString() => notation;
}

class ChessPiece {
  final ChessPieceType type;
  final ChessColor color;
  final bool hasMoved;

  const ChessPiece({
    required this.type,
    required this.color,
    this.hasMoved = false,
  });

  ChessPiece copyWith({bool? hasMoved, ChessPieceType? type, ChessColor? color}) {
    return ChessPiece(
      type: type ?? this.type,
      color: color ?? this.color,
      hasMoved: hasMoved ?? this.hasMoved,
    );
  }

  int get baseValue {
    switch (type) {
      case ChessPieceType.pawn:
        return 100;
      case ChessPieceType.knight:
        return 320;
      case ChessPieceType.bishop:
        return 330;
      case ChessPieceType.rook:
        return 500;
      case ChessPieceType.queen:
        return 900;
      case ChessPieceType.king:
        return 20000;
    }
  }

  String get symbol {
    switch (type) {
      case ChessPieceType.king:
        return color == ChessColor.white ? '♔' : '♚';
      case ChessPieceType.queen:
        return color == ChessColor.white ? '♕' : '♛';
      case ChessPieceType.rook:
        return color == ChessColor.white ? '♖' : '♜';
      case ChessPieceType.bishop:
        return color == ChessColor.white ? '♗' : '♝';
      case ChessPieceType.knight:
        return color == ChessColor.white ? '♘' : '♞';
      case ChessPieceType.pawn:
        return color == ChessColor.white ? '♙' : '♟';
    }
  }
}

class ChessMove {
  final ChessPosition from;
  final ChessPosition to;
  final ChessPiece? capturedPiece;
  final ChessPieceType? promotion;
  final bool isCastling;
  final bool isEnPassant;

  const ChessMove({
    required this.from,
    required this.to,
    this.capturedPiece,
    this.promotion,
    this.isCastling = false,
    this.isEnPassant = false,
  });

  String get notation => toString();

  @override
  String toString() {
    return '${from.notation}->${to.notation}${promotion != null ? '(${promotion!.name})' : ''}';
  }
}
