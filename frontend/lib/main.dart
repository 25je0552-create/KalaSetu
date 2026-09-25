import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env)
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('[Environment] .env file not loaded, falling back to defaults: $e');
  }

  // ═══════════════════════════════════════════════════════════════
  // SUPABASE INITIALIZATION
  // ═══════════════════════════════════════════════════════════════
  // TODO: replace with real Supabase project credentials from your Supabase Dashboard
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'https://placeholder-project.supabase.co';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 'placeholder-anon-key-xyz-1234567890';

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    debugPrint('[Supabase] Initialized with endpoint: $supabaseUrl');
  } catch (e) {
    debugPrint('[Supabase] Init error (running offline / mock auth fallback): $e');
  }

  runApp(
    const ProviderScope(
      child: KalaSetuApp(),
    ),
  );
}
