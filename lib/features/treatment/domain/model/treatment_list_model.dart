import 'treatment_model.dart';

class TreatmentListItemModel {
  final String id;
  final TreatmentModel treatment;

  const TreatmentListItemModel({
    required this.id,
    required this.treatment,
  });
}

class TreatmentListResultModel {
  final String patientName;
  final List<TreatmentListItemModel> treatments;

  const TreatmentListResultModel({
    required this.patientName,
    required this.treatments,
  });
}