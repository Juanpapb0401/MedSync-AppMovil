import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/model/treatment_summary_model.dart';

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
}