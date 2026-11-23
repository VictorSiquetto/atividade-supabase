import 'package:dotenv/dotenv.dart';
import 'package:supabase/supabase.dart';

SupabaseClient conectar() {
  final env = DotEnv(includePlatformEnvironment: true)..load();

  final url = env['SUPABASE_URL'];
  final chave = env['SUPABASE_PUBLISHABLE_KEY'];

  if (url == null || url.isEmpty || chave == null || chave.isEmpty) {
    throw Exception(
        'SUPABASE_URL e SUPABASE_PUBLISHABLE_KEY precisam estar no arquivo .env');
  }

  return SupabaseClient(url, chave);
}
