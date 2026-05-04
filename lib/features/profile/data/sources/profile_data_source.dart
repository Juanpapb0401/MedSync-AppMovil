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

    // In Supabase, auth.users.id and profile.id are the same UUID when the
    // profile was created via the auth trigger. We try both so the query works
    // regardless of how the test data was inserted.
    final lookupId = authUser.id;

    LinkedPatientModel? linkedPatient;
    String? linkedCaregiverName;

    if (type == 'cuidador') {
      // Find patients whose caregiver FK points to the current user.
      // Try the auth UUID first; fall back to profile.id if different.
      var patients = await _client
          .from('profile')
          .select('id, full_name, linking_code')
          .eq('caregiver', lookupId);

      if ((patients as List).isEmpty && lookupId != profileId) {
        patients = await _client
            .from('profile')
            .select('id, full_name, linking_code')
            .eq('caregiver', profileId);
      }

      if ((patients as List).isNotEmpty) {
        final p = patients.first;
        linkedPatient = LinkedPatientModel(
          id: p['id'] as String,
          fullName: p['full_name'] as String,
          linkingCode: _resolveLinkingCode(
            p['id'] as String,
            p['linking_code'] as String?,
          ),
        );
      }
    } else {
      // Patient: the caregiver field holds the caregiver's profile UUID.
      final caregiverUuid = data['caregiver'] as String?;
      if (caregiverUuid != null) {
        final caregiver = await _client
            .from('profile')
            .select('full_name')
            .eq('id', caregiverUuid)
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

  String _resolveLinkingCode(String profileId, String? storedLinkingCode) {
    final cleanedStoredCode = storedLinkingCode?.trim();
    if (cleanedStoredCode != null && cleanedStoredCode.isNotEmpty) {
      return cleanedStoredCode;
    }

    final digits = profileId.replaceAll(RegExp(r'\D'), '');
    final codeDigits = digits.isEmpty
        ? '000'
        : digits.length >= 3
        ? digits.substring(0, 3)
        : digits.padLeft(3, '0');
    return 'MED-$codeDigits';
  }
}
