import '../model/treatment_summary_model.dart';
import '../repo/treatment_repo.dart';

class GetTreatmentSummaryUsecase {
  final TreatmentRepo _repo;

  GetTreatmentSummaryUsecase(this._repo);

  Future<TreatmentSummaryModel> execute() => _repo.getTreatmentSummary();
}