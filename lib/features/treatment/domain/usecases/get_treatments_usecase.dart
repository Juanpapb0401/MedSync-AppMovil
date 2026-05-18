import '../model/treatment_list_model.dart';
import '../repo/treatment_repo.dart';
import '../../data/repo/treatment_repo_impl.dart';

class GetTreatmentsUsecase {
  final TreatmentRepo _repo;

  GetTreatmentsUsecase() : _repo = TreatmentRepoImpl();

  Future<TreatmentListResultModel> execute() => _repo.getTreatments();
}