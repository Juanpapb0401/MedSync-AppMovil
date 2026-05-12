import '../../../profile/domain/model/profile_model.dart';
import '../repo/auth_repo.dart';
import '../../data/repo/auth_repo_impl.dart';

class LoginUsecase {
  final AuthRepo _repo = AuthRepoImpl();

  Future<ProfileModel> execute(String email, String password) {
    return _repo.login(email, password);
  }
}
