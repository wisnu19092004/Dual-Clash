enum ShogiPlayer { sente, gote } // sente = Black/First Player (Bottom), gote = White/Second Player (Top)

enum ShogiPieceType {
  king,      // 王将 / 玉将 (Gyoku / Ou)
  rook,      // 飛車 (Hisha)
  promotedRook, // 竜王 (Ryu - Rook + King moves 1)
  bishop,    // 角行 (Kaku)
  promotedBishop, // 竜馬 (Uma - Bishop + King moves 1)
  gold,      // 金将 (Kin)
  silver,    // 銀将 (Gin)
  promotedSilver, // 成銀 (Narigin -> moves as Gold)
  knight,    // 桂馬 (Keima)
  promotedKnight, // 成桂 (Narikei -> moves as Gold)
  lance,     // 香車 (Kyosha)
  promotedLance,  // 成香 (Narikyo -> moves as Gold)
  pawn,      // 歩兵 (Fuhyo)
  promotedPawn,   // と金 (Tokin -> moves as Gold)
}

class ShogiPiece {
  final ShogiPieceType type;
  final ShogiPlayer player;

  const ShogiPiece({
    required this.type,
    required this.player,
  });

  bool get isPromoted {
    return type == ShogiPieceType.promotedRook ||
        type == ShogiPieceType.promotedBishop ||
        type == ShogiPieceType.promotedSilver ||
        type == ShogiPieceType.promotedKnight ||
        type == ShogiPieceType.promotedLance ||
        type == ShogiPieceType.promotedPawn;
  }

  bool get canPromote {
    return type == ShogiPieceType.rook ||
        type == ShogiPieceType.bishop ||
        type == ShogiPieceType.silver ||
        type == ShogiPieceType.knight ||
        type == ShogiPieceType.lance ||
        type == ShogiPieceType.pawn;
  }

  ShogiPieceType get promotedType {
    switch (type) {
      case ShogiPieceType.rook:
        return ShogiPieceType.promotedRook;
      case ShogiPieceType.bishop:
        return ShogiPieceType.promotedBishop;
      case ShogiPieceType.silver:
        return ShogiPieceType.promotedSilver;
      case ShogiPieceType.knight:
        return ShogiPieceType.promotedKnight;
      case ShogiPieceType.lance:
        return ShogiPieceType.promotedLance;
      case ShogiPieceType.pawn:
        return ShogiPieceType.promotedPawn;
      default:
        return type;
    }
  }

  ShogiPieceType get unpromotedType {
    switch (type) {
      case ShogiPieceType.promotedRook:
        return ShogiPieceType.rook;
      case ShogiPieceType.promotedBishop:
        return ShogiPieceType.bishop;
      case ShogiPieceType.promotedSilver:
        return ShogiPieceType.silver;
      case ShogiPieceType.promotedKnight:
        return ShogiPieceType.knight;
      case ShogiPieceType.promotedLance:
        return ShogiPieceType.lance;
      case ShogiPieceType.promotedPawn:
        return ShogiPieceType.pawn;
      default:
        return type;
    }
  }

  int get baseValue {
    switch (type) {
      case ShogiPieceType.king:
        return 20000;
      case ShogiPieceType.promotedRook:
        return 1200;
      case ShogiPieceType.rook:
        return 1000;
      case ShogiPieceType.promotedBishop:
        return 1050;
      case ShogiPieceType.bishop:
        return 850;
      case ShogiPieceType.gold:
        return 600;
      case ShogiPieceType.promotedSilver:
      case ShogiPieceType.promotedKnight:
      case ShogiPieceType.promotedLance:
      case ShogiPieceType.promotedPawn:
        return 580;
      case ShogiPieceType.silver:
        return 500;
      case ShogiPieceType.knight:
        return 350;
      case ShogiPieceType.lance:
        return 300;
      case ShogiPieceType.pawn:
        return 100;
    }
  }

  String get kanji {
    switch (type) {
      case ShogiPieceType.king:
        return player == ShogiPlayer.sente ? '玉' : '王';
      case ShogiPieceType.rook:
        return '飛';
      case ShogiPieceType.promotedRook:
        return '竜';
      case ShogiPieceType.bishop:
        return '角';
      case ShogiPieceType.promotedBishop:
        return '馬';
      case ShogiPieceType.gold:
        return '金';
      case ShogiPieceType.silver:
        return '銀';
      case ShogiPieceType.promotedSilver:
        return '全';
      case ShogiPieceType.knight:
        return '桂';
      case ShogiPieceType.promotedKnight:
        return '圭';
      case ShogiPieceType.lance:
        return '香';
      case ShogiPieceType.promotedLance:
        return '杏';
      case ShogiPieceType.pawn:
        return '歩';
      case ShogiPieceType.promotedPawn:
        return 'と';
    }
  }

  String get englishShort {
    switch (type) {
      case ShogiPieceType.king:
        return 'K';
      case ShogiPieceType.rook:
        return 'R';
      case ShogiPieceType.promotedRook:
        return '+R';
      case ShogiPieceType.bishop:
        return 'B';
      case ShogiPieceType.promotedBishop:
        return '+B';
      case ShogiPieceType.gold:
        return 'G';
      case ShogiPieceType.silver:
        return 'S';
      case ShogiPieceType.promotedSilver:
        return '+S';
      case ShogiPieceType.knight:
        return 'N';
      case ShogiPieceType.promotedKnight:
        return '+N';
      case ShogiPieceType.lance:
        return 'L';
      case ShogiPieceType.promotedLance:
        return '+L';
      case ShogiPieceType.pawn:
        return 'P';
      case ShogiPieceType.promotedPawn:
        return '+P';
    }
  }
}
