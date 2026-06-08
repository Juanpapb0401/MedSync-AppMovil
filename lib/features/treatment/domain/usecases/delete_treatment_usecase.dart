import '../repo/treatment_repo.dart';

class DeleteTreatmentUsecase {
  final TreatmentRepo _repo;

  DeleteTreatmentUsecase(this._repo);

  Future<void> execute(String treatmentId) {
    return _repo.deleteTreatment(treatmentId);
  }
}
