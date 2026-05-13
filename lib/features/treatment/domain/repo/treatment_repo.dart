import '../model/treatment_summary_model.dart';
import '../model/treatment_model.dart';

abstract class TreatmentRepo {
  Future<TreatmentSummaryModel> getTreatmentSummary();
  Future<void> saveTreatment(TreatmentModel treatment);
}