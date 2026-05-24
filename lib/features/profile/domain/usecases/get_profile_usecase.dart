import '../model/profile_model.dart';
import '../repo/profile_repo.dart';

class GetProfileUsecase {
  final ProfileRepo _repo;
  GetProfileUsecase(this._repo);

  Future<ProfileModel> execute() => _repo.getProfile();
}
