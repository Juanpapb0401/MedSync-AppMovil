import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/domain/model/app_user.dart';

class AuthDataSource {
  Future<AppUser> login(String email, String password) async {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final userId = response.user!.id;

    final profile = await Supabase.instance.client
        .from('profile')
        .select('type')
        .eq('email', email)
        .single();

    return AppUser(
      id: userId,
      email: email,
      role: profile['type'] as String,
    );
  }
}
