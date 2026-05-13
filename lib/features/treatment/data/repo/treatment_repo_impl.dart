import '../../domain/model/treatment_summary_model.dart';
import '../../domain/model/treatment_model.dart';
import '../../domain/repo/treatment_repo.dart';
import '../sources/treatment_data_source.dart';

class TreatmentRepoImpl implements TreatmentRepo {
  final _source = TreatmentDataSource();

  @override
  Future<TreatmentSummaryModel> getTreatmentSummary() =>
      _source.getTreatmentSummary();

  @override
  Future<void> saveTreatment(TreatmentModel treatment) =>
      _source.saveTreatment(treatment);
}