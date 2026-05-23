import '../repo/forgot_password_repo.dart';

class VerifyOtpUsecase {
  final ForgotPasswordRepo _repo;

  VerifyOtpUsecase(this._repo);

  Future<void> execute(String email, String token) async {
    await _repo.verifyOTP(email, token);
  }
}