import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/model/rutina_medicamento_model.dart';

class RutinaDataSource {
  final _client = Supabase.instance.client;

  Future<List<RutinaMedicamentoModel>> getDailyRutina(DateTime date) async {
    final authUser = _client.auth.currentSession?.user;
    if (authUser == null) throw Exception('No active session');

    final patientId = authUser.id;

    // 1. Get the patient's treatments
    final treatmentsResp = await _client
        .from('treatment')
        .select('id')
        .eq('profile_id', patientId);

    final treatmentIds = (treatmentsResp as List)
        .map((t) => t['id'] as String)
        .toList();

    if (treatmentIds.isEmpty) return [];

    // 2. Get the schedules for those treatments
    final schedulesResp = await _client
        .from('schedule')
        .select('id')
        .inFilter('treatment_id', treatmentIds);

    final schedules = schedulesResp as List;
    if (schedules.isEmpty) return [];

    final scheduleIds = schedules.map((s) => s['id'] as String).toList();

    // 3. Define the start and end of today in UTC
    final startOfDay = DateTime(date.year, date.month, date.day).toUtc();
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // 4. Fetch all notifications for today directly (No lazy generation!)
    final notificationsResp = await _client
        .from('notification')
        .select(
          'id, scheduled_datetime, status, '
          'schedule!inner(id, treatment!inner(id, dose, unit, medicine!inner(id, name), restriction(description)))',
        )
        .inFilter('schedule_id', scheduleIds)
        .gte('scheduled_datetime', startOfDay.toIso8601String())
        .lt('scheduled_datetime', endOfDay.toIso8601String())
        .order('scheduled_datetime');

    // 5. Map to domain models
    return (notificationsResp as List).map((row) {
      final schedule = row['schedule'] as Map<String, dynamic>;
      final treatment = schedule['treatment'] as Map<String, dynamic>;
      final medicine = treatment['medicine'] as Map<String, dynamic>;
      final restrictionsRaw = treatment['restriction'] as List?;

      final restrictions = restrictionsRaw
              ?.map((item) => item['description'] as String)
              .toList() ??
          <String>[];

      final scheduledAt =
          DateTime.parse(row['scheduled_datetime'] as String).toLocal();

      return RutinaMedicamentoModel(
        notificationId: row['id'] as String,
        medicineName: medicine['name'] as String,
        dose: _formatDose(treatment['dose']),
        unit: treatment['unit'] as String,
        scheduledDateTime: scheduledAt,
        status: row['status'] as String,
        restrictions: restrictions,
      );
    }).toList();
  }

  Future<void> updateIntakeStatus(String notificationId, String newStatus) async {
    await _client
        .from('notification')
        .update({'status': newStatus})
        .eq('id', notificationId);
  }

  String _formatDose(dynamic dose) {
    if (dose == null) return '';
    if (dose is num) {
      final value = dose.toDouble();
      return value % 1 == 0 ? value.toInt().toString() : value.toString();
    }
    return dose.toString();
  }
}
