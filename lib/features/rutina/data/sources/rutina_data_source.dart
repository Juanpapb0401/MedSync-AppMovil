import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/model/rutina_medicamento_model.dart';

class RutinaDataSource {
  final _client = Supabase.instance.client;

  final _rutinaController =
      StreamController<List<RutinaMedicamentoModel>>.broadcast();

  Stream<List<RutinaMedicamentoModel>> get todayRutinaStream =>
      _rutinaController.stream;

  // ────────────────────────────────────────────────────────────────────────
  // Public API
  // ────────────────────────────────────────────────────────────────────────

  Future<List<RutinaMedicamentoModel>> getDailyRutina(DateTime date) async {
    final authUser = _client.auth.currentSession?.user;
    if (authUser == null) throw Exception('No active session');

    final schedules = await _getPatientSchedules(authUser.id);
    if (schedules.isEmpty) return [];

    await _ensureTodayNotificationsExist(schedules, date);

    final scheduleIds = schedules.map((s) => s['id'] as String).toList();
    final result = await _fetchTodayNotifications(scheduleIds, date);

    // Push so InAppNotificationService gets the latest list via stream
    _pushToStream(result);

    return result;
  }

  Future<void> updateIntakeStatus(
    String notificationId,
    String newStatus,
  ) async {
    final now = DateTime.now().toUtc();

    final notifData = await _client
        .from('notification')
        .select(
          'schedule_id, scheduled_datetime, schedule!inner(interval_hours)',
        )
        .eq('id', notificationId)
        .single();

    final scheduleId = notifData['schedule_id'] as String;
    final scheduledAt =
        DateTime.parse(notifData['scheduled_datetime'] as String);
    final intervalHours =
        (notifData['schedule']['interval_hours'] as num).toInt();

    final updateData = <String, dynamic>{
      'status': newStatus,
      'snooze_count': 0,
    };
    if (newStatus == 'tomado') {
      updateData['taken_datetime'] = now.toIso8601String();
    }

    await _client
        .from('notification')
        .update(updateData)
        .eq('id', notificationId);

    // Adaptive rescheduling: shift the next pending slot
    // tomado  → from actual intake time; omitido → from original schedule time
    final baseTime = newStatus == 'tomado' ? now : scheduledAt;

    final nextNotif = await _client
        .from('notification')
        .select('id')
        .eq('schedule_id', scheduleId)
        .inFilter('status', ['pendiente', 'sin_confirmar'])
        .gt('scheduled_datetime', scheduledAt.toIso8601String())
        .order('scheduled_datetime')
        .limit(1)
        .maybeSingle();

    if (nextNotif != null) {
      final newScheduledAt = baseTime.add(Duration(hours: intervalHours));
      final localNow = now.toLocal();
      final endOfToday =
          DateTime(localNow.year, localNow.month, localNow.day)
              .toUtc()
              .add(const Duration(days: 1));
      if (newScheduledAt.isBefore(endOfToday)) {
        await _client
            .from('notification')
            .update({'scheduled_datetime': newScheduledAt.toIso8601String()})
            .eq('id', nextNotif['id'] as String);
      }
    }

    await _pushTodayRutina();
  }

  Future<String> remindLater(String notificationId) async {
    final current = await _client
        .from('notification')
        .select('snooze_count')
        .eq('id', notificationId)
        .single();

    final newCount = ((current['snooze_count'] as int?) ?? 0) + 1;

    final updateData = <String, dynamic>{'snooze_count': newCount};
    if (newCount >= 2) {
      updateData['status'] = 'sin_confirmar';
    }

    await _client
        .from('notification')
        .update(updateData)
        .eq('id', notificationId);

    await _pushTodayRutina();

    return newCount >= 2 ? 'sin_confirmar' : 'pendiente';
  }

  // ────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ────────────────────────────────────────────────────────────────────────

  /// Fetches today's notifications for the patient and pushes to stream.
  /// Does NOT call _ensureTodayNotificationsExist — use only after a write.
  Future<void> _pushTodayRutina() async {
    try {
      final authUser = _client.auth.currentSession?.user;
      if (authUser == null) return;

      final schedules = await _getPatientSchedules(authUser.id);
      if (schedules.isEmpty) {
        _pushToStream([]);
        return;
      }

      final scheduleIds = schedules.map((s) => s['id'] as String).toList();
      final result =
          await _fetchTodayNotifications(scheduleIds, DateTime.now());
      _pushToStream(result);
    } catch (_) {
      // Never break the stream on a push failure
    }
  }

  void _pushToStream(List<RutinaMedicamentoModel> data) {
    if (!_rutinaController.isClosed) {
      _rutinaController.add(data);
    }
  }

  /// Returns schedule rows (id, interval_hours, time) for the given patient.
  Future<List<Map<String, dynamic>>> _getPatientSchedules(
    String patientId,
  ) async {
    final treatmentsResp = await _client
        .from('treatment')
        .select('id')
        .eq('profile_id', patientId);

    final treatmentIds =
        (treatmentsResp as List).map((t) => t['id'] as String).toList();
    if (treatmentIds.isEmpty) return [];

    final schedulesResp = await _client
        .from('schedule')
        .select('id, interval_hours, time')
        .inFilter('treatment_id', treatmentIds);

    return (schedulesResp as List).cast<Map<String, dynamic>>();
  }

  /// Queries today's notification rows with all joined data; no side-effects.
  Future<List<RutinaMedicamentoModel>> _fetchTodayNotifications(
    List<String> scheduleIds,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day).toUtc();
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final resp = await _client
        .from('notification')
        .select(
          'id, scheduled_datetime, status, '
          'schedule!inner(id, treatment!inner(id, dose, unit, medicine!inner(id, name), restriction(description)))',
        )
        .inFilter('schedule_id', scheduleIds)
        .gte('scheduled_datetime', startOfDay.toIso8601String())
        .lt('scheduled_datetime', endOfDay.toIso8601String())
        .order('scheduled_datetime');

    return (resp as List).map(_mapToModel).toList();
  }

  RutinaMedicamentoModel _mapToModel(dynamic row) {
    final r = row as Map<String, dynamic>;
    final schedule = r['schedule'] as Map<String, dynamic>;
    final treatment = schedule['treatment'] as Map<String, dynamic>;
    final medicine = treatment['medicine'] as Map<String, dynamic>;
    final restrictionsRaw = treatment['restriction'] as List?;

    final restrictions =
        restrictionsRaw?.map((item) => item['description'] as String).toList() ??
            <String>[];

    final scheduledAt =
        DateTime.parse(r['scheduled_datetime'] as String).toLocal();

    return RutinaMedicamentoModel(
      notificationId: r['id'] as String,
      medicineName: medicine['name'] as String,
      dose: _formatDose(treatment['dose']),
      unit: treatment['unit'] as String,
      scheduledDateTime: scheduledAt,
      status: r['status'] as String,
      restrictions: restrictions,
    );
  }

  Future<void> _ensureTodayNotificationsExist(
    List<Map<String, dynamic>> schedules,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day).toUtc();
    final endOfDay = startOfDay.add(const Duration(days: 1));

    for (final schedule in schedules) {
      final scheduleId = schedule['id'] as String;
      final intervalHours = (schedule['interval_hours'] as num).toInt();
      final scheduleTime = schedule['time'] as String?;

      final existing = await _client
          .from('notification')
          .select('id')
          .eq('schedule_id', scheduleId)
          .gte('scheduled_datetime', startOfDay.toIso8601String())
          .lt('scheduled_datetime', endOfDay.toIso8601String())
          .limit(1)
          .maybeSingle();

      if (existing != null) continue;

      final lastTaken = await _client
          .from('notification')
          .select('taken_datetime')
          .eq('schedule_id', scheduleId)
          .eq('status', 'tomado')
          .order('taken_datetime', ascending: false)
          .limit(1)
          .maybeSingle();

      DateTime baseTime;
      if (lastTaken != null && lastTaken['taken_datetime'] != null) {
        final lastTakenAt =
            DateTime.parse(lastTaken['taken_datetime'] as String);
        baseTime = lastTakenAt.add(Duration(hours: intervalHours));
      } else {
        if (scheduleTime != null && scheduleTime.length >= 5) {
          final parts = scheduleTime.split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          baseTime =
              DateTime(date.year, date.month, date.day, hour, minute).toUtc();
        } else {
          baseTime = DateTime(date.year, date.month, date.day, 8, 0).toUtc();
        }
      }

      var slot = baseTime;
      while (slot.isBefore(startOfDay)) {
        slot = slot.add(Duration(hours: intervalHours));
      }

      final List<Map<String, dynamic>> toInsert = [];
      while (slot.isBefore(endOfDay)) {
        toInsert.add({
          'schedule_id': scheduleId,
          'scheduled_datetime': slot.toIso8601String(),
          'original_scheduled_datetime': slot.toIso8601String(),
          'status': 'pendiente',
          'snooze_count': 0,
        });
        slot = slot.add(Duration(hours: intervalHours));
      }

      if (toInsert.isNotEmpty) {
        await _client.from('notification').insert(toInsert);
      }
    }
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
