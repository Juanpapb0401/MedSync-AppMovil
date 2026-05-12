class TreatmentSummaryModel {
  final String patientId;
  final String patientName;
  final int activeMedicinesCount;

  const TreatmentSummaryModel({
    required this.patientId,
    required this.patientName,
    required this.activeMedicinesCount,
  });
}