import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  indonesian('id', 'Bahasa Indonesia', '🇮🇩', 'Indonesia'),
  english('en', 'English', '🇬🇧', 'English'),
  japanese('ja', '日本語 (Japanese)', '🇯🇵', 'Japan'),
  malay('ms', 'Bahasa Melayu', '🇲🇾', 'Malaysia');

  final String code;
  final String label;
  final String flag;
  final String region;

  const AppLanguage(this.code, this.label, this.flag, this.region);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (e) => e.code == code,
      orElse: () => AppLanguage.indonesian,
    );
  }
}

class LanguageProvider extends ChangeNotifier {
  static const String _prefKey = 'app_language_code';
  AppLanguage _currentLanguage = AppLanguage.indonesian;

  LanguageProvider() {
    _loadLanguage();
  }

  AppLanguage get currentLanguage => _currentLanguage;
  Locale get currentLocale => Locale(_currentLanguage.code);

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey);
    if (code != null) {
      _currentLanguage = AppLanguage.fromCode(code);
      notifyListeners();
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage == language) return;
    _currentLanguage = language;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, language.code);
  }

  // Localized string dictionary helper
  String tr(String key) {
    final code = _currentLanguage.code;
    return _translations[key]?[code] ?? _translations[key]?['id'] ?? key;
  }

  String trArgs(String key, Map<String, String> values) {
    var text = tr(key);
    for (final entry in values.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value);
    }
    return text;
  }

  static const Map<String, Map<String, String>> _translations = {
    // App & Header
    'app_title': {
      'id': 'Dual Clash - Catur & Shogi',
      'en': 'Dual Clash - Chess & Shogi',
      'ja': 'Dual Clash - チェス & 将棋',
      'ms': 'Dual Clash - Catur & Syogi',
    },
    'duel_strategy': {
      'id': 'DUEL STRATEGI',
      'en': 'STRATEGY DUEL',
      'ja': '戦略の決闘',
      'ms': 'DUEL STRATEGI',
    },
    'official_edition': {
      'id': 'OFFICIAL CLASH EDITION',
      'en': 'OFFICIAL CLASH EDITION',
      'ja': '公式クラッシュエディション',
      'ms': 'EDISI CLASH RASMI',
    },
    'hero_desc': {
      'id':
          'Dua mahakarya strategi papan dalam satu genggaman arena bergengsi.',
      'en': 'Two board strategy masterworks in one prestigious arena.',
      'ja': '最高峰の盤上戦略ゲームを、一つの舞台で。',
      'ms': 'Dua mahakarya strategi papan dalam satu arena berprestij.',
    },
    'guide': {'id': 'Panduan', 'en': 'Guide', 'ja': 'ガイド', 'ms': 'Panduan'},
    'bot_tiers_badge': {
      'id': '6 Tingkat AI (800 - 2400 ELO)',
      'en': '6 AI Tiers (800 - 2400 ELO)',
      'ja': 'AI難易度 6段階（800 - 2400 ELO）',
      'ms': '6 Tahap AI (800 - 2400 ELO)',
    },
    'shogi_features_badge': {
      'id': 'Komadai & Drop Otentik',
      'en': 'Authentic Komadai & Drops',
      'ja': '本格的な駒台と駒打ち',
      'ms': 'Komadai & Drop Asli',
    },
    'profile': {
      'id': 'Profil',
      'en': 'Profile',
      'ja': 'プロフィール',
      'ms': 'Profil',
    },
    'leaderboard': {
      'id': 'Papan Peringkat',
      'en': 'Leaderboard',
      'ja': 'ランキング',
      'ms': 'Papan Kedudukan',
    },
    'language': {
      'id': 'Bahasa / Language',
      'en': 'Language / Bahasa',
      'ja': '言語設定 (Language)',
      'ms': 'Bahasa / Language',
    },
    'select_language': {
      'id': 'Pilih Bahasa Aplikasi',
      'en': 'Select App Language',
      'ja': 'アプリの言語を選択',
      'ms': 'Pilih Bahasa Aplikasi',
    },
    'theme_setting': {
      'id': 'Tema Tampilan UI',
      'en': 'UI Theme Mode',
      'ja': 'テーマ表示設定',
      'ms': 'Tema Paparan UI',
    },

    // Arena Selection
    'choose_arena': {
      'id': 'PILIH ARENA STRATEGI',
      'en': 'CHOOSE STRATEGY ARENA',
      'ja': '対局アリーナを選択',
      'ms': 'PILIH ARENA STRATEGI',
    },
    'chess_title': {
      'id': 'Catur Klasik (Chess)',
      'en': 'Classic Chess',
      'ja': 'クラシックチェス (Chess)',
      'ms': 'Catur Klasik (Chess)',
    },
    'chess_desc': {
      'id': 'Strategi 8x8 papan dunia barat. Skakmat raja lawan dengan formasi taktik tak tertandingi.',
      'en': '8x8 western battlefield. Checkmate the enemy king with unmatched tactics.',
      'ja': '8x8マスの西洋戦略。多彩な戦術で相手のキングを詰ませろ。',
      'ms': 'Strategi 8x8 papan dunia barat. Skakmat raja lawan dengan formasi taktikal terunggul.',
    },
    'shogi_title': {
      'id': 'Shogi Jepang (将棋)',
      'en': 'Japanese Shogi (将棋)',
      'ja': '日本将棋 (Shogi)',
      'ms': 'Syogi Jepun (将棋)',
    },
    'shogi_desc': {
      'id': 'Catur tradisional Jepang 9x9 dengan aturan Drop (memainkan kembali bidak yang ditangkap) & Promosi.',
      'en': 'Traditional 9x9 Japanese chess with piece drop mechanics & promotion.',
      'ja': '取った駒を使える「持ち駒」と「成駒」が鍵を握る9x9の伝統日本将棋。',
      'ms': 'Catur tradisional Jepun 9x9 dengan peraturan Drop (main semula buah ditangkap) & Kenaikan Pangkat.',
    },
    'play_now': {
      'id': 'MAIN SEKARANG',
      'en': 'PLAY NOW',
      'ja': '今すぐ対局',
      'ms': 'MAIN SEKARANG',
    },

    // Setup Dialog
    'setup_chess': {
      'id': 'Atur Permainan Catur',
      'en': 'Chess Game Setup',
      'ja': 'チェス対局設定',
      'ms': 'Tetapan Permainan Catur',
    },
    'setup_shogi': {
      'id': 'Atur Permainan Shogi',
      'en': 'Shogi Game Setup',
      'ja': '将棋対局設定',
      'ms': 'Tetapan Permainan Syogi',
    },
    'game_mode': {
      'id': 'PILIH MODE BERMAIN',
      'en': 'CHOOSE GAME MODE',
      'ja': '対局モード選択',
      'ms': 'PILIH MOD PERMAINAN',
    },
    'vs_bot': {
      'id': 'Lawan Bot AI',
      'en': 'Vs Bot AI',
      'ja': 'AIボットと対局',
      'ms': 'Lawan Bot AI',
    },
    'vs_bot_sub': {
      'id': 'Latihan 6 Tingkat',
      'en': '6 Difficulty Tiers',
      'ja': '6段階の難易度',
      'ms': 'Latihan 6 Tahap',
    },
    'vs_player': {
      'id': 'Lawan Pemain',
      'en': 'Vs Player',
      'ja': '2人対局 (ローカル)',
      'ms': 'Lawan Pemain',
    },
    'vs_player_sub': {
      'id': 'Pass & Play Local / PvP',
      'en': 'Pass & Play Local PvP',
      'ja': 'パス＆プレイ (対人戦)',
      'ms': 'Pass & Play Tempatan PvP',
    },
    'choose_side_chess': {
      'id': 'PILIH SISI / WARNA BIDAK',
      'en': 'CHOOSE PIECE COLOR',
      'ja': '駒の色（手番）を選択',
      'ms': 'PILIH WARNA BUAH',
    },
    'choose_side_shogi': {
      'id': 'PILIH GILIRAN / SISI SHOGI',
      'en': 'CHOOSE SHOGI SIDE',
      'ja': '先手・後手を選択',
      'ms': 'PILIH GILIRAN SYOGI',
    },
    'white_first': {
      'id': 'Putih / Emas (Jalan Pertama)',
      'en': 'White / Gold (First Move)',
      'ja': '白 / 先手 (先攻)',
      'ms': 'Putih / Emas (Gerak Pertama)',
    },
    'black_second': {
      'id': 'Hitam / Gelap (Jalan Kedua)',
      'en': 'Black / Dark (Second Move)',
      'ja': '黒 / 後手 (後攻)',
      'ms': 'Hitam / Gelap (Gerak Kedua)',
    },
    'duration_label': {
      'id': 'DURASI WAKTU PERMAINAN (PER PEMAIN)',
      'en': 'MATCH DURATION (PER PLAYER)',
      'ja': '持ち時間設定（各プレイヤー）',
      'ms': 'TEMPOH MASA PERMAINAN (SETIAP PEMAIN)',
    },
    'bot_difficulty_label': {
      'id': 'TINGKAT KEPINTARAN BOT (RATING)',
      'en': 'BOT DIFFICULTY LEVEL',
      'ja': 'AI難易度 (レーティング)',
      'ms': 'TAHAP KEBIJAKSANAAN BOT (RATING)',
    },
    'start_match': {
      'id': 'MULAI PERTANDINGAN',
      'en': 'START MATCH',
      'ja': '対局を開始する',
      'ms': 'MULA PERLAWANAN',
    },
    'random_chess_side': {
      'id': 'Warna Putih dan Hitam akan diacak saat pertandingan dimulai.',
      'en': 'White and Black will be assigned randomly when the match starts.',
      'ja': '対局開始時に白番・黒番がランダムに決まります。',
      'ms': 'Warna Putih dan Hitam akan dipilih secara rawak apabila perlawanan bermula.',
    },
    'random_shogi_side': {
      'id': 'Sente dan Gote akan diacak saat pertandingan dimulai.',
      'en': 'Sente and Gote will be assigned randomly when the match starts.',
      'ja': '対局開始時に先手・後手がランダムに決まります。',
      'ms': 'Sente dan Gote akan dipilih secara rawak apabila perlawanan bermula.',
    },
    'login_title': {
      'id': 'Masuk ke Akun',
      'en': 'Sign In',
      'ja': 'ログイン',
      'ms': 'Log Masuk',
    },
    'register_title': {
      'id': 'Buat Akun Baru',
      'en': 'Create Account',
      'ja': 'アカウントを作成',
      'ms': 'Cipta Akaun',
    },
    'login': {'id': 'Masuk', 'en': 'Sign In', 'ja': 'ログイン', 'ms': 'Log Masuk'},
    'register': {'id': 'Daftar', 'en': 'Register', 'ja': '登録', 'ms': 'Daftar'},
    'login_now': {
      'id': 'Masuk Sekarang',
      'en': 'Sign In Now',
      'ja': 'ログインする',
      'ms': 'Log Masuk Sekarang',
    },
    'register_now': {
      'id': 'Daftar Sekarang',
      'en': 'Register Now',
      'ja': '今すぐ登録',
      'ms': 'Daftar Sekarang',
    },
    'google_login': {
      'id': 'Masuk dengan Akun Google',
      'en': 'Continue with Google',
      'ja': 'Googleでログイン',
      'ms': 'Teruskan dengan Google',
    },
    'google_register': {
      'id': 'Daftar dengan Akun Google',
      'en': 'Register with Google',
      'ja': 'Googleで登録',
      'ms': 'Daftar dengan Google',
    },
    'or_email': {
      'id': 'atau dengan Email',
      'en': 'or with Email',
      'ja': 'またはメールアドレスで',
      'ms': 'atau dengan E-mel',
    },
    'full_name': {
      'id': 'NAMA LENGKAP / DISPLAY NAME',
      'en': 'FULL NAME / DISPLAY NAME',
      'ja': '名前 / 表示名',
      'ms': 'NAMA PENUH / NAMA PAPARAN',
    },
    'email_address': {
      'id': 'ALAMAT EMAIL',
      'en': 'EMAIL ADDRESS',
      'ja': 'メールアドレス',
      'ms': 'ALAMAT E-MEL',
    },
    'password': {
      'id': 'KATA SANDI (PASSWORD)',
      'en': 'PASSWORD',
      'ja': 'パスワード',
      'ms': 'KATA LALUAN',
    },
    'name_hint': {
      'id': 'Contoh: Grandmaster Pro',
      'en': 'Example: Grandmaster Pro',
      'ja': '例：Grandmaster Pro',
      'ms': 'Contoh: Grandmaster Pro',
    },
    'password_hint': {
      'id': 'Minimal 6 karakter',
      'en': 'At least 6 characters',
      'ja': '6文字以上',
      'ms': 'Sekurang-kurangnya 6 aksara',
    },
    'invalid_email': {
      'id': 'Masukkan alamat email yang valid.',
      'en': 'Enter a valid email address.',
      'ja': '有効なメールアドレスを入力してください。',
      'ms': 'Masukkan alamat e-mel yang sah.',
    },
    'invalid_password': {
      'id': 'Password minimal harus 6 karakter.',
      'en': 'Password must be at least 6 characters.',
      'ja': 'パスワードは6文字以上にしてください。',
      'ms': 'Kata laluan mesti sekurang-kurangnya 6 aksara.',
    },
    'name_required': {
      'id': 'Nama pemain tidak boleh kosong.',
      'en': 'Player name cannot be empty.',
      'ja': 'プレイヤー名を入力してください。',
      'ms': 'Nama pemain tidak boleh kosong.',
    },
    'google_auth_failed': {
      'id': 'Gagal melakukan otentikasi Google.',
      'en': 'Google authentication failed.',
      'ja': 'Google認証に失敗しました。',
      'ms': 'Pengesahan Google gagal.',
    },
    'google_login_success': {
      'id': 'Berhasil masuk dengan Google!',
      'en': 'Signed in with Google!',
      'ja': 'Googleでログインしました！',
      'ms': 'Berjaya log masuk dengan Google!',
    },
    'google_register_success': {
      'id': 'Pendaftaran dengan Google berhasil!',
      'en': 'Google registration successful!',
      'ja': 'Googleでの登録が完了しました！',
      'ms': 'Pendaftaran Google berjaya!',
    },
    'login_success': {
      'id': 'Berhasil masuk sebagai {name}!',
      'en': 'Signed in as {name}!',
      'ja': '{name}としてログインしました！',
      'ms': 'Berjaya log masuk sebagai {name}!',
    },
    'register_success': {
      'id': 'Registrasi berhasil! Selamat datang, {name}',
      'en': 'Registration successful! Welcome, {name}',
      'ja': '登録完了！ようこそ、{name}さん',
      'ms': 'Pendaftaran berjaya! Selamat datang, {name}',
    },
    'save_progress': {
      'id': 'Simpan Rating & Progres',
      'en': 'Save Rating & Progress',
      'ja': 'レーティングと進行状況を保存',
      'ms': 'Simpan Rating & Kemajuan',
    },
    'sync_progress': {
      'id': 'Login atau daftar untuk sinkron ELO Anda',
      'en': 'Sign in or register to sync your ELO',
      'ja': 'ログインまたは登録してELOを同期',
      'ms': 'Log masuk atau daftar untuk menyegerakkan ELO anda',
    },
    'login_register': {
      'id': 'Login / Daftar',
      'en': 'Sign In / Register',
      'ja': 'ログイン / 登録',
      'ms': 'Log Masuk / Daftar',
    },
    'chess_tab': {
      'id': 'Catur (Chess)',
      'en': 'Chess',
      'ja': 'チェス',
      'ms': 'Catur',
    },
    'shogi_tab': {
      'id': 'Shogi (将棋)',
      'en': 'Shogi',
      'ja': '将棋',
      'ms': 'Syogi (将棋)',
    },
    'rank': {'id': 'RANK', 'en': 'RANK', 'ja': '順位', 'ms': 'KEDUDUKAN'},
    'players': {
      'id': 'MASTER / PEMAIN',
      'en': 'MASTER / PLAYER',
      'ja': 'マスター / プレイヤー',
      'ms': 'MASTER / PEMAIN',
    },
    'rating_elo': {
      'id': 'RATING ELO',
      'en': 'ELO RATING',
      'ja': 'ELOレーティング',
      'ms': 'RATING ELO',
    },
    'record': {
      'id': '{wins} Menang · {losses} Kalah',
      'en': '{wins} Wins · {losses} Losses',
      'ja': '{wins}勝 · {losses}敗',
      'ms': '{wins} Menang · {losses} Kalah',
    },
    'position': {
      'id': 'POSISI #{rank}',
      'en': 'RANK #{rank}',
      'ja': '順位 #{rank}',
      'ms': 'KEDUDUKAN #{rank}',
    },
    'title_record': {
      'id': 'Gelar: {title} ({wins}W / {losses}L)',
      'en': 'Title: {title} ({wins}W / {losses}L)',
      'ja': '称号: {title}（{wins}勝 / {losses}敗）',
      'ms': 'Gelaran: {title} ({wins}M / {losses}K)',
    },
    'win': {'id': 'MENANG', 'en': 'WIN', 'ja': '勝利', 'ms': 'MENANG'},
    'loss': {'id': 'KALAH', 'en': 'LOSS', 'ja': '敗北', 'ms': 'KALAH'},
    'draw': {'id': 'SERI', 'en': 'DRAW', 'ja': '引き分け', 'ms': 'SERI'},
    'versus': {
      'id': 'vs {name}',
      'en': 'vs {name}',
      'ja': '対 {name}',
      'ms': 'lwn {name}',
    },
    'victory': {
      'id': 'KEMENANGAN!',
      'en': 'VICTORY!',
      'ja': '勝利！',
      'ms': 'KEMENANGAN!',
    },
    'defeat': {
      'id': 'KEKALAHAN',
      'en': 'DEFEAT',
      'ja': '敗北',
      'ms': 'KEKALAHAN',
    },
    'rating_change': {
      'id': 'Perubahan Rating ELO:',
      'en': 'ELO Rating Change:',
      'ja': 'ELOレーティング変動:',
      'ms': 'Perubahan Rating ELO:',
    },
    'bot_practice': {
      'id': 'Mode Bot (Latihan):',
      'en': 'Bot Mode (Practice):',
      'ja': 'ボットモード（練習）:',
      'ms': 'Mod Bot (Latihan):',
    },
    'cancel': {'id': 'Batal', 'en': 'Cancel', 'ja': 'キャンセル', 'ms': 'Batal'},
    'restart_match': {
      'id': 'Mulai Ulang Match?',
      'en': 'Restart Match?',
      'ja': '対局をやり直しますか？',
      'ms': 'Mulakan Semula Perlawanan?',
    },
    'restart_message': {
      'id': 'Apakah Anda yakin ingin memulai ulang posisi permainan ini?',
      'en': 'Are you sure you want to restart this game?',
      'ja': 'この対局を最初からやり直しますか？',
      'ms': 'Adakah anda pasti mahu memulakan semula permainan ini?',
    },
    'resign': {'id': 'Menyerah', 'en': 'Resign', 'ja': '投了', 'ms': 'Menyerah'},
    'resign_title': {
      'id': 'Menyerah dari Pertandingan?',
      'en': 'Resign from Match?',
      'ja': '対局を投了しますか？',
      'ms': 'Menyerah dari Perlawanan?',
    },
    'resign_message': {
      'id': 'Anda akan dinyatakan kalah dan pertandingan akan diakhiri.',
      'en': 'You will lose the match and it will end immediately.',
      'ja': '敗北となり、対局は直ちに終了します。',
      'ms': 'Anda akan kalah dan perlawanan akan tamat serta-merta.',
    },
    'confirm_resign': {
      'id': 'Ya, Menyerah',
      'en': 'Yes, Resign',
      'ja': '投了する',
      'ms': 'Ya, Menyerah',
    },
    'resigned_title': {
      'id': 'Anda Menyerah',
      'en': 'You Resigned',
      'ja': '投了しました',
      'ms': 'Anda Menyerah',
    },
    'resigned_message': {
      'id': 'Anda menyerah dari pertandingan.',
      'en': 'You resigned from the match.',
      'ja': '対局を投了しました。',
      'ms': 'Anda menyerah dari perlawanan.',
    },

    // Ratings & Leaderboard
    'chess_rating': {
      'id': 'Rating Catur',
      'en': 'Chess Rating',
      'ja': 'チェスレーティング',
      'ms': 'Rating Catur',
    },
    'shogi_rating': {
      'id': 'Rating Shogi',
      'en': 'Shogi Rating',
      'ja': '将棋レーティング',
      'ms': 'Rating Syogi',
    },
    'view_leaderboard': {
      'id': 'Lihat Peringkat & Leaderboard Global',
      'en': 'View Global Leaderboard & Ranks',
      'ja': 'グローバルランキングを見る',
      'ms': 'Lihat Papan Kedudukan Global',
    },
    'my_rank': {'id': 'POSISI', 'en': 'RANK', 'ja': '順位', 'ms': 'KEDUDUKAN'},
    'restart': {
      'id': 'Mulai Ulang',
      'en': 'Restart',
      'ja': '再対局',
      'ms': 'Mula Semula',
    },
    'main_menu': {
      'id': 'Menu Utama',
      'en': 'Main Menu',
      'ja': 'メインメニュー',
      'ms': 'Menu Utama',
    },
    'play_again': {
      'id': 'Main Lagi',
      'en': 'Play Again',
      'ja': 'もう一度対局',
      'ms': 'Main Lagi',
    },
    'nav_play': {
      'id': 'Main',
      'en': 'Play',
      'ja': '対局',
      'ms': 'Main',
    },
    'nav_guide': {
      'id': 'Panduan',
      'en': 'Guide',
      'ja': 'ガイド',
      'ms': 'Panduan',
    },
    'nav_leaderboard': {
      'id': 'Peringkat',
      'en': 'Rankings',
      'ja': '順位表',
      'ms': 'Kedudukan',
    },
    'nav_profile': {
      'id': 'Profil',
      'en': 'Profile',
      'ja': 'プロフィール',
      'ms': 'Profil',
    },
    'view_match_history': {
      'id': 'Lihat Riwayat Pertandingan',
      'en': 'View Match History',
      'ja': '対局履歴を見る',
      'ms': 'Lihat Sejarah Perlawanan',
    },
    'match_history_title': {
      'id': 'Riwayat Pertandingan',
      'en': 'Match History',
      'ja': '対局履歴',
      'ms': 'Sejarah Perlawanan',
    },
    'filter_all': {
      'id': 'Semua',
      'en': 'All',
      'ja': 'すべて',
      'ms': 'Semua',
    },
    'no_match_history': {
      'id': 'Belum Ada Pertandingan',
      'en': 'No Match History Yet',
      'ja': 'まだ対局履歴がありません',
      'ms': 'Belum Ada Sejarah Perlawanan',
    },
    'no_match_history_desc': {
      'id': 'Mainkan catur atau shogi untuk melihat catatan statistik di sini.',
      'en': 'Play chess or shogi to view your match records here.',
      'ja': 'チェスや将棋をプレイして、ここに記録を表示しましょう。',
      'ms': 'Mainkan catur atau syogi untuk melihat rekod perlawanan di sini.',
    },
    'review_game_analysis': {
      'id': 'Lihat Analisis Permainan',
      'en': 'Review Game Analysis',
      'ja': '対局分析を見る',
      'ms': 'Lihat Analisis Perlawanan',
    },
    'game_analysis_title': {
      'id': 'Laporan Analisis Permainan',
      'en': 'Game Analysis Report',
      'ja': '対局分析レポート',
      'ms': 'Laporan Analisis Perlawanan',
    },
    'accuracy': {
      'id': 'Akurasi',
      'en': 'Accuracy',
      'ja': '正確度',
      'ms': 'Ketepatan',
    },
    'move_timeline': {
      'id': 'Rincian & Evaluasi Langkah',
      'en': 'Move Timeline & Evaluation',
      'ja': '手の履歴と評価',
      'ms': 'Garis Masa & Penilaian Langkah',
    },
    'no_moves_analyzed': {
      'id': 'Belum ada langkah yang tercatat.',
      'en': 'No moves recorded yet.',
      'ja': '記録された手はありません。',
      'ms': 'Belum ada langkah yang direkodkan.',
    },
    'vs_coach': {
      'id': 'Lawan Pelatih',
      'en': 'vs Coach',
      'ja': 'コーチ対戦',
      'ms': 'Lawan Jurulatih',
    },
    'vs_coach_sub': {
      'id': 'Umpan balik real-time',
      'en': 'Real-time feedback',
      'ja': 'リアルタイム指導',
      'ms': 'Maklum balas masa nyata',
    },
    'coach_level_title': {
      'id': 'Tingkatan Pelatih',
      'en': 'Coach Level',
      'ja': 'コーチレベル',
      'ms': 'Tahap Jurulatih',
    },
    'coach_beginner': {
      'id': 'Pelatih Pemula',
      'en': 'Beginner Coach',
      'ja': '初級コーチ',
      'ms': 'Jurulatih Pemula',
    },
    'coach_beginner_desc': {
      'id': 'Fokus belajar dasar & langkah aman.',
      'en': 'Learn fundamentals & safe moves.',
      'ja': '基本と安全な手を学びます。',
      'ms': 'Fokus asas & langkah selamat.',
    },
    'coach_easy': {
      'id': 'Pelatih Mudah',
      'en': 'Easy Coach',
      'ja': '初中級コーチ',
      'ms': 'Jurulatih Mudah',
    },
    'coach_easy_desc': {
      'id': 'Pola pembukaan & pemanfaatan ruang.',
      'en': 'Openings & board space control.',
      'ja': '序盤の定跡と空間支配。',
      'ms': 'Pola pembukaan & kawalan ruang.',
    },
    'coach_medium': {
      'id': 'Pelatih Sedang',
      'en': 'Medium Coach',
      'ja': '中級コーチ',
      'ms': 'Jurulatih Sederhana',
    },
    'coach_medium_desc': {
      'id': 'Taktik serang balik & penempatan bidak.',
      'en': 'Counter-tactics & piece placement.',
      'ja': '反撃の戦術と駒の活用。',
      'ms': 'Taktik serangan balas & kedudukan.',
    },
    'coach_hard': {
      'id': 'Pelatih Sulit',
      'en': 'Hard Coach',
      'ja': '上級コーチ',
      'ms': 'Jurulatih Sukar',
    },
    'coach_hard_desc': {
      'id': 'Kombinasi mendalam, antisipasi ancaman & perhitungan taktis 4-langkah.',
      'en': 'Deep tactical combinations & 4-ply threat anticipation.',
      'ja': '高度な読みと4手先を見据えた鋭い戦術指導。',
      'ms': 'Kombinasi mendalam & antisipasi ancaman 4-langkah.',
    },
    'coach_master': {
      'id': 'Pelatih Master',
      'en': 'Master Coach',
      'ja': '師範 (Master)',
      'ms': 'Jurulatih Master',
    },
    'coach_master_desc': {
      'id': 'Standar grandmaster tanpa celah blunder dengan analisa mendalam 5-langkah.',
      'en': 'Flawless grandmaster precision with 5-ply deep search engine analysis.',
      'ja': '隙のない最高峰の完全無欠な大局観・5手深層分析指導。',
      'ms': 'Piawaian grandmaster tanpa celah dengan analisa 5-langkah.',
    },
    'coach_feedback_bubble': {
      'id': 'Evaluasi Pelatih',
      'en': 'Coach Evaluation',
      'ja': 'コーチの講評',
      'ms': 'Penilaian Jurulatih',
    },
    'undo_move': {
      'id': 'Ulang Langkah',
      'en': 'Undo Move',
      'ja': '待った (一手戻す)',
      'ms': 'Ulang Langkah',
    },
    'undo_move_tooltip': {
      'id': 'Ulangi gerakan sebelumnya',
      'en': 'Take back previous move',
      'ja': '前の手をやり直す',
      'ms': 'Ulangi gerakan sebelumnya',
    },

    // Chess Specific Coach Analysis Dialogues
    'coach_chess_checkmate': {
      'id': 'Skakmat brilian! Rencana penyerangan Anda tuntas sempurna!',
      'en': 'Brilliant checkmate! Your attack plan concluded perfectly!',
      'ja': '見事なチェックメイト！完璧な寄せの手順でした！',
      'ms': 'Skakmat yang cemerlang! Rancangan serangan anda selesai dengan sempurna!',
    },
    'coach_chess_castling_1': {
      'id': 'Rokade tepat waktu! Raja aman di sudut dan benteng siap beraksi di lajur terbuka.',
      'en': 'Timely castling! King safely tucked away and rook ready on the open file.',
      'ja': '好タイミングのキャスリング！王を囲い、ルークを活用します。',
      'ms': 'Rokade tepat pada masanya! Raja selamat di sudut dan benteng sedia beraksi.',
    },
    'coach_chess_castling_2': {
      'id': 'Keputusan rokade yang sangat baik untuk mengamankan pertahanan raja.',
      'en': 'Excellent castling decision to solidify your king safety.',
      'ja': 'キングの安全を確保する素晴らしい判断です。',
      'ms': 'Keputusan rokade yang sangat baik untuk mengukuhkan keselamatan raja.',
    },
    'coach_chess_castling_3': {
      'id': 'Mengamankan raja sekarang memberi Anda kebebasan melancarkan serangan pusat.',
      'en': 'Shielding your king now allows you to launch a central breakthrough.',
      'ja': '玉を安全にしたことで、中央突破への準備が整いました。',
      'ms': 'Menyelamatkan raja sekarang memberi kebebasan melancarkan serangan pusat.',
    },
    'coach_chess_promo_1': {
      'id': 'Promosi pion luar biasa! Kehadiran perwira baru ini membalikkan dominasi permainan.',
      'en': 'Superb promotion! Your new queen/piece completely dominates the board.',
      'ja': '強力なプロモーション！新たな戦力で盤面を制圧しましょう。',
      'ms': 'Promosi pion yang luar biasa! Kehadiran perwira baru menguasai permainan.',
    },
    'coach_chess_promo_2': {
      'id': 'Pion promosi Anda menjadi ancaman mematikan bagi struktur pertahanan lawan.',
      'en': 'Your promoted piece is now a lethal threat to the opposing structure.',
      'ja': '昇格した駒が相手陣に強烈なプレッシャーを与えています。',
      'ms': 'Pion promosi anda kini menjadi ancaman maut kepada pertahanan lawan.',
    },
    'coach_chess_check_sharp': {
      'id': 'Skak tajam beruntun! Memaksa raja lawan kehilangan hak gerak dan koordinasi.',
      'en': 'Sharp check! Forcing opponent king out of harmony and coordination.',
      'ja': '鋭いチェック！相手玉の陣形を崩す強力な王手です。',
      'ms': 'Skak yang tajam! Memaksa raja lawan hilang koordinasi.',
    },
    'coach_chess_check_good': {
      'id': 'Skak taktis yang baik, menjaga tempo serangan tetap berada di tangan Anda.',
      'en': 'Good tactical check, keeping the attacking initiative in your hands.',
      'ja': '手番を維持する堅実な王手です。',
      'ms': 'Skak taktikal yang baik, mengekalkan inisiatif serangan di tangan anda.',
    },
    'coach_chess_check_premature': {
      'id': 'Skak ini agak prematur, lawan bisa menutupnya sambil mengembangkan perwira mereka.',
      'en': 'Premature check; the opponent can easily block while developing pieces.',
      'ja': 'やや早い王手です。相手に合駒され、展開を手伝ってしまう恐れがあります。',
      'ms': 'Skak agak pramatang; lawan mudah menghalang sambil memajukan perwira.',
    },
    'coach_chess_capture_brilliant_1': {
      'id': 'Pukulan taktis brilian! Anda memenangkan pertukaran perwira dengan kalkulasi matang.',
      'en': 'Brilliant tactical capture! You won a decisive material exchange.',
      'ja': '鋭い駒得の妙手！計算し尽くされた見事な取りです。',
      'ms': 'Tangkapan taktikal cemerlang! Anda memenangi pertukaran material.',
    },
    'coach_chess_capture_brilliant_2': {
      'id': 'Kombinasi tangkapan yang sangat jeli! Membongkar benteng pertahanan musuh.',
      'en': 'Keen capture combination! Tearing apart the enemy defense.',
      'ja': '敵の守りを崩す鋭利な捕獲です！',
      'ms': 'Kombinasi tangkapan yang bijak! Memecahkan pertahanan lawan.',
    },
    'coach_chess_capture_best_1': {
      'id': 'Tangkapan perwira yang tepat dan bersih, menambah keunggulan poin materiil.',
      'en': 'Clean and precise capture, increasing your material advantage.',
      'ja': '確実な駒得。戦力差を着実に広げています。',
      'ms': 'Tangkapan yang tepat dan bersih, menambah kelebihan poin.',
    },
    'coach_chess_capture_best_2': {
      'id': 'Menghilangkan perwira kunci lawan yang paling berbahaya.',
      'en': 'Eliminating opponent\'s most active defensive piece.',
      'ja': '相手の最も厄介な守備駒を排除しました。',
      'ms': 'Menghapuskan perwira lawan yang paling berbahaya.',
    },
    'coach_chess_trade_fair': {
      'id': 'Pertukaran bidak yang seimbang, menyederhanakan posisi papan.',
      'en': 'Fair trade of pieces, simplifying the position.',
      'ja': '互角の駒交換。局面を整理しています。',
      'ms': 'Pertukaran bidak yang seimbang, meringkaskan kedudukan papan.',
    },
    'coach_chess_capture_bad_trade': {
      'id': 'Pertukaran yang merugikan! Anda kehilangan perwira yang bernilai lebih tinggi.',
      'en': 'Unfavorable trade! You lost higher value material.',
      'ja': '不利な駒交換です。価値の高い駒を損してしまいました。',
      'ms': 'Pertukaran yang merugikan! Anda kehilangan perwira bernilai tinggi.',
    },
    'coach_chess_open_best_1': {
      'id': 'Pembukaan solid! Menguasai petak pusat (d4/e4/d5/e5) sejak awal.',
      'en': 'Solid opening! Gaining firm central control right from the start.',
      'ja': '堅実な序盤！中央（センター）をしっかりと制圧しています。',
      'ms': 'Pembukaan kukuh! Menguasai petak tengah sejak awal.',
    },
    'coach_chess_open_best_2': {
      'id': 'Langkah pembukaan ideal. Mengembangkan perwira ringan (kuda/gajah) secara harmonis.',
      'en': 'Ideal opening move. Developing minor pieces smoothly and harmoniously.',
      'ja': '理想的な駒展開。ナイトとビショップが連携しやすい形です。',
      'ms': 'Langkah pembukaan ideal. Memajukan perwira secara harmoni.',
    },
    'coach_chess_open_best_3': {
      'id': 'Langkah teoritis yang sangat kuat, membuka jalur gerak menteri dan gajah.',
      'en': 'Strong book move, clearing diagonals for your queen and bishop.',
      'ja': '定跡通りの力強い一手。角やクイーンの道が開きました。',
      'ms': 'Langkah pembukaan yang kuat, membuka laluan untuk ratu dan gajah.',
    },
    'coach_chess_open_good': {
      'id': 'Pembukaan wajar. Fokuslah segera mengeluarkan sisa perwira Anda.',
      'en': 'Decent development. Remember to activate all your remaining minor pieces.',
      'ja': '無難な駒組み。残りの駒も素早く出していきましょう。',
      'ms': 'Pembukaan wajar. Majukan sisa perwira anda dengan segera.',
    },
    'coach_chess_open_inaccurate': {
      'id': 'Langkah pembukaan agak pasif atau menggerakkan bidak yang sama berulang kali.',
      'en': 'Slightly passive opening move or moving the same piece multiple times.',
      'ja': '序盤の緩手です。同じ駒を何度も動かすのは避けましょう。',
      'ms': 'Langkah pembukaan agak pasif atau menggerakkan bidak yang sama berulang kali.',
    },
    'coach_chess_best_1': {
      'id': 'Langkah terbaik dari engine! Memperkuat posisi dan memberi tekanan ganda.',
      'en': 'Top engine move! Strengthening your grid while applying dual pressure.',
      'ja': '最善手！陣形を引き締めつつ、相手陣に二重の圧力をかけています。',
      'ms': 'Langkah terbaik! Memperkukuh kedudukan dan memberi tekanan berganda.',
    },
    'coach_chess_best_2': {
      'id': 'Posisi yang sangat presisi. Perwira Anda saling melindungi dengan kokoh.',
      'en': 'Highly accurate positional play. Your pieces protect each other perfectly.',
      'ja': '非常に正確なポジショニング。駒同士の連携が抜群です。',
      'ms': 'Kedudukan yang sangat tepat. Perwira anda saling melindungi dengan kukuh.',
    },
    'coach_chess_best_3': {
      'id': 'Manuver cerdas! Membatasi mobilitas perwira musuh secara signifikan.',
      'en': 'Clever maneuver! Significantly restricting enemy mobility.',
      'ja': '巧みな駒の活用！相手の動きを効果的に封じています。',
      'ms': 'Gerakan bijak! Menyekat pergerakan perwira musuh secara ketara.',
    },
    'coach_chess_best_4': {
      'id': 'Langkah yang sangat tajam, menempatkan perwira di petak pos terdepan (outpost).',
      'en': 'Very sharp move, planting a piece firmly on a strong outpost.',
      'ja': '好位置（アウトポスト）に駒を据える素晴らしい一手です。',
      'ms': 'Langkah yang sangat tajam, menempatkan perwira di pos terdepan yang kuat.',
    },
    'coach_chess_good_1': {
      'id': 'Langkah bagus. Struktur pertahanan Anda tetap terjaga aman.',
      'en': 'Good move. Your defensive structure remains sound and reliable.',
      'ja': '良い手です。陣形のバランスが崩れていません。',
      'ms': 'Langkah bagus. Struktur pertahanan anda kekal selamat.',
    },
    'coach_chess_good_2': {
      'id': 'Keputusan yang masuk akal, melanjutkan rencana permainan dengan tenang.',
      'en': 'Sensible decision, steadily progressing your tactical plan.',
      'ja': '手堅い指し手。着実にプランを進めています。',
      'ms': 'Keputusan yang munasabah, meneruskan rancangan taktikal dengan tenang.',
    },
    'coach_chess_good_3': {
      'id': 'Langkah aktif yang menjaga inisiatif tetap berjalan.',
      'en': 'Active move maintaining momentum and fighting spirit.',
      'ja': '主導権を渡さない積極的な手です。',
      'ms': 'Langkah aktif yang mengekalkan inisiatif permainan.',
    },
    'coach_chess_inacc_1': {
      'id': 'Kurang akurat. Langkah ini melepaskan kontrol di petak kunci.',
      'en': 'Inaccurate. This releases control over a key central square.',
      'ja': 'やや疑問手。重要なマスの制圧力を弱めてしまいました。',
      'ms': 'Kurang tepat. Langkah ini melepaskan kawalan di petak utama.',
    },
    'coach_chess_inacc_2': {
      'id': 'Ada alternatif yang lebih dinamis. Perwira Anda sedikit terisolasi di sini.',
      'en': 'There were more dynamic alternatives; this piece is a bit isolated.',
      'ja': 'より良い手がありました。この駒が少し浮いてしまっています。',
      'ms': 'Ada pilihan yang lebih dinamik. Perwira anda sedikit terasing di sini.',
    },
    'coach_chess_inacc_3': {
      'id': 'Langkah ini memperlambat ritme serangan Anda.',
      'en': 'This move slows down your attacking rhythm unnecessarily.',
      'ja': '攻めのテンポを少し遅らせてしまいました。',
      'ms': 'Langkah ini memperlahankan ritma serangan anda.',
    },
    'coach_chess_mistake_1': {
      'id': 'Kesalahan taktis: Lawan kini bisa mengeksploitasi pin atau garpu (fork).',
      'en': 'Mistake: Opponent can now exploit a pin or tactical fork.',
      'ja': '悪手です。ピンや両取り（フォーク）の隙が生じています。',
      'ms': 'Kesilapan taktikal: Lawan kini boleh mengeksploitasi pin atau garpu (fork).',
    },
    'coach_chess_mistake_2': {
      'id': 'Langkah ini melemahkan perlindungan di sekitar sayap raja Anda.',
      'en': 'This move weakens the pawn shield around your king\'s flank.',
      'ja': '王の周りの守備（ポーン構造）が弱体化してしまいました。',
      'ms': 'Langkah ini melemahkan perlindungan di sekitar raja anda.',
    },
    'coach_chess_mistake_3': {
      'id': 'Kehilangan tempo berharga. Lawan berkesempatan melancarkan serangan balik.',
      'en': 'Lost precious tempo. Opponent has a chance to counter-attack.',
      'ja': '手番を損ねました。相手に反撃のチャンスを与えてしまいます。',
      'ms': 'Kehilangan tempo berharga. Lawan berpeluang melancarkan serangan balas.',
    },
    'coach_chess_blunder_1': {
      'id': 'Blunder fatal! Bidak atau perwira Anda dibiarkan menggantung tanpa penjagaan.',
      'en': 'Major blunder! Your piece is left hanging unprotected.',
      'ja': '大悪手（ポロリ）！駒が無防備な状態になっています。',
      'ms': 'Blunder besar! Bidak atau perwira anda tergantung tanpa perlindungan.',
    },
    'coach_chess_blunder_2': {
      'id': 'Bahaya besar! Langkah ini memberi lawan peluang skakmat atau kemenangan materiil masif.',
      'en': 'Severe blunder! This gives opponent a winning mating net or huge material.',
      'ja': '痛恨の大悪手！相手に詰み筋や決定的な駒得を与えてしまいます。',
      'ms': 'Bahaya besar! Langkah ini memberi lawan peluang skakmat atau kelebihan besar.',
    },
    'coach_chess_blunder_3': {
      'id': 'Waspada! Garis pertahanan raja terbuka total akibat langkah ceroboh ini.',
      'en': 'Critical danger! King defense is fully blown open by this move.',
      'ja': '危険！王の逃げ道が塞がれ、致命的な攻撃を受ける恐れがあります。',
      'ms': 'Waspada! Garisan pertahanan raja terbuka akibat langkah ini.',
    },

    // Shogi Specific Coach Analysis Dialogues
    'coach_shogi_tsumi': {
      'id': 'Tsumi (詰み) sempurna! Serangan akhir yang tidak dapat dihindari lawan!',
      'en': 'Perfect Tsumi (Checkmate)! Undefendable mating net concluded!',
      'ja': '見事な「詰み」！完璧な寄せで勝負を決めました！',
      'ms': 'Tsumi (詰み) yang sempurna! Serangan akhir yang tidak dapat dielakkan lawan!',
    },
    'coach_shogi_drop_check': {
      'id': 'Drop Ōte (王手) mematikan! Menekan langsung raja lawan ke dinding.',
      'en': 'Deadly check drop! Pressuring enemy king right against the edge.',
      'ja': '鋭い「王手打ち」！相手玉を逃げ場のない端へ追い込みます。',
      'ms': 'Drop Ōte (王手) maut! Menekan terus raja lawan ke sudut.',
    },
    'coach_shogi_drop_vital': {
      'id': 'Drop bidak di titik vital (Koushu)! Mengunci pergerakan perwira musuh.',
      'en': 'Vital drop point (Koushu)! Locking down opponent\'s key piece mobility.',
      'ja': '急所を突く「好手の駒打ち」！相手の要の駒を無力化しました。',
      'ms': 'Drop bidak di titik penting (Koushu)! Mengunci pergerakan perwira musuh.',
    },
    'coach_shogi_drop_best_1': {
      'id': 'Penggunaan bidak simpanan (Mochigoma) yang sangat cerdik.',
      'en': 'Very smart utilization of your in-hand Mochigoma piece.',
      'ja': '持ち駒を効果的に使う素晴らしい打ち込みです。',
      'ms': 'Penggunaan bidak simpanan (Mochigoma) yang sangat bijak.',
    },
    'coach_shogi_drop_best_2': {
      'id': 'Drop pertahanan yang kokoh, menutup jalur serangan lawan dengan rapat.',
      'en': 'Solid defensive drop, tightly plugging the opponent attack line.',
      'ja': '受けの好手。相手の攻め筋を的確に遮断しました。',
      'ms': 'Drop pertahanan yang kukuh, menutup laluan serangan lawan.',
    },
    'coach_shogi_drop_good': {
      'id': 'Drop yang bagus untuk menambah tekanan pada petak strategis.',
      'en': 'Good drop to reinforce tactical pressure on a strategic square.',
      'ja': '拠点を築く手堅い駒打ちです。',
      'ms': 'Drop yang bagus untuk menambah tekanan di petak strategik.',
    },
    'coach_shogi_drop_waste': {
      'id': 'Bidak simpanan terbuang sia-sia pada posisi yang kurang efektif.',
      'en': 'Wasting in-hand piece on an ineffective square.',
      'ja': '持ち駒の無駄遣いになりかねない位置です。慎重に使いましょう。',
      'ms': 'Bidak simpanan dibazirkan pada kedudukan yang kurang berkesan.',
    },
    'coach_shogi_promote_brilliant': {
      'id': 'Promosi 成 (Naru) brilian! Membentuk Ryu/Uma yang menguasai seluruh papan!',
      'en': 'Brilliant promotion (Naru)! Ryu/Uma dominance across the entire board!',
      'ja': '絶妙な「成」！竜・馬の力で敵陣を一気に制圧します！',
      'ms': 'Promosi 成 (Naru) cemerlang! Membentuk Ryu/Uma yang menguasai papan!',
    },
    'coach_shogi_promote_best_1': {
      'id': 'Keputusan promosi yang sangat tepat, melipatgandakan daya serang perwira.',
      'en': 'Top promotion choice, multiplying your piece attack radius.',
      'ja': '的確な昇格。駒の働きが一気に倍増しました。',
      'ms': 'Keputusan promosi yang sangat tepat, menggandakan kuasa serangan perwira.',
    },
    'coach_shogi_promote_best_2': {
      'id': 'Bidak bertransformasi di garis musuh, mempersempit ruang gerak lawan.',
      'en': 'Piece empowered in enemy camp, suffocating their defenses.',
      'ja': '敵陣での「成」により、相手の守備網を突破しました。',
      'ms': 'Bidak bertukar kuasa di kubu musuh, menyempitkan ruang lawan.',
    },
    'coach_shogi_ote_sharp': {
      'id': 'Ōte (王手) yang sangat tajam! Mengawali rangkaian serangan pamungkas.',
      'en': 'Razor-sharp Ōte (Check)! Initiating the decisive offensive sequence.',
      'ja': '鋭い「王手」！決定的な寄せの始まりです。',
      'ms': 'Ōte (王手) yang sangat tajam! Memulakan siri serangan akhir.',
    },
    'coach_shogi_ote_standard': {
      'id': 'Ōte yang baik untuk menguji respon pertahanan lawan.',
      'en': 'Solid check testing opponent\'s defensive response.',
      'ja': '相手の受け方を問う確実な王手です。',
      'ms': 'Ōte yang baik untuk menguji respon pertahanan lawan.',
    },
    'coach_shogi_capture_brilliant': {
      'id': 'Tangkapan emas (Toritate)! Mengambil perwira berat musuh untuk modal serangan.',
      'en': 'Brilliant capture! Taking major material to fuel your drop offensive.',
      'ja': '大駒を奪う見事な駒得！持ち駒が一気に充実しました。',
      'ms': 'Tangkapan cemerlang! Mengambil perwira berat musuh untuk serangan drop.',
    },
    'coach_shogi_capture_best': {
      'id': 'Pukulan perwira bersih yang memperbesar pundi-pundi Mochigoma Anda.',
      'en': 'Clean capture bolstering your in-hand arsenal.',
      'ja': '手堅い駒得。戦況を確実に有利へ導きます。',
      'ms': 'Pukulan perwira bersih yang menambah bidak simpanan anda.',
    },
    'coach_shogi_capture_good': {
      'id': 'Pertukaran yang seimbang di garis depan pertarungan.',
      'en': 'Equitable piece trade on the front lines.',
      'ja': '前線での妥当な駒交換です。',
      'ms': 'Pertukaran yang seimbang di barisan hadapan.',
    },
    'coach_shogi_open_best_1': {
      'id': 'Pembukaan Shogi yang sangat elegan! Memajukan Pion Jalur Gajah/Benteng.',
      'en': 'Elegant Shogi opening! Advancing Bishop/Rook line pawns.',
      'ja': '美しい序盤の駒組み！角道・飛車先を突く基本かつ強力な一手。',
      'ms': 'Pembukaan Shogi yang sangat elegan! Memajukan pion laluan gajah/benteng.',
    },
    'coach_shogi_open_best_2': {
      'id': 'Pembangunan kastil (Kakoi) yang terencana rapi seperti Mino atau Yagura.',
      'en': 'Well-planned castle (Kakoi) construction like Mino or Yagura.',
      'ja': '「美濃囲い」や「矢倉」を思わせる理想的な玉の囲いです。',
      'ms': 'Pembinaan kubu (Kakoi) yang terancang kemas seperti Mino atau Yagura.',
    },
    'coach_shogi_open_best_3': {
      'id': 'Menyiapkan perak (Gin) dan emas (Kin) untuk mengontrol pusat permainan.',
      'en': 'Deploying Silver and Gold generals to dominate the center field.',
      'ja': '銀と金を繰り出し、中央の制空権を握る好手です。',
      'ms': 'Menyiapkan perak (Gin) dan emas (Kin) untuk mengawal pusat permainan.',
    },
    'coach_shogi_open_good': {
      'id': 'Langkah pembukaan yang wajar. Pastikan raja diamankan ke dalam kastil.',
      'en': 'Reasonable opening move. Ensure your king enters a safe castle.',
      'ja': '手堅い出だし。玉の囲いもしっかり進めましょう。',
      'ms': 'Langkah pembukaan yang wajar. Pastikan raja masuk ke kubu selamat.',
    },
    'coach_shogi_open_inaccurate': {
      'id': 'Langkah pembukaan menyimpang dari prinsip keselamatan raja dan ruang.',
      'en': 'Opening deviating from king safety and board development principles.',
      'ja': '序盤の疑問手。玉の守りが手薄なまま攻め急いでいます。',
      'ms': 'Langkah pembukaan menyimpang dari prinsip keselamatan raja.',
    },
    'coach_shogi_best_1': {
      'id': 'Langkah master! Menyatukan sinergi seluruh perwira di papan dan tangan.',
      'en': 'Master move! Perfect synergy between board pieces and in-hand drops.',
      'ja': '名手！盤上の駒と持ち駒の連携が完璧に取れています。',
      'ms': 'Langkah master! Menyatukan sinergi seluruh perwira papan dan simpanan.',
    },
    'coach_shogi_best_2': {
      'id': 'Sabaki (裁き) yang indah! Membebaskan posisi bidak Anda dengan sangat mulus.',
      'en': 'Beautiful Sabaki (fluent coordination)! Resolving piece tension smoothly.',
      'ja': '見事な「駒の捌き（さばき）」！重い形を軽やかに解消しました。',
      'ms': 'Sabaki (裁き) yang indah! Menyelesaikan kedudukan bidak dengan lancar.',
    },
    'coach_shogi_best_3': {
      'id': 'Pondasi pertahanan yang sangat kokoh (Katai), sulit ditembus musuh.',
      'en': 'Ironclad defense (Katai), virtually impenetrable for the opponent.',
      'ja': '「玉の堅さ」を活かした重厚な受けの手です。',
      'ms': 'Pertahanan yang sangat kukuh (Katai), sukar ditembusi musuh.',
    },
    'coach_shogi_best_4': {
      'id': 'Inisiatif serangan mendalam (Semete) yang membongkar kepala perak lawan.',
      'en': 'Deep offensive push (Semete) dismantling opponent\'s silver/gold head.',
      'ja': '「攻めの手筋」を突いた強烈な仕掛けです。',
      'ms': 'Inisiatif serangan mendalam (Semete) yang membongkar kubu lawan.',
    },
    'coach_shogi_good_1': {
      'id': 'Langkah yang aman dan terkontrol, menjaga keseimbangan formasi.',
      'en': 'Safe, controlled move preserving formation equilibrium.',
      'ja': 'バランスの取れた安定感のある一手です。',
      'ms': 'Langkah selamat dan terkawal, menjaga keseimbangan formasi.',
    },
    'coach_shogi_good_2': {
      'id': 'Menambah perlindungan pada perwira yang rawan diserang.',
      'en': 'Reinforcing defense around vulnerable pieces.',
      'ja': '隙を消す手堅い補強です。',
      'ms': 'Menambah perlindungan pada perwira yang terdedah.',
    },
    'coach_shogi_inacc_1': {
      'id': 'Kurang tajam. Memberi kesempatan lawan merapikan susunan kastil mereka.',
      'en': 'Lacks sharpness. Gives opponent room to consolidate their castle.',
      'ja': 'やや緩手。相手に陣形を立て直す隙を与えてしまいました。',
      'ms': 'Kurang tajam. Memberi peluang lawan merapikan kubu mereka.',
    },
    'coach_shogi_inacc_2': {
      'id': 'Bidak Anda berada di jalur yang mudah diserang oleh drop bidak lawan.',
      'en': 'Your piece is stationed on a square prone to enemy drops.',
      'ja': '相手の駒打ちの標的になりやすい配置です。',
      'ms': 'Bidak anda berada di laluan yang mudah diserang oleh drop lawan.',
    },
    'coach_shogi_mistake_1': {
      'id': 'Kesalahan posisi! Kepala raja atau perwira emas Anda terbuka lebar.',
      'en': 'Positional error! The head of your king or gold is wide open.',
      'ja': '悪手です。「玉の頭」や「金の頭」の弱点を突かれる恐れがあります。',
      'ms': 'Kesilapan kedudukan! Kepala raja atau perwira emas anda terbuka.',
    },
    'coach_shogi_mistake_2': {
      'id': 'Langkah ini mengorbankan formasi pertahanan tanpa kompensasi serangan yang jelas.',
      'en': 'This move weakens your castle without sufficient counter-attack value.',
      'ja': '囲いを崩してしまい、守備力が大幅に低下しました。',
      'ms': 'Langkah ini mengorbankan kubu pertahanan tanpa pulangan serangan yang jelas.',
    },
    'coach_shogi_blunder_1': {
      'id': 'Blunder parah! Bidak berat Anda dibiarkan tertangkap tanpa balasan!',
      'en': 'Terrible blunder! Your major piece is captured without return!',
      'ja': '痛恨の大悪手！大駒をタダで取られてしまう危険があります！',
      'ms': 'Blunder teruk! Bidak berat anda dibiarkan ditangkap tanpa balasan!',
    },
    'coach_shogi_blunder_2': {
      'id': 'Bahaya tsumi! Raja Anda langsung masuk ke jangkauan serangan fatal musuh!',
      'en': 'Critical danger! Your king steps directly into a fatal mating net!',
      'ja': '即詰みの危機！王が致命的な包囲網に入ってしまいました！',
      'ms': 'Bahaya tsumi! Raja anda terus masuk ke perangkap maut musuh!',
    },

    'analysis_summary_mastery': {
      'id': 'Performa luar biasa dengan akurasi tinggi layaknya master!',
      'en': 'Outstanding performance with high master-level accuracy!',
      'ja': 'マスター級の高い正確度を誇る見事な指し回しでした！',
      'ms': 'Prestasi luar biasa dengan ketepatan tinggi seperti master!',
    },
    'analysis_summary_balanced': {
      'id': 'Pertandingan solid dan seimbang dengan banyak adu taktik.',
      'en': 'A solid, balanced match with exciting tactical exchanges.',
      'ja': '激しい戦術の応酬が見られた熱戦でした。',
      'ms': 'Perlawanan kukuh dan seimbang dengan banyak pertempuran taktik.',
    },
    'analysis_summary_blunders': {
      'id': 'Ada beberapa blunder kritis yang membalikkan keadaan.',
      'en': 'A few critical blunders shifted the momentum.',
      'ja': 'いくつかの重大なミスが勝敗を大きく分けました。',
      'ms': 'Terdapat beberapa blunder kritikal yang mengubah momentum.',
    },
    'analysis_summary_tactical': {
      'id': 'Banyak dinamika taktis, evaluasi kembali celah pertahanan.',
      'en': 'High tactical volatility, review defensive weaknesses.',
      'ja': '戦術的な展開が多く、守りの隙を見直す良い機会です。',
      'ms': 'Banyak dinamika taktik, nilai semula kelemahan pertahanan.',
    },
  };
}
