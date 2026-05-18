import '../model/treatment_summary_model.dart';
import '../model/treatment_model.dart';
import '../model/treatment_list_model.dart';

abstract class TreatmentRepo {
  Future<TreatmentSummaryModel> getTreatmentSummary();
  Future<TreatmentListResultModel> getTreatments();
  Future<void> saveTreatment(TreatmentModel treatment);
  Future<void> updateTreatment(String treatmentId, TreatmentModel treatment);
  Future<void> deleteTreatment(String treatmentId);
}