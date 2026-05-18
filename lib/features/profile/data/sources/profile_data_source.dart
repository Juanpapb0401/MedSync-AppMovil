import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/model/profile_model.dart';

class ProfileDataSource {
  final _client = Supabase.instance.client;

  Future<ProfileModel> getProfile() async {
    final authUser = _client.auth.currentSession?.user;
    if (authUser == null) throw Exception('No active session');

    // Fetch the full profile row by email.
    final data = await _client
        .from('profile')
        .select()
        .eq('email', authUser.email!)
        .single();

    final profileId = data['id'] as String;
    final type = data['type'] as String;
    final storedLinkingCode = data['linking_code'] as String?;
    final linkingCode = _resolveLinkingCode(profileId, storedLinkingCode);

    if (type == 'paciente' && storedLinkingCode != linkingCode) {
      try {
        await _client
            .from('profile')
            .update({'linking_code': linkingCode})
            .eq('id', profileId);
      } catch (_) {
        // Best-effort persistence: the screen can still render the code even if
        // the database update is blocked by permissions or the column is pending.
      }
    }

    LinkedPatientModel? linkedPatient;
    String? linkedCaregiverName;

    if (type == 'cuidador') {
      final relations = await _client
          .from('user_relation')
          .select('profile_id')
          .eq('profile_id1', profileId);

      if ((relations as List).isNotEmpty) {
        final patientId = relations.first['profile_id'] as String;
        final patientData = await _client
            .from('profile')
            .select('id, full_name, linking_code')
            .eq('id', patientId)
            .single();

        linkedPatient = LinkedPatientModel(
          id: patientData['id'] as String,
          fullName: patientData['full_name'] as String,
          linkingCode: _resolveLinkingCode(
            patientData['id'] as String,
            patientData['linking_code'] as String?,
          ),
        );
      }
    } else {
      final relation = await _client
          .from('user_relation')
          .select('profile_id1')
          .eq('profile_id', profileId)
          .maybeSingle();

      if (relation != null) {
        final caregiverId = relation['profile_id1'] as String;
        final caregiver = await _client
            .from('profile')
            .select('full_name')
            .eq('id', caregiverId)
            .single();
        linkedCaregiverName = caregiver['full_name'] as String;
      }
    }

    return ProfileModel(
      id: profileId,
      fullName: data['full_name'] as String,
      email: data['email'] as String,
      type: type,
      linkingCode: linkingCode,
      linkedPatient: linkedPatient,
      linkedCaregiverName: linkedCaregiverName,
    );
  }

  Future<void> linkPatientToCaregiver(String patientCode) async {
    final authUser = _client.auth.currentSession?.user;
    if (authUser == null) throw Exception('No active session');

    final cleanedCode = patientCode.trim().toUpperCase();
    if (cleanedCode.isEmpty) {
      throw Exception('Ingresa el código del paciente');
    }

    final caregiverProfile = await _client
        .from('profile')
        .select('id, type')
        .eq('id', authUser.id)
        .maybeSingle();

    final resolvedCaregiverProfile = caregiverProfile ??
        await _client
            .from('profile')
            .select('id, type')
            .eq('email', authUser.email!)
            .maybeSingle();

    if (resolvedCaregiverProfile == null) {
      throw Exception('No se pudo cargar el perfil del cuidador');
    }

    if (resolvedCaregiverProfile['type'] != 'cuidador') {
      throw Exception('Solo los cuidadores pueden vincular pacientes');
    }

    final patient = await _client
        .from('profile')
        .select('id')
        .eq('type', 'paciente')
        .eq('linking_code', cleanedCode)
        .maybeSingle();

    if (patient == null) {
      throw Exception('El código del paciente no existe');
    }

    final existingRelationByPatient = await _client
        .from('user_relation')
        .select('profile_id')
        .eq('profile_id', patient['id'])
        .maybeSingle();

    if (existingRelationByPatient != null) {
      throw Exception('Este código ya fue vinculado a otro cuidador');
    }

    final existingRelationByCaregiver = await _client
        .from('user_relation')
        .select('profile_id1')
        .eq('profile_id1', resolvedCaregiverProfile['id'])
        .maybeSingle();

    if (existingRelationByCaregiver != null) {
      throw Exception('Ya tienes un paciente vinculado');
    }

    await _client.from('user_relation').insert({
      'profile_id': patient['id'],
      'profile_id1': resolvedCaregiverProfile['id'],
    });
  }

  String _resolveLinkingCode(String profileId, String? storedLinkingCode) {
    final cleanedStoredCode = storedLinkingCode?.trim();
    if (cleanedStoredCode != null && cleanedStoredCode.isNotEmpty) {
      return cleanedStoredCode;
    }

    final digits = profileId.replaceAll(RegExp(r'\D'), '');
    final codeDigits = digits.isEmpty
        ? '0000'
        : digits.length >= 4
        ? digits.substring(0, 4)
        : digits.padLeft(4, '0');
    return 'MED-$codeDigits';
  }
}
