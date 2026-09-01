import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:game_papan/services/language_provider.dart';
import 'package:game_papan/theme/app_colors.dart';
import 'package:game_papan/widgets/game_emblem_icon.dart';

class GameGuideScreen extends StatefulWidget {
  final int initialTabIndex;
  final bool showBackButton;

  const GameGuideScreen({
    super.key,
    this.initialTabIndex = 0,
    this.showBackButton = true,
  });

  @override
  State<GameGuideScreen> createState() => _GameGuideScreenState();
}

class _GameGuideScreenState extends State<GameGuideScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().currentLanguage;
    final content = _GuideContent.forLanguage(language);
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        automaticallyImplyLeading: false,
        leading: widget.showBackButton
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textColor(context),
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Row(
          children: [
            const Icon(
              Icons.menu_book_rounded,
              color: Color(0xFFFBBF24),
              size: 22,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                content.title,
                style: GoogleFonts.cinzel(
                  color: AppColors.textColor(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor(context)),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD97706), Color(0xFF92400E)],
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondaryColor(context),
              labelStyle: GoogleFonts.cinzel(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              tabs: [
                Tab(child: _tabLabel(true, content.chessTab)),
                Tab(child: _tabLabel(false, content.shogiTab)),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildGuide(content.chess), _buildGuide(content.shogi)],
      ),
    );
  }

  Widget _tabLabel(bool isChess, String text) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      GameEmblemIcon(isChess: isChess, size: 16),
      const SizedBox(width: 6),
      Text(text),
    ],
  );

  Widget _buildGuide(_GameGuide guide) => SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section(guide.goalTitle, Icons.flag_rounded),
        _textCard(guide.goal),
        const SizedBox(height: 18),
        _section(guide.piecesTitle, Icons.extension_rounded),
        ...guide.pieces.expand(
          (piece) => [_pieceCard(piece), const SizedBox(height: 10)],
        ),
        const SizedBox(height: 8),
        _section(guide.rulesTitle, Icons.auto_awesome),
        ...guide.rules.map(_ruleCard),
      ],
    ),
  );

  Widget _section(String title, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFFFBBF24), size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.cinzel(
              color: const Color(0xFFFDE68A),
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _textCard(String text) => _card(
    Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        color: AppColors.textColor(context),
        fontSize: 12.5,
        height: 1.5,
      ),
    ),
  );

  Widget _pieceCard(_GuideItem item) => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: GoogleFonts.cinzel(
            color: const Color(0xFFFBBF24),
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          item.description,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textColor(context),
            fontSize: 11.5,
            height: 1.4,
          ),
        ),
        if (item.note != null) ...[
          const SizedBox(height: 5),
          Text(
            item.note!,
            style: const TextStyle(
              color: Color(0xFFFDE68A),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    ),
  );

  Widget _ruleCard(_GuideItem item) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: _pieceCard(item),
  );

  Widget _card(Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.borderColor(context)),
    ),
    child: child,
  );
}

class _GuideItem {
  final String title;
  final String description;
  final String? note;
  const _GuideItem(this.title, this.description, [this.note]);
}

class _GameGuide {
  final String goalTitle, goal, piecesTitle, rulesTitle;
  final List<_GuideItem> pieces, rules;
  const _GameGuide(
    this.goalTitle,
    this.goal,
    this.piecesTitle,
    this.rulesTitle,
    this.pieces,
    this.rules,
  );
}

class _GuideContent {
  final String title, chessTab, shogiTab;
  final _GameGuide chess, shogi;
  const _GuideContent(
    this.title,
    this.chessTab,
    this.shogiTab,
    this.chess,
    this.shogi,
  );

  static _GuideContent forLanguage(AppLanguage language) => switch (language) {
    AppLanguage.english => _english,
    AppLanguage.japanese => _japanese,
    AppLanguage.malay => _malay,
    AppLanguage.indonesian => _indonesian,
  };

  static const _indonesian = _GuideContent(
    'Panduan & Ensiklopedia Game',
    'Panduan Catur',
    'Panduan Shogi',
    _GameGuide(
      'Tujuan Permainan Catur',
      'Jebak Raja lawan dalam skak tanpa langkah legal untuk melarikan diri, memblokir serangan, atau menangkap penyerang. Kondisi ini disebut skakmat.',
      'Daftar Bidak & Gerakan',
      'Aturan Khusus Catur',
      [
        _GuideItem(
          'Raja (King)',
          'Bergerak satu petak ke segala arah dan tidak boleh masuk ke petak yang diserang.',
          'Dapat melakukan rokade.',
        ),
        _GuideItem(
          'Ratu (Queen)',
          'Bergerak bebas secara lurus maupun diagonal.',
          'Nilai 9 poin; bidak terkuat.',
        ),
        _GuideItem(
          'Benteng (Rook)',
          'Bergerak lurus horizontal atau vertikal.',
          'Nilai 5 poin; kuat di lajur terbuka.',
        ),
        _GuideItem(
          'Gajah (Bishop)',
          'Bergerak diagonal sejauh petak kosong.',
          'Nilai 3 poin; selalu berada pada warna petak yang sama.',
        ),
        _GuideItem(
          'Kuda (Knight)',
          'Bergerak membentuk huruf L dan dapat melompati bidak lain.',
          'Nilai 3 poin.',
        ),
        _GuideItem(
          'Pion (Pawn)',
          'Maju satu petak, atau dua petak pada langkah awal; menangkap secara diagonal.',
          'Nilai 1 poin; dapat promosi di baris terakhir.',
        ),
      ],
      [
        _GuideItem(
          '1. Rokade',
          'Raja dan Benteng bergerak bersamaan. Keduanya belum pernah bergerak dan jalur Raja tidak boleh diserang.',
        ),
        _GuideItem(
          '2. En Passant',
          'Pion yang baru maju dua petak dapat ditangkap pada giliran berikutnya oleh pion lawan yang dilewatinya.',
        ),
        _GuideItem(
          '3. Promosi Pion',
          'Pion di baris terakhir dapat menjadi Ratu, Benteng, Gajah, atau Kuda.',
        ),
      ],
    ),
    _GameGuide(
      'Tujuan Permainan Shogi',
      'Shogi adalah catur Jepang 9x9. Skakmat Raja lawan. Bidak yang ditangkap menjadi milik Anda dan dapat diterjunkan kembali ke papan.',
      'Daftar Bidak & Gerakan',
      'Aturan Khas Shogi',
      [
        _GuideItem(
          '王将 Osho / Raja',
          'Bergerak satu petak ke delapan arah.',
          'Tidak dapat dipromosikan.',
        ),
        _GuideItem(
          '飛車 Hisha / Benteng',
          'Bergerak lurus horizontal atau vertikal tanpa batas.',
          'Promosi: Naga, juga dapat satu langkah diagonal.',
        ),
        _GuideItem(
          '角行 Kakugyo / Gajah',
          'Bergerak diagonal tanpa batas.',
          'Promosi: Kuda Terbang, juga dapat satu langkah lurus.',
        ),
        _GuideItem(
          '金将 Kinsho / Jenderal Emas',
          'Satu petak ke maju, mundur, kiri, kanan, atau diagonal depan.',
          'Tidak dapat dipromosikan.',
        ),
        _GuideItem(
          '銀将 Ginsho / Jenderal Perak',
          'Satu petak ke depan atau keempat diagonal.',
          'Promosi: bergerak seperti Jenderal Emas.',
        ),
        _GuideItem(
          '桂馬 Keima / Kuda',
          'Melompat dua petak maju dan satu ke samping.',
          'Promosi: bergerak seperti Jenderal Emas.',
        ),
        _GuideItem(
          '香車 Kyosha / Tombak',
          'Meluncur lurus ke depan tanpa batas.',
          'Promosi: bergerak seperti Jenderal Emas.',
        ),
        _GuideItem(
          '歩兵 Fuhyo / Pion',
          'Bergerak satu petak lurus ke depan.',
          'Promosi: Tokin, bergerak seperti Jenderal Emas.',
        ),
      ],
      [
        _GuideItem(
          '1. Drop',
          'Bidak tangkapan disimpan di tangan dan dapat diterjunkan ke petak kosong sebagai giliran Anda.',
        ),
        _GuideItem(
          '2. Zona Promosi',
          'Tiga baris wilayah lawan adalah zona promosi; bidak yang bergerak melaluinya dapat dipromosikan.',
        ),
        _GuideItem(
          '3. Nifu',
          'Tidak boleh menjatuhkan pion pada lajur yang sudah berisi pion Anda yang belum promosi.',
        ),
        _GuideItem(
          '4. Uchifuzume',
          'Tidak boleh menjatuhkan pion yang langsung menghasilkan skakmat.',
        ),
      ],
    ),
  );

  static const _english = _GuideContent(
    'Game Guide & Encyclopedia',
    'Chess Guide',
    'Shogi Guide',
    _GameGuide(
      'Objective of Chess',
      'Trap the opposing King in check with no legal escape, block, or capture. This is checkmate.',
      'Pieces & Movement',
      'Special Chess Rules',
      [
        _GuideItem(
          'King',
          'Moves one square in any direction and may not enter an attacked square.',
          'May castle.',
        ),
        _GuideItem(
          'Queen',
          'Moves any distance straight or diagonally.',
          'Worth 9 points; the strongest piece.',
        ),
        _GuideItem(
          'Rook',
          'Moves any distance horizontally or vertically.',
          'Worth 5 points.',
        ),
        _GuideItem(
          'Bishop',
          'Moves any distance diagonally.',
          'Worth 3 points; remains on one square color.',
        ),
        _GuideItem(
          'Knight',
          'Moves in an L shape and can jump over pieces.',
          'Worth 3 points.',
        ),
        _GuideItem(
          'Pawn',
          'Moves forward one square, or two from its start; captures diagonally.',
          'Worth 1 point; promotes on the last rank.',
        ),
      ],
      [
        _GuideItem(
          '1. Castling',
          'The King and Rook move together. Neither may have moved and the King may not cross attacked squares.',
        ),
        _GuideItem(
          '2. En Passant',
          'A pawn that advances two squares can be captured by an adjacent enemy pawn on the next turn.',
        ),
        _GuideItem(
          '3. Pawn Promotion',
          'A pawn reaching the last rank becomes a Queen, Rook, Bishop, or Knight.',
        ),
      ],
    ),
    _GameGuide(
      'Objective of Shogi',
      'Shogi is Japanese 9x9 chess. Checkmate the enemy King. Captured pieces become yours and can be dropped back onto the board.',
      'Pieces & Movement',
      'Essential Shogi Rules',
      [
        _GuideItem(
          '王将 Osho / King',
          'Moves one square in all eight directions.',
          'Cannot promote.',
        ),
        _GuideItem(
          '飛車 Hisha / Rook',
          'Moves any distance horizontally or vertically.',
          'Promotes to Dragon: also one diagonal step.',
        ),
        _GuideItem(
          '角行 Kakugyo / Bishop',
          'Moves any distance diagonally.',
          'Promotes to Horse: also one straight step.',
        ),
        _GuideItem(
          '金将 Kinsho / Gold General',
          'One square forward, backward, sideways, or diagonally forward.',
          'Cannot promote.',
        ),
        _GuideItem(
          '銀将 Ginsho / Silver General',
          'One square forward or diagonally.',
          'Promotes to Gold movement.',
        ),
        _GuideItem(
          '桂馬 Keima / Knight',
          'Jumps two squares forward and one sideways.',
          'Promotes to Gold movement.',
        ),
        _GuideItem(
          '香車 Kyosha / Lance',
          'Slides any distance straight forward.',
          'Promotes to Gold movement.',
        ),
        _GuideItem(
          '歩兵 Fuhyo / Pawn',
          'Moves one square straight forward.',
          'Promotes to Tokin with Gold movement.',
        ),
      ],
      [
        _GuideItem(
          '1. Drop',
          'Captured pieces are held in hand and may be dropped on an empty square instead of a move.',
        ),
        _GuideItem(
          '2. Promotion Zone',
          'The opponent\'s three farthest ranks form the promotion zone.',
        ),
        _GuideItem(
          '3. Nifu',
          'You may not drop a pawn into a file already containing your unpromoted pawn.',
        ),
        _GuideItem(
          '4. Uchifuzume',
          'A pawn drop may not give immediate checkmate.',
        ),
      ],
    ),
  );

  static const _malay = _GuideContent(
    'Panduan & Ensiklopedia Permainan',
    'Panduan Catur',
    'Panduan Syogi',
    _GameGuide(
      'Matlamat Catur',
      'Perangkap Raja lawan dalam keadaan skak tanpa langkah sah untuk melarikan diri, menghalang serangan, atau menangkap penyerang. Keadaan ini dipanggil skakmat.',
      'Buah & Pergerakan',
      'Peraturan Khas Catur',
      [
        _GuideItem(
          'Raja (King)',
          'Bergerak satu petak ke semua arah dan tidak boleh memasuki petak yang diserang.',
          'Boleh melakukan rokade.',
        ),
        _GuideItem(
          'Ratu (Queen)',
          'Bergerak bebas secara lurus atau pepenjuru.',
          'Bernilai 9 mata.',
        ),
        _GuideItem(
          'Benteng (Rook)',
          'Bergerak lurus mendatar atau menegak.',
          'Bernilai 5 mata.',
        ),
        _GuideItem(
          'Gajah (Bishop)',
          'Bergerak pepenjuru sejauh petak kosong.',
          'Bernilai 3 mata.',
        ),
        _GuideItem(
          'Kuda (Knight)',
          'Bergerak berbentuk L dan boleh melompat buah lain.',
          'Bernilai 3 mata.',
        ),
        _GuideItem(
          'Pion (Pawn)',
          'Maju satu petak dan menangkap secara pepenjuru.',
          'Bernilai 1 mata; boleh dinaikkan pangkat.',
        ),
      ],
      [
        _GuideItem(
          '1. Rokade',
          'Raja dan Benteng bergerak serentak jika belum bergerak dan laluan Raja tidak diserang.',
        ),
        _GuideItem(
          '2. En Passant',
          'Pion yang baru maju dua petak boleh ditangkap oleh pion lawan pada giliran berikutnya.',
        ),
        _GuideItem(
          '3. Kenaikan Pangkat Pion',
          'Pion di barisan terakhir boleh menjadi Ratu, Benteng, Gajah, atau Kuda.',
        ),
      ],
    ),
    _GameGuide(
      'Matlamat Syogi',
      'Syogi ialah catur Jepun 9x9. Skakmat Raja lawan. Buah yang ditangkap menjadi milik anda dan boleh diterjunkan semula ke papan.',
      'Buah & Pergerakan',
      'Peraturan Penting Syogi',
      [
        _GuideItem(
          '王将 Osho / Raja',
          'Bergerak satu petak ke lapan arah.',
          'Tidak boleh dinaikkan pangkat.',
        ),
        _GuideItem(
          '飛車 Hisha / Benteng',
          'Bergerak lurus tanpa had.',
          'Naik pangkat: Naga.',
        ),
        _GuideItem(
          '角行 Kakugyo / Gajah',
          'Bergerak pepenjuru tanpa had.',
          'Naik pangkat: Kuda Terbang.',
        ),
        _GuideItem(
          '金将 Kinsho / Jeneral Emas',
          'Satu petak ke hadapan, belakang, sisi, atau pepenjuru hadapan.',
        ),
        _GuideItem(
          '銀将 Ginsho / Jeneral Perak',
          'Satu petak ke hadapan atau pepenjuru.',
          'Naik pangkat: gerakan Jeneral Emas.',
        ),
        _GuideItem(
          '桂馬 Keima / Kuda',
          'Melompat dua petak ke hadapan dan satu ke sisi.',
          'Naik pangkat: gerakan Jeneral Emas.',
        ),
        _GuideItem(
          '香車 Kyosha / Lembing',
          'Meluncur lurus ke hadapan tanpa had.',
          'Naik pangkat: gerakan Jeneral Emas.',
        ),
        _GuideItem(
          '歩兵 Fuhyo / Pion',
          'Bergerak satu petak lurus ke hadapan.',
          'Naik pangkat: Tokin.',
        ),
      ],
      [
        _GuideItem(
          '1. Drop',
          'Buah tangkapan boleh diterjunkan ke petak kosong sebagai langkah anda.',
        ),
        _GuideItem(
          '2. Zon Promosi',
          'Tiga baris kawasan lawan ialah zon promosi.',
        ),
        _GuideItem(
          '3. Nifu',
          'Tidak boleh menerjunkan pion pada lajur yang sudah mempunyai pion anda yang belum promosi.',
        ),
        _GuideItem(
          '4. Uchifuzume',
          'Tidak boleh menerjunkan pion yang terus menyebabkan skakmat.',
        ),
      ],
    ),
  );
  static const _japanese = _GuideContent(
    'ゲームガイド・百科事典',
    'チェスガイド',
    '将棋ガイド',
    _GameGuide(
      'チェスの目的',
      '相手のキングをチェック状態にし、逃げる・防ぐ・攻撃駒を取る合法手がない状態にします。これをチェックメイトといいます。',
      '駒と動き',
      'チェスの特別ルール',
      [
        _GuideItem('キング', '全方向に1マス動きます。相手の利きがあるマスには移動できません。', 'キャスリングが可能です。'),
        _GuideItem('クイーン', '縦・横・斜めに何マスでも動けます。', '価値は9点です。'),
        _GuideItem('ルーク', '縦または横に何マスでも動けます。', '価値は5点です。'),
        _GuideItem('ビショップ', '斜めに何マスでも動けます。', '価値は3点です。'),
        _GuideItem('ナイト', 'L字に動き、他の駒を飛び越えられます。', '価値は3点です。'),
        _GuideItem('ポーン', '前に1マス進み、斜め前の駒を取ります。', '最終段で昇格できます。'),
      ],
      [
        _GuideItem(
          '1. キャスリング',
          'キングとルークを同時に動かします。両方が未移動で、キングの通過するマスが攻撃されていない必要があります。',
        ),
        _GuideItem('2. アンパッサン', '2マス進んだポーンは、直後の手番に相手ポーンで取ることができます。'),
        _GuideItem('3. ポーン昇格', '最終段に到達したポーンはクイーン、ルーク、ビショップ、ナイトになります。'),
      ],
    ),
    _GameGuide(
      '将棋の目的',
      '将棋は9x9の日本の盤上ゲームです。相手の王を詰ませます。取った駒は自分の持ち駒となり、盤上に打てます。',
      '駒と動き',
      '将棋の重要ルール',
      [
        _GuideItem('王将', '周囲8方向に1マス動きます。', '成れません。'),
        _GuideItem('飛車', '縦横に何マスでも動けます。', '成ると竜王になります。'),
        _GuideItem('角行', '斜めに何マスでも動けます。', '成ると竜馬になります。'),
        _GuideItem('金将', '前後左右と前斜めに1マス動けます。'),
        _GuideItem('銀将', '前と4つの斜めに1マス動けます。', '成ると金将と同じ動きです。'),
        _GuideItem('桂馬', '前方へ2マス、横に1マス跳びます。', '成ると金将と同じ動きです。'),
        _GuideItem('香車', '前方に何マスでも進めます。', '成ると金将と同じ動きです。'),
        _GuideItem('歩兵', '前に1マス進みます。', '成るとと金になります。'),
      ],
      [
        _GuideItem('1. 駒打ち', '持ち駒を空いているマスに打てます。'),
        _GuideItem('2. 成り', '相手陣の3段は成りの区域です。'),
        _GuideItem('3. 二歩', '未成の自分の歩がある筋には歩を打てません。'),
        _GuideItem('4. 打ち歩詰め', '歩を打って即詰みにすることはできません。'),
      ],
    ),
  );
}
