import '../model/rutina_medicamento_model.dart';

abstract class RutinaRepo {
  Future<List<RutinaMedicamentoModel>> getDailyRutina(DateTime date);
  Future<void> updateIntakeStatus(String notificationId, String newStatus);
  Future<String> remindLater(String notificationId);
}
