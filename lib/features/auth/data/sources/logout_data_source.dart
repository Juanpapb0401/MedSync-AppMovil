import 'package:supabase_flutter/supabase_flutter.dart';

class LogoutDataSource {
  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
  }
}
