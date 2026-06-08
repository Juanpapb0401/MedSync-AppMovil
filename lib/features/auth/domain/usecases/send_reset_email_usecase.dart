import '../repo/forgot_password_repo.dart';

class SendResetEmailUsecase {
  final ForgotPasswordRepo _repo;

  SendResetEmailUsecase(this._repo);

  Future<void> execute(String email) async {
    await _repo.sendResetEmail(email);
  }
}