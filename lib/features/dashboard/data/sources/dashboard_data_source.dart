import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/model/daily_notification_model.dart';
import '../../domain/model/daily_summary_model.dart';

class DashboardDataSource {
  final _client = Supabase.instance.client;

  Future<DailySummaryModel> getDailySummary(DateTime date) async {
    final authUser = _client.auth.currentSession?.user;
    if (authUser == null) throw Exception('No active session');

    final caregiverId = authUser.id;

    final relation = await _client
        .from('user_relation')
        .select('profile_id')
        .eq('profile_id1', caregiverId)
        .maybeSingle();

    if (relation == null) throw Exception('No linked patient found');
    final patientId = relation['profile_id'] as String;

    final patientData = await _client
        .from('profile')
        .select('full_name')
        .eq('id', patientId)
        .single();
    final patientName = patientData['full_name'] as String;

    final treatmentsResp = await _client
        .from('treatment')
        .select('id')
        .eq('profile_id', patientId);

    final treatmentIds = (treatmentsResp as List)
        .map((t) => t['id'] as String)
        .toList();

    if (treatmentIds.isEmpty) {
      return DailySummaryModel(patientName: patientName, notifications: []);
    }

    final schedulesResp = await _client
        .from('schedule')
        .select('id')
        .inFilter('treatment_id', treatmentIds);

    final scheduleIds = (schedulesResp as List)
        .map((s) => s['id'] as String)
        .toList();

    if (scheduleIds.isEmpty) {
      return DailySummaryModel(patientName: patientName, notifications: []);
    }

    final startOfDay = DateTime(date.year, date.month, date.day).toUtc();
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final notificationsResp = await _client
        .from('notification')
        .select(
          'id, scheduled_datetime, status, '
          'schedule!inner(treatment!inner(medicine!inner(name)))',
        )
        .inFilter('schedule_id', scheduleIds)
        .gte('scheduled_datetime', startOfDay.toIso8601String())
        .lt('scheduled_datetime', endOfDay.toIso8601String())
        .order('scheduled_datetime');

    final notifications = (notificationsResp as List).map((row) {
      final medicineName = row['schedule']['treatment']['medicine']['name']
          as String;
      final scheduledAt =
          DateTime.parse(row['scheduled_datetime'] as String).toLocal();
      return DailyNotificationModel(
        id: row['id'] as String,
        medicineName: medicineName,
        scheduledDateTime: scheduledAt,
        status: row['status'] as String,
      );
    }).toList();

    return DailySummaryModel(
      patientName: patientName,
      notifications: notifications,
    );
  }
}
