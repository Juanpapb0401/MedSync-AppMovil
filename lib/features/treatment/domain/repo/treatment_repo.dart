import '../model/treatment_summary_model.dart';

abstract class TreatmentRepo {
  Future<TreatmentSummaryModel> getTreatmentSummary();
}