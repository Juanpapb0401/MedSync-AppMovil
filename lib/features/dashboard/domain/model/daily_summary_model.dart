import 'daily_notification_model.dart';

class DailySummaryModel {
  final String patientName;
  final List<DailyNotificationModel> notifications;

  const DailySummaryModel({
    required this.patientName,
    required this.notifications,
  });

  int get tomadas => notifications.where((n) => n.status == 'tomado').length;

  int get sinConfirmar =>
      notifications.where((n) => n.status == 'sin_confirmar').length;

  int get omitidas =>
      notifications.where((n) => n.status == 'omitido').length + sinConfirmar;

  int get total => notifications.length;

  double? get logroPct => total == 0 ? null : tomadas / total * 100;
}
