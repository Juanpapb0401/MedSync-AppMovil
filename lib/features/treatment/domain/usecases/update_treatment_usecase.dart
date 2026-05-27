import '../model/treatment_model.dart';
import '../repo/treatment_repo.dart';

class UpdateTreatmentUsecase {
  final TreatmentRepo _repo;

  UpdateTreatmentUsecase(this._repo);

  Future<void> execute(String treatmentId, TreatmentModel treatment) {
    return _repo.updateTreatment(treatmentId, treatment);
  }
}