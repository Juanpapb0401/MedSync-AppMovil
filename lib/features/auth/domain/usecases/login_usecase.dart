import '../../../profile/domain/model/profile_model.dart';
import '../repo/auth_repo.dart';

class LoginUsecase {
  final AuthRepo _repo;

  LoginUsecase(this._repo);

  Future<ProfileModel> execute(String email, String password) {
    return _repo.login(email, password);
  }
}
