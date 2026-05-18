import '../model/treatment_model.dart';
import '../repo/treatment_repo.dart';
import '../../data/repo/treatment_repo_impl.dart';

class UpdateTreatmentUsecase {
  final TreatmentRepo _repo;

  UpdateTreatmentUsecase() : _repo = TreatmentRepoImpl();

  Future<void> execute(String treatmentId, TreatmentModel treatment) {
    return _repo.updateTreatment(treatmentId, treatment);
  }
}