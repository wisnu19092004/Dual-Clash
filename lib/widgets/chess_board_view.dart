import 'package:flutter/material.dart';
import 'package:game_papan/chess/chess_board.dart';
import 'package:game_papan/chess/chess_piece.dart';
import 'package:game_papan/widgets/chess_piece_widget.dart';

class ChessBoardView extends StatelessWidget {
  final ChessBoard board;
  final ChessPosition? selectedPosition;
  final List<ChessMove> validMovesForSelected;
  final Function(int row, int col) onSquareTap;
  final ChessPosition? lastMoveFrom;
  final ChessPosition? lastMoveTo;
  final ChessPiece? animatedPiece;
  final ChessColor playerPerspective;

  const ChessBoardView({
    super.key,
    required this.board,
    required this.selectedPosition,
    required this.validMovesForSelected,
    required this.onSquareTap,
    this.lastMoveFrom,
    this.lastMoveTo,
    this.animatedPiece,
    this.playerPerspective = ChessColor.white,
  });

  bool get _isFlipped => playerPerspective == ChessColor.black;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableW = constraints.maxWidth;
        final availableH = constraints.maxHeight;
        final boardSize = availableW < availableH ? availableW : availableH;
        const padding = 7.0;
        final innerBoardSize = boardSize - (padding * 2);
        final tileSize = innerBoardSize / 8;

        return Center(
          child: Container(
            width: boardSize,
            height: boardSize,
            padding: const EdgeInsets.all(padding),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF381F12), // Metallic Bronze Rim Top-Left
                  Color(0xFF1B0E07), // Dark Bronze Rim Body
                  Color(0xFF0F0703), // Deep Shadow Bottom-Right
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD97706).withValues(alpha: 0.25),
                  blurRadius: 22,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(color: const Color(0xFF92400E), width: 2.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: innerBoardSize,
                height: innerBoardSize,
                child: Stack(
                  children: [
                    // Grid Squares Layer
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8,
                          ),
                      itemCount: 64,
                      itemBuilder: (context, index) {
                        final gridRow = index ~/ 8;
                        final gridCol = index % 8;
                        // Transform display row/col to actual board row/col based on perspective
                        final actualRow = _isFlipped ? (7 - gridRow) : gridRow;
                        final actualCol = _isFlipped ? (7 - gridCol) : gridCol;

                        return _buildTileBackground(
                          actualRow,
                          actualCol,
                          gridRow,
                          gridCol,
                          tileSize,
                        );
                      },
                    ),

                    // Ultra-smooth Animated Piece Walk / Slide Layer
                    ..._buildSmoothMovingPieces(tileSize),
                    if (lastMoveFrom != null && lastMoveTo != null)
                      _buildMovingPiece(lastMoveFrom!, lastMoveTo!, tileSize),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTileBackground(
    int actualRow,
    int actualCol,
    int gridRow,
    int gridCol,
    double tileSize,
  ) {
    final isLightSquare = (actualRow + actualCol) % 2 == 0;
    final pos = ChessPosition(actualRow, actualCol);
    final piece = board.getPiece(pos);
    final isSelected = selectedPosition == pos;
    final isValidMove = validMovesForSelected.any((m) => m.to == pos);
    final isKingInCheck =
        board.isCheck &&
        piece?.type == ChessPieceType.king &&
        piece?.color == board.turn;

    // Rich bronze wood & golden cream checkerboard tiles inspired by the shield on logo
    Color tileColor = isLightSquare
        ? const Color(0xFFF3E5D0)
        : const Color(0xFF96603B);

    if (isSelected) {
      tileColor = const Color(0xFFF59E0B).withValues(alpha: 0.80);
    } else if (isKingInCheck) {
      tileColor = const Color(0xFFDC2626).withValues(alpha: 0.85);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onSquareTap(actualRow, actualCol),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: tileColor,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Coordinate labels matching perspective
            if (gridCol == 0)
              Positioned(
                top: 2,
                left: 3,
                child: Text(
                  '${8 - actualRow}',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: isLightSquare
                        ? const Color(0xFF6B3608)
                        : const Color(0xFFFDE68A),
                  ),
                ),
              ),
            if (gridRow == 7)
              Positioned(
                bottom: 2,
                right: 3,
                child: Text(
                  String.fromCharCode('a'.codeUnitAt(0) + actualCol),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: isLightSquare
                        ? const Color(0xFF6B3608)
                        : const Color(0xFFFDE68A),
                  ),
                ),
              ),

            // Move indicator dot / capture target ring
            if (isValidMove)
              AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: piece == null ? tileSize * 0.32 : tileSize * 0.84,
                  height: piece == null ? tileSize * 0.32 : tileSize * 0.84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: piece == null
                        ? const Color(0xFFD97706).withValues(alpha: 0.65)
                        : Colors.transparent,
                    border: piece != null
                        ? Border.all(color: const Color(0xFFEF4444), width: 3.2)
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSmoothMovingPieces(double tileSize) {
    final widgets = <Widget>[];

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final pos = ChessPosition(r, c);
        final piece = board.getPiece(pos);
        if (piece == null || pos == lastMoveTo) continue;

        final displayRow = _isFlipped ? (7 - r) : r;
        final displayCol = _isFlipped ? (7 - c) : c;

        widgets.add(
          Positioned(
            left: displayCol * tileSize,
            top: displayRow * tileSize,
            width: tileSize,
            height: tileSize,
            child: Center(
              child: IgnorePointer(
                child: ChessPieceWidget(piece: piece, tileSize: tileSize),
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  Widget _buildMovingPiece(
    ChessPosition from,
    ChessPosition to,
    double tileSize,
  ) {
    final piece = board.getPiece(to);
    if (piece == null) return const SizedBox.shrink();
    final fromRow = _isFlipped ? 7 - from.row : from.row;
    final fromCol = _isFlipped ? 7 - from.col : from.col;
    final toRow = _isFlipped ? 7 - to.row : to.row;
    final toCol = _isFlipped ? 7 - to.col : to.col;
    return TweenAnimationBuilder<double>(
      key: ValueKey(
        'chess_move_${from.notation}_${to.notation}_${board.moveHistory.length}',
      ),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) => Positioned(
        left: (fromCol + (toCol - fromCol) * progress) * tileSize,
        top: (fromRow + (toRow - fromRow) * progress) * tileSize,
        width: tileSize,
        height: tileSize,
        child: Center(
          child: IgnorePointer(
            child: ChessPieceWidget(piece: piece, tileSize: tileSize),
          ),
        ),
      ),
    );
  }
}
