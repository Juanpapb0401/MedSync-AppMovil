import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/model/treatment_summary_model.dart';
import '../../domain/model/treatment_model.dart';

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

    await _client.from('schedule').insert({
      'frequency_type': 'intervalo',
      'interval_hours': intervalHours,
      'treatment_id': treatmentId,
    });

    // 5. Insert Restrictions
    if (treatment.restrictions.isNotEmpty) {
      final restrictionsToInsert = treatment.restrictions.map((r) => {
        'treatment_id': treatmentId,
        'description': r,
        'restriction_type': 'general',
      }).toList();
      await _client.from('restriction').insert(restrictionsToInsert);
    }
  }
}