import '../repo/profile_repo.dart';

class LinkPatientUsecase {
  final ProfileRepo _repo;

  LinkPatientUsecase(this._repo);

  Future<void> execute(String patientCode) {
    return _repo.linkPatientToCaregiver(patientCode);
  }
}