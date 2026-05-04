import '../model/profile_model.dart';
import '../repo/profile_repo.dart';
import '../../data/repo/profile_repo_impl.dart';

class GetProfileUsecase {
  final ProfileRepo _repo;
  GetProfileUsecase() : _repo = ProfileRepoImpl();

  Future<ProfileModel> execute() => _repo.getProfile();
}
