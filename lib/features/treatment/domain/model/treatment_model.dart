class TreatmentModel {
  final String medicineName;
  final String dose;
  final String unit; // mg, ml, comprimidos
  final String frequency; // Cada 8 horas, etc.
  final String startTime; // 08:00 AM
  final List<String> restrictions;

  const TreatmentModel({
    required this.medicineName,
    required this.dose,
    required this.unit,
    required this.frequency,
    required this.startTime,
    required this.restrictions,
  });

  TreatmentModel copyWith({
    String? medicineName,
    String? dose,
    String? unit,
    String? frequency,
    String? startTime,
    List<String>? restrictions,
  }) {
    return TreatmentModel(
      medicineName: medicineName ?? this.medicineName,
      dose: dose ?? this.dose,
      unit: unit ?? this.unit,
      frequency: frequency ?? this.frequency,
      startTime: startTime ?? this.startTime,
      restrictions: restrictions ?? this.restrictions,
    );
  }
}
