import '../../../../core/domain/model/app_user.dart';
import '../../domain/repo/auth_repo.dart';
import '../sources/auth_data_source.dart';

class AuthRepoImpl extends AuthRepo {
  final AuthDataSource _source = AuthDataSource();

  @override
  Future<AppUser> login(String email, String password) {
    return _source.login(email, password);
  }
}
