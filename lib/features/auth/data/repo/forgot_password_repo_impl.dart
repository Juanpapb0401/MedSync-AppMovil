import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repo/forgot_password_repo.dart';

class ForgotPasswordRepoImpl implements ForgotPasswordRepo {
  @override
  Future<void> sendResetEmail(String email) async {
    await Supabase.instance.client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> verifyOTP(String email, String token) async {
    await Supabase.instance.client.auth.verifyOTP(
      type: OtpType.recovery,
      token: token,
      email: email,
    );
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await Supabase.instance.client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
}