import '../model/treatment_model.dart';
import '../repo/treatment_repo.dart';

class CreateTreatmentUsecase {
  final TreatmentRepo _repo;

  CreateTreatmentUsecase(this._repo);

  Future<void> execute(TreatmentModel treatment) => _repo.saveTreatment(treatment);
}
