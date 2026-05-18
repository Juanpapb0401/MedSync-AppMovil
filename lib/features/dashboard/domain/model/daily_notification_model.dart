class DailyNotificationModel {
  final String id;
  final String medicineName;
  final DateTime scheduledDateTime;
  final String status; // 'pendiente', 'tomado', 'omitido', 'sin_confirmar'

  const DailyNotificationModel({
    required this.id,
    required this.medicineName,
    required this.scheduledDateTime,
    required this.status,
  });
}
