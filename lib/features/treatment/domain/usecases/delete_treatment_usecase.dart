import '../repo/treatment_repo.dart';
import '../../data/repo/treatment_repo_impl.dart';

class DeleteTreatmentUsecase {
  final TreatmentRepo _repo;

  DeleteTreatmentUsecase() : _repo = TreatmentRepoImpl();

  Future<void> execute(String treatmentId) {
    return _repo.deleteTreatment(treatmentId);
  }
}
