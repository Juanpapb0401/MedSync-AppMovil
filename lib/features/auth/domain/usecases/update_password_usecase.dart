import '../repo/forgot_password_repo.dart';

class UpdatePasswordUsecase {
  final ForgotPasswordRepo _repo;

  UpdatePasswordUsecase(this._repo);

  Future<void> execute(String newPassword) async {
    await _repo.updatePassword(newPassword);
  }
}