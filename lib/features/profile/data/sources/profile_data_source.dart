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
          .select('id, full_name')
          .eq('caregiver', lookupId);

      if ((patients as List).isEmpty && lookupId != profileId) {
        patients = await _client
            .from('profile')
            .select('id, full_name')
            .eq('caregiver', profileId);
      }

      if ((patients as List).isNotEmpty) {
        final p = patients.first;
        linkedPatient = LinkedPatientModel(
          id: p['id'] as String,
          fullName: p['full_name'] as String,
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
      linkedPatient: linkedPatient,
      linkedCaregiverName: linkedCaregiverName,
    );
  }
}
