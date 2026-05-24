class RutinaMedicamentoModel {
  final String notificationId;
  final String medicineName;
  final String dose;
  final String unit;
  final DateTime scheduledDateTime;
  final String status; // 'pendiente', 'tomado', 'omitido', 'sin_confirmar'
  final List<String> restrictions;

  const RutinaMedicamentoModel({
    required this.notificationId,
    required this.medicineName,
    required this.dose,
    required this.unit,
    required this.scheduledDateTime,
    required this.status,
    required this.restrictions,
  });

  bool get isTaken => status == 'tomado';
  bool get isOmitted => status == 'omitido';
  bool get isPending => status == 'pendiente' || status == 'sin_confirmar';
}
