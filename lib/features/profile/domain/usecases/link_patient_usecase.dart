import '../repo/profile_repo.dart';
import '../../data/repo/profile_repo_impl.dart';

class LinkPatientUsecase {
  final ProfileRepo _repo;

  LinkPatientUsecase() : _repo = ProfileRepoImpl();

  Future<void> execute(String patientCode) {
    return _repo.linkPatientToCaregiver(patientCode);
  }
}