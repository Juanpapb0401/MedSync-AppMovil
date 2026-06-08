import '../model/treatment_list_model.dart';
import '../repo/treatment_repo.dart';

class GetTreatmentsUsecase {
  final TreatmentRepo _repo;

  GetTreatmentsUsecase(this._repo);

  Future<TreatmentListResultModel> execute() => _repo.getTreatments();
}