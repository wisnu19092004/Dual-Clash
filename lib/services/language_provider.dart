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
  };
}
