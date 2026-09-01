import 'package:flutter/material.dart';
import 'package:game_papan/shogi/shogi_board.dart';
import 'package:game_papan/shogi/shogi_piece.dart';
import 'package:game_papan/shogi/shogi_move.dart';
import 'package:game_papan/widgets/shogi_piece_widget.dart';

class ShogiBoardView extends StatelessWidget {
  final ShogiBoard board;
  final ShogiPosition? selectedPosition;
  final List<ShogiMove> validMoves;
  final Function(int row, int col) onSquareTap;
  final ShogiPosition? lastMoveFrom;
  final ShogiPosition? lastMoveTo;
  final ShogiPiece? animatedPiece;
  final ShogiPlayer playerPerspective;

  const ShogiBoardView({
    super.key,
    required this.board,
    required this.selectedPosition,
    required this.validMoves,
    required this.onSquareTap,
    this.lastMoveFrom,
    this.lastMoveTo,
    this.animatedPiece,
    this.playerPerspective = ShogiPlayer.sente,
  });

  bool get _isFlipped => playerPerspective == ShogiPlayer.gote;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;
        final boardSize = availableWidth < availableHeight
            ? availableWidth
            : availableHeight;

        const padding = 5.0;
        final innerBoardSize = boardSize - (padding * 2);
        final tileSize = innerBoardSize / 9;

        return Center(
          child: Container(
            width: boardSize,
            height: boardSize,
            padding: const EdgeInsets.all(padding),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF5D3915), // Deep Kaya Wood Border
                  Color(0xFF381F0E), // Rich Walnut Rim
                  Color(0xFF221107), // Shadow Corner
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEA580C).withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(color: const Color(0xFF9A632F), width: 2.8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
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
                            crossAxisCount: 9,
                          ),
                      itemCount: 81,
                      itemBuilder: (context, index) {
                        final gridRow = index ~/ 9;
                        final gridCol = index % 9;
                        final actualRow = _isFlipped ? (8 - gridRow) : gridRow;
                        final actualCol = _isFlipped ? (8 - gridCol) : gridCol;

                        return _buildTileBackground(
                          actualRow,
                          actualCol,
                          tileSize,
                        );
                      },
                    ),

                    // Star Points on Shogi Board
                    ..._buildStarPoints(tileSize),

                    // Ultra-smooth Animated Piece Walk / Slide Layer
                    ..._buildSmoothMovingPieces(tileSize),
                    if (lastMoveTo != null) _buildMovingPiece(tileSize),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTileBackground(int actualRow, int actualCol, double tileSize) {
    final pos = ShogiPosition(actualRow, actualCol);
    final isSelected = selectedPosition == pos;
    final isValidMove = validMoves.any((m) => m.to == pos);
    final piece = board.getPiece(pos);
    final isKingInCheck =
        board.isCheck &&
        piece?.type == ShogiPieceType.king &&
        piece?.player == board.turn;

    // Warm Japanese Cedar/Kaya Wooden board tiles
    Color tileColor = const Color(0xFFDFB376);
    if ((actualRow + actualCol) % 2 == 1) {
      tileColor = const Color(0xFFD6A767);
    }

    if (isSelected) {
      tileColor = const Color(0xFFF59E0B).withValues(alpha: 0.85);
    } else if (isKingInCheck) {
      tileColor = const Color(0xFFDC2626).withValues(alpha: 0.85);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onSquareTap(actualRow, actualCol),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: tileColor,
          border: Border.all(
            color: const Color(0xFF7A4A1C).withValues(alpha: 0.45),
            width: 0.5,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Move indicator dot / ring
            if (isValidMove)
              AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: piece == null ? tileSize * 0.30 : tileSize * 0.84,
                  height: piece == null ? tileSize * 0.30 : tileSize * 0.84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: piece == null
                        ? const Color(0xFFC2410C).withValues(alpha: 0.70)
                        : Colors.transparent,
                    border: piece != null
                        ? Border.all(color: const Color(0xFFEF4444), width: 3.0)
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStarPoints(double tileSize) {
    final starCoordinates = [
      const Point(3, 3),
      const Point(3, 6),
      const Point(6, 3),
      const Point(6, 6),
    ];

    return starCoordinates.map((pt) {
      final displayRow = _isFlipped ? (8 - pt.row) : pt.row;
      final displayCol = _isFlipped ? (8 - pt.col) : pt.col;

      return Positioned(
        left: (displayCol * tileSize) - 2.5,
        top: (displayRow * tileSize) - 2.5,
        child: IgnorePointer(
          child: Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFF5D3915),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildSmoothMovingPieces(double tileSize) {
    final widgets = <Widget>[];

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final pos = ShogiPosition(r, c);
        final piece = board.getPiece(pos);
        if (piece == null || pos == lastMoveTo) continue;

        final displayRow = _isFlipped ? (8 - r) : r;
        final displayCol = _isFlipped ? (8 - c) : c;

        // Determine if this piece points down relative to player's screen perspective:
        // The piece of the active player perspective points UP, opponent's piece points DOWN
        final isFacingDown = piece.player != playerPerspective;

        widgets.add(
          Positioned(
            left: displayCol * tileSize,
            top: displayRow * tileSize,
            width: tileSize,
            height: tileSize,
            child: Center(
              child: IgnorePointer(
                child: ShogiPieceWidget(
                  piece: piece,
                  baseTileSize: tileSize,
                  isFacingDown: isFacingDown,
                ),
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  Widget _buildMovingPiece(double tileSize) {
    final to = lastMoveTo!;
    final piece = board.getPiece(to);
    if (piece == null) return const SizedBox.shrink();
    final from = lastMoveFrom;
    final fromRow = from == null
        ? (_isFlipped ? 8 - to.row : to.row)
        : (_isFlipped ? 8 - from.row : from.row);
    final fromCol = from == null
        ? (_isFlipped ? 8 - to.col : to.col)
        : (_isFlipped ? 8 - from.col : from.col);
    final toRow = _isFlipped ? 8 - to.row : to.row;
    final toCol = _isFlipped ? 8 - to.col : to.col;
    final isFacingDown = piece.player != playerPerspective;

    return TweenAnimationBuilder<double>(
      key: ValueKey('shogi_move_${from}_${to}_${board.moveHistory.length}'),
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
            child: ShogiPieceWidget(
              piece: piece,
              baseTileSize: tileSize,
              isFacingDown: isFacingDown,
            ),
          ),
        ),
      ),
    );
  }
}

class Point {
  final int row;
  final int col;
  const Point(this.row, this.col);
}
