import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordRepo {
  Future<void> sendResetEmail(String email) async {
    await Supabase.instance.client.auth.resetPasswordForEmail(email);
  }
}
