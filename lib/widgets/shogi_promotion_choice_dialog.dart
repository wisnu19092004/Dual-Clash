import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:game_papan/shogi/shogi_move.dart';
import 'package:game_papan/widgets/interactive_button.dart';

class ShogiPromotionChoiceDialog extends StatelessWidget {
  final List<ShogiMove> moves;
  final ValueChanged<ShogiMove> onMoveSelected;

  const ShogiPromotionChoiceDialog({
    super.key,
    required this.moves,
    required this.onMoveSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Promosikan Bidak? (成る)',
        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'Bidak Anda memasuki area promosi. Ingin mempromosikannya sekarang?',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        InteractiveButton(
          onPressed: () {
            Navigator.pop(context);
            final nonPromoteMove = moves.firstWhere((m) => !m.promote, orElse: () => moves.first);
            onMoveSelected(nonPromoteMove);
          },
          backgroundColor: Colors.transparent,
          border: Border.all(color: Colors.white24),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: const Text('Tidak Promosi', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ),
        InteractiveButton(
          onPressed: () {
            Navigator.pop(context);
            final promoteMove = moves.firstWhere((m) => m.promote, orElse: () => moves.first);
            onMoveSelected(promoteMove);
          },
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: const Text('Promosi (成)', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
