import '../../../../core/domain/model/app_user.dart';
import '../repo/auth_repo.dart';
import '../../data/repo/auth_repo_impl.dart';

class LoginUsecase {
  final AuthRepo _repo = AuthRepoImpl();

  Future<AppUser> execute(String email, String password) {
    return _repo.login(email, password);
  }
}
