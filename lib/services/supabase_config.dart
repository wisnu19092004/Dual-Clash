class SupabaseConfig {
  /// URL project Supabase Anda
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://lakadxltdxlsyjylxphj.supabase.co',
  );

  /// API Publishable / Anon Key Supabase
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_f4B_xsRoXW0UZJWoOXCW0w_s_XOazxk',
  );

  /// Cek apakah Supabase telah dikonfigurasi dengan URL & Key sebenarnya
  static bool get isConfigured =>
      !supabaseUrl.contains('YOUR_PROJECT_REF.supabase.co') &&
      supabaseAnonKey.isNotEmpty;
}
