import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  final supabase = SupabaseClient(
    dotenv.env['SUPABASE_URL']!,
    dotenv.env['SUPABASE_ANON_KEY']!,
  );

  try {
    final response = await supabase.auth.signUp(
      email: 'testuser_${DateTime.now().millisecondsSinceEpoch}@example.com',
      password: 'password123',
      data: {'full_name': 'Test User', 'role': 'paciente'},
    );
    print("Success: \${response.user?.id}");
  } catch (e) {
    print("Error: \$e");
  }
}
