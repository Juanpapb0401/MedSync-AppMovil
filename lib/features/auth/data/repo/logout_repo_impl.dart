import 'package:medsync/features/auth/data/sources/logout_data_source.dart';
import '../../domain/repo/logout_repo.dart';

class LogoutRepoImpl implements LogoutRepo {
  final LogoutDataSource _dataSource;

  LogoutRepoImpl(this._dataSource);

  @override
  Future<void> logout() async {
    await _dataSource.logout();
  }
}
