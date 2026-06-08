import 'package:medsync/features/auth/data/sources/forgot_password_data_source.dart';
import '../../domain/repo/forgot_password_repo.dart';

class ForgotPasswordRepoImpl implements ForgotPasswordRepo {
  final ForgotPasswordDataSource _dataSource;

  ForgotPasswordRepoImpl(this._dataSource);

  @override
  Future<void> sendResetEmail(String email) async {
    await _dataSource.sendResetEmail(email);
  }

  @override
  Future<void> verifyOTP(String email, String token) async {
    await _dataSource.verifyOTP(email, token);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await _dataSource.updatePassword(newPassword);
  }
}
