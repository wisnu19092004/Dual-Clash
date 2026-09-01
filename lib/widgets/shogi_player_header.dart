import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:game_papan/shogi/shogi_piece.dart';
import 'package:game_papan/theme/app_colors.dart';
import 'package:game_papan/widgets/shogi_piece_widget.dart';
import 'package:game_papan/widgets/interactive_button.dart';

/// Authentic Shogi Online Style Player Header with Fixed Komadai (駒台)
/// Preserves fixed height at all times so that UI never jumps or shifts during piece captures/drops.
class ShogiPlayerHeader extends StatelessWidget {
  final String name;
  final int rating;
  final ShogiPlayer player;
  final String timeString;
  final bool isCurrentTurn;
  final bool isAi;
  final List<ShogiPieceType>? handPieces;
  final ShogiPieceType? selectedHandPiece;
  final Function(ShogiPieceType pieceType)? onHandPieceTap;
  final VoidCallback? onUndoMove;

  const ShogiPlayerHeader({
    super.key,
    required this.name,
    required this.rating,
    required this.player,
    required this.timeString,
    required this.isCurrentTurn,
    required this.isAi,
    this.handPieces,
    this.selectedHandPiece,
    this.onHandPieceTap,
    this.onUndoMove,
  });

  // Standard Shogi piece types eligible for hand (Komadai)
  static const List<ShogiPieceType> _handPieceTypes = [
    ShogiPieceType.rook,
    ShogiPieceType.bishop,
    ShogiPieceType.gold,
    ShogiPieceType.silver,
    ShogiPieceType.knight,
    ShogiPieceType.lance,
    ShogiPieceType.pawn,
  ];

  @override
  Widget build(BuildContext context) {
    final isSente = player == ShogiPlayer.sente;
    final pieces = handPieces ?? [];

    final Map<ShogiPieceType, int> counts = {};
    for (final type in pieces) {
      counts[type] = (counts[type] ?? 0) + 1;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      height: 82, // Constant fixed height for rock-solid zero UI shift
      decoration: BoxDecoration(
        color: isCurrentTurn ? AppColors.surface(context) : AppColors.surfaceDark(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentTurn ? const Color(0xFFEA580C) : AppColors.borderColor(context),
          width: isCurrentTurn ? 2.0 : 1.0,
        ),
        boxShadow: isCurrentTurn
            ? [
                BoxShadow(
                  color: const Color(0xFFC2410C).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              ]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Player Info, Name, Rating & Time
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF0D4), Color(0xFFECC48C), Color(0xFFC99554)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: const Color(0xFF78350F), width: 1.2),
                ),
                alignment: Alignment.center,
                child: Text(
                  isSente ? '☗' : '☖',
                  style: GoogleFonts.sawarabiMincho(
                    color: const Color(0xFF381A08),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: GoogleFonts.cinzel(
                          color: AppColors.textColor(context),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC2410C).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFEA580C), width: 0.6),
                      ),
                      child: Text(
                        '$rating',
                        style: const TextStyle(
                          color: Color(0xFFFB923C),
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (onUndoMove != null) ...[
                InteractiveButton(
                  onPressed: onUndoMove,
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  backgroundColor: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFFEA580C).withValues(alpha: 0.7),
                    width: 1,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.replay_rounded, size: 12, color: Color(0xFFFB923C)),
                      SizedBox(width: 2),
                      Text(
                        'Undo',
                        style: TextStyle(
                          color: Color(0xFFFB923C),
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: isCurrentTurn
                      ? const LinearGradient(
                          colors: [Color(0xFFC2410C), Color(0xFF7C2D12)],
                        )
                      : null,
                  color: isCurrentTurn ? null : AppColors.surfaceDark(context),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isCurrentTurn ? const Color(0xFFFB923C) : AppColors.borderColor(context),
                    width: 1,
                  ),
                ),
                child: Text(
                  timeString,
                  style: GoogleFonts.robotoMono(
                    color: isCurrentTurn ? Colors.white : AppColors.textColor(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),

          // Bottom Row: Fixed-Grid Shogi Online Style Komadai Bar (駒台)
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF26140A), Color(0xFF190C05)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF5D3915), width: 1.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _handPieceTypes.map((type) {
                final count = counts[type] ?? 0;
                final isAvailable = count > 0;
                final isSelected = selectedHandPiece == type;

                return GestureDetector(
                  onTap: isAvailable && isCurrentTurn && onHandPieceTap != null
                      ? () => onHandPieceTap!(type)
                      : null,
                  child: Container(
                    width: 38,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFEA580C).withValues(alpha: 0.45)
                          : (isAvailable ? const Color(0xFF381F0E) : Colors.transparent),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFF97316)
                            : (isAvailable ? const Color(0xFF78350F) : Colors.transparent),
                        width: isSelected ? 1.5 : 0.8,
                      ),
                    ),
                    child: isAvailable
                        ? Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              ShogiPieceWidget(
                                piece: ShogiPiece(type: type, player: player),
                                baseTileSize: 24,
                                isFacingDown: false,
                              ),
                              if (count > 1)
                                Positioned(
                                  right: -5,
                                  bottom: -4,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFDC2626),
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$count',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : Text(
                            ShogiPiece(type: type, player: player).kanji,
                            style: GoogleFonts.sawarabiMincho(
                              color: const Color(0xFF5D3915).withValues(alpha: 0.4),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
