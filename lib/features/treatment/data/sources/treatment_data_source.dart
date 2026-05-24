import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/model/treatment_summary_model.dart';
import '../../domain/model/treatment_model.dart';
import '../../domain/model/treatment_list_model.dart';

class TreatmentDataSource {
  final _client = Supabase.instance.client;

  Future<TreatmentSummaryModel> getTreatmentSummary() async {
    final authUser = _client.auth.currentSession?.user;
    if (authUser == null) throw Exception('No active session');

    final caregiverId = authUser.id;

    final relations = await _client
        .from('user_relation')
        .select('profile_id')
        .eq('profile_id1', caregiverId);

    if ((relations as List).isEmpty) {
      throw Exception('No linked patient found');
    }

    final patientId = relations.first['profile_id'] as String;

    final patientData = await _client
        .from('profile')
        .select('full_name')
        .eq('id', patientId)
        .single();

    final patientName = patientData['full_name'] as String;

    final treatmentsResponse = await _client
        .from('treatment')
        .select('id')
        .eq('profile_id', patientId);

    final activeMedicinesCount = (treatmentsResponse as List).length;

    return TreatmentSummaryModel(
      patientId: patientId,
      patientName: patientName,
      activeMedicinesCount: activeMedicinesCount,
    );
  }

  Future<void> saveTreatment(TreatmentModel treatment) async {
    final authUser = _client.auth.currentSession?.user;
    if (authUser == null) throw Exception('No active session');

    final caregiverId = authUser.id;

    // 1. Get patient ID
    final relations = await _client
        .from('user_relation')
        .select('profile_id')
        .eq('profile_id1', caregiverId);

    if ((relations as List).isEmpty) {
      throw Exception('No linked patient found');
    }
    final patientId = relations.first['profile_id'] as String;

    // 2. Handle Medicine
    final existingMedicine = await _client
        .from('medicine')
        .select('id')
        .eq('name', treatment.medicineName)
        .maybeSingle();

    String medicineId;
    if (existingMedicine != null) {
      medicineId = existingMedicine['id'] as String;
    } else {
      final newMedicine = await _client.from('medicine').insert({
        'name': treatment.medicineName,
        'medicine_type': 'General',
      }).select('id').single();
      medicineId = newMedicine['id'] as String;
    }

    // 3. Insert Treatment
    final newTreatment = await _client.from('treatment').insert({
      'dose': double.tryParse(treatment.dose) ?? 0.0,
      'unit': treatment.unit,
      'start_date': DateTime.now().toIso8601String().split('T')[0],
      'medicine_id': medicineId,
      'profile_id': patientId,
    }).select('id').single();
    final treatmentId = newTreatment['id'] as String;

    // 4. Insert Schedule
    int intervalHours = 8;
    if (treatment.frequency.contains('12')) intervalHours = 12;
    if (treatment.frequency.contains('24')) intervalHours = 24;

    final normalizedTime = _normalizeStartTime(treatment.startTime);

    final scheduleRow = await _client.from('schedule').insert({
      'frequency_type': 'intervalo',
      'interval_hours': intervalHours,
      if (normalizedTime != null) 'time': normalizedTime,
      'treatment_id': treatmentId,
    }).select('id').single();

    // 5. Generate notifications for the next 30 days
    final scheduleId = scheduleRow['id'] as String;
    final notifications = _buildNotifications(
      scheduleId: scheduleId,
      startTimeStr: normalizedTime ?? '08:00:00',
      intervalHours: intervalHours,
    );
    if (notifications.isNotEmpty) {
      await _client.from('notification').insert(notifications);
    }

    // 6. Insert Restrictions
    if (treatment.restrictions.isNotEmpty) {
      final restrictionsToInsert = treatment.restrictions.map((r) => {
        'treatment_id': treatmentId,
        'description': r,
        'restriction_type': 'general',
      }).toList();
      await _client.from('restriction').insert(restrictionsToInsert);
    }
  }

  Future<void> updateTreatment(String treatmentId, TreatmentModel treatment) async {
    final authUser = _client.auth.currentSession?.user;
    if (authUser == null) throw Exception('No active session');

    final caregiverId = authUser.id;

    final relations = await _client
        .from('user_relation')
        .select('profile_id')
        .eq('profile_id1', caregiverId)
        .maybeSingle();

    if (relations == null) {
      throw Exception('No linked patient found');
    }

    final patientId = relations['profile_id'] as String;

    final existingMedicine = await _client
        .from('medicine')
        .select('id')
        .eq('name', treatment.medicineName)
        .maybeSingle();

    String medicineId;
    if (existingMedicine != null) {
      medicineId = existingMedicine['id'] as String;
    } else {
      final newMedicine = await _client.from('medicine').insert({
        'name': treatment.medicineName,
        'medicine_type': 'General',
      }).select('id').single();
      medicineId = newMedicine['id'] as String;
    }

    await _client
        .from('treatment')
        .update({
          'dose': double.tryParse(treatment.dose) ?? 0.0,
          'unit': treatment.unit,
          'medicine_id': medicineId,
        })
        .eq('id', treatmentId)
        .eq('profile_id', patientId);

    final intervalHours = _resolveIntervalHours(treatment.frequency);
    final normalizedTime = _normalizeStartTime(treatment.startTime);

    final scheduleUpdate = <String, dynamic>{
      'frequency_type': 'intervalo',
      'interval_hours': intervalHours,
    };
    if (normalizedTime != null) {
      scheduleUpdate['time'] = normalizedTime;
    }

    final scheduleRow = await _client
        .from('schedule')
        .update(scheduleUpdate)
        .eq('treatment_id', treatmentId)
        .select('id')
        .single();

    // Regenerate future pending notifications when schedule changes
    final scheduleId = scheduleRow['id'] as String;
    final now = DateTime.now().toUtc().toIso8601String();
    await _client
        .from('notification')
        .delete()
        .eq('schedule_id', scheduleId)
        .eq('status', 'pendiente')
        .gte('scheduled_datetime', now);

    final regenNotifications = _buildNotifications(
      scheduleId: scheduleId,
      startTimeStr: normalizedTime ?? '08:00:00',
      intervalHours: intervalHours,
    );
    if (regenNotifications.isNotEmpty) {
      await _client.from('notification').insert(regenNotifications);
    }

    await _client.from('restriction').delete().eq('treatment_id', treatmentId);

    if (treatment.restrictions.isNotEmpty) {
      final restrictionsToInsert = treatment.restrictions.map((r) => {
        'treatment_id': treatmentId,
        'description': r,
        'restriction_type': 'general',
      }).toList();
      await _client.from('restriction').insert(restrictionsToInsert);
    }
  }

  Future<TreatmentListResultModel> getTreatments() async {
    final authUser = _client.auth.currentSession?.user;
    if (authUser == null) throw Exception('No active session');

    final caregiverId = authUser.id;

    final relation = await _client
        .from('user_relation')
        .select('profile_id')
        .eq('profile_id1', caregiverId)
        .maybeSingle();

    if (relation == null) {
      throw Exception('No linked patient found');
    }

    final patientId = relation['profile_id'] as String;

    final patientData = await _client
        .from('profile')
        .select('full_name')
        .eq('id', patientId)
        .single();

    final patientName = patientData['full_name'] as String;

    final treatmentsResponse = await _client
        .from('treatment')
        .select('id, dose, unit, medicine_id')
        .eq('profile_id', patientId)
        .order('id');

    final treatments = await Future.wait(
      (treatmentsResponse as List).map((row) async {
        final treatmentId = row['id'] as String;
        final medicineId = row['medicine_id'] as String;

        final medicineData = await _client
            .from('medicine')
            .select('name')
            .eq('id', medicineId)
            .single();

        final scheduleData = await _client
            .from('schedule')
            .select('frequency_type, time, interval_hours')
            .eq('treatment_id', treatmentId)
            .maybeSingle();

        final restrictionsResponse = await _client
            .from('restriction')
            .select('description')
            .eq('treatment_id', treatmentId);

        final restrictions = (restrictionsResponse as List)
            .map((item) => item['description'] as String)
            .toList();

        return TreatmentListItemModel(
          id: treatmentId,
          treatment: TreatmentModel(
            medicineName: medicineData['name'] as String,
            dose: _formatDose(row['dose']),
            unit: row['unit'] as String,
            frequency: _resolveFrequencyLabel(scheduleData),
            startTime: _resolveStartTimeLabel(scheduleData),
            restrictions: restrictions,
          ),
        );
      }),
    );

    return TreatmentListResultModel(
      patientName: patientName,
      treatments: treatments,
    );
  }

  String _resolveFrequencyLabel(Map<String, dynamic>? scheduleData) {
    final intervalHours = scheduleData?['interval_hours'];
    if (intervalHours != null) {
      final hours = intervalHours is num
          ? intervalHours.toInt()
          : int.tryParse(intervalHours.toString()) ?? 8;
      return 'Cada ${hours}h';
    }

    final frequencyType = scheduleData?['frequency_type']?.toString();
    if (frequencyType == 'fija') {
      return 'Hora fija';
    }

    return 'Cada 8h';
  }

  int _resolveIntervalHours(String frequency) {
    if (frequency.contains('12')) return 12;
    if (frequency.contains('24')) return 24;
    return 8;
  }

  String _resolveStartTimeLabel(Map<String, dynamic>? scheduleData) {
    final rawTime = scheduleData?['time']?.toString();
    if (rawTime == null || rawTime.isEmpty) {
      return 'Inicio: --:--';
    }

    final normalized = rawTime.length >= 5 ? rawTime.substring(0, 5) : rawTime;
    return 'Inicio: $normalized';
  }

  String? _normalizeStartTime(String startTime) {
    final value = startTime.trim();
    if (value.isEmpty) return null;

    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*([AaPp][Mm])?$').firstMatch(value);
    if (match == null) return null;

    var hour = int.parse(match.group(1)!);
    final minute = match.group(2)!;
    final meridiem = match.group(3)?.toUpperCase();

    if (meridiem == 'PM' && hour != 12) hour += 12;
    if (meridiem == 'AM' && hour == 12) hour = 0;

    return '${hour.toString().padLeft(2, '0')}:$minute:00';
  }

  Future<void> deleteTreatment(String treatmentId) async {
    final authUser = _client.auth.currentSession?.user;
    if (authUser == null) throw Exception('No active session');

    final schedules = await _client
        .from('schedule')
        .select('id')
        .eq('treatment_id', treatmentId);

    for (final schedule in schedules as List) {
      await _client
          .from('notification')
          .delete()
          .eq('schedule_id', schedule['id'] as String);
    }

    await _client.from('schedule').delete().eq('treatment_id', treatmentId);
    await _client.from('restriction').delete().eq('treatment_id', treatmentId);
    await _client.from('treatment').delete().eq('id', treatmentId);
  }

  String _formatDose(dynamic dose) {
    if (dose == null) return '';
    if (dose is num) {
      final value = dose.toDouble();
      return value % 1 == 0 ? value.toInt().toString() : value.toString();
    }
    return dose.toString();
  }

  List<Map<String, dynamic>> _buildNotifications({
    required String scheduleId,
    required String startTimeStr,
    required int intervalHours,
    int daysAhead = 30,
  }) {
    final results = <Map<String, dynamic>>[];
    final parts = startTimeStr.split(':');
    final startHour = int.tryParse(parts[0]) ?? 8;
    final startMinute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    final today = DateTime.now();
    final startDate = DateTime(today.year, today.month, today.day);

    for (int dayOffset = 0; dayOffset < daysAhead; dayOffset++) {
      final date = startDate.add(Duration(days: dayOffset));
      final endOfDay = date.add(const Duration(days: 1));
      var current = DateTime(date.year, date.month, date.day, startHour, startMinute);

      while (current.isBefore(endOfDay)) {
        final iso = current.toUtc().toIso8601String();
        results.add({
          'scheduled_datetime': iso,
          'original_scheduled_datetime': iso,
          'status': 'pendiente',
          'schedule_id': scheduleId,
        });
        current = current.add(Duration(hours: intervalHours));
      }
    }

    return results;
  }
}