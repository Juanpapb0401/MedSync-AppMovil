abstract class ForgotPasswordRepo {
  Future<void> sendResetEmail(String email);
  Future<void> verifyOTP(String email, String token);
  Future<void> updatePassword(String newPassword);
}