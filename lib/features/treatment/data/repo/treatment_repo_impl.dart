import '../../domain/model/treatment_summary_model.dart';
import '../../domain/model/treatment_model.dart';
import '../../domain/model/treatment_list_model.dart';
import '../../domain/repo/treatment_repo.dart';
import '../sources/treatment_data_source.dart';

class TreatmentRepoImpl implements TreatmentRepo {
  final TreatmentDataSource _source;

  TreatmentRepoImpl(this._source);

  @override
  Future<TreatmentSummaryModel> getTreatmentSummary() =>
      _source.getTreatmentSummary();

  @override
  Future<TreatmentListResultModel> getTreatments() => _source.getTreatments();

  @override
  Future<void> saveTreatment(TreatmentModel treatment) =>
      _source.saveTreatment(treatment);

  @override
  Future<void> updateTreatment(String treatmentId, TreatmentModel treatment) =>
      _source.updateTreatment(treatmentId, treatment);

  @override
  Future<void> deleteTreatment(String treatmentId) =>
      _source.deleteTreatment(treatmentId);
}