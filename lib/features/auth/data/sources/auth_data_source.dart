import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/domain/model/app_user.dart';

class AuthDataSource {
  Future<AppUser> login(String email, String password) async {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final userId = response.user!.id;

    final profile = await Supabase.instance.client
        .from('profile')
        .select('type')
        .eq('email', email)
        .single();

    return AppUser(id: userId, email: email, role: profile['type'] as String);
  }

  Future<AppUser> registerPatient(
    String fullName,
    String email,
    String password, {
    Uint8List? avatarBytes,
    String? avatarExt,
  }) async {
    await _ensureEmailAvailable(email);

    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'type': 'paciente'},
    );

    final userId = response.user!.id;
    String? avatarUrl;

    if (avatarBytes != null && avatarExt != null) {
      try {
        final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$avatarExt';

        await Supabase.instance.client.storage
            .from('avatars')
            .uploadBinary(fileName, avatarBytes);

        avatarUrl = Supabase.instance.client.storage
            .from('avatars')
            .getPublicUrl(fileName);

        await Supabase.instance.client.auth.updateUser(
          UserAttributes(data: {'avatar_url': avatarUrl}),
        );

        await Supabase.instance.client
            .from('profile')
            .update({'avatar_url': avatarUrl})
            .eq('id', userId);
      } catch (e) {
        // Log the error or handle it securely without breaking the registration flow
      }
    }

    await _createProfile(
      id: userId,
      fullName: fullName,
      email: email,
      password: password,
      type: 'paciente',
    );

    return AppUser(id: userId, email: email, role: 'paciente');
  }

  Future<AppUser> registerCaregiver(
    String fullName,
    String email,
    String password, {
    Uint8List? avatarBytes,
    String? avatarExt,
    String? patientCode,
  }) async {
    await _ensureEmailAvailable(email);

    final cleanedCode = patientCode?.trim().toUpperCase();

    if (cleanedCode != null && cleanedCode.isNotEmpty) {
      final patient = await Supabase.instance.client
          .from('profile')
          .select('id')
          .eq('type', 'paciente')
          .eq('linking_code', cleanedCode)
          .maybeSingle();

      if (patient == null) {
        throw Exception('El código del paciente no existe');
      }

      final existingRelation = await Supabase.instance.client
          .from('user_relation')
          .select('profile_id')
          .eq('profile_id', patient['id'])
          .maybeSingle();

      if (existingRelation != null) {
        throw Exception('Este código ya fue vinculado a otro cuidador');
      }
    }

    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'type': 'cuidador'},
    );

    final userId = response.user!.id;

    if (avatarBytes != null && avatarExt != null) {
      try {
        final fileName =
            '$userId-${DateTime.now().millisecondsSinceEpoch}.$avatarExt';

        await Supabase.instance.client.storage
            .from('avatars')
            .uploadBinary(fileName, avatarBytes);

        final avatarUrl = Supabase.instance.client.storage
            .from('avatars')
            .getPublicUrl(fileName);

        await Supabase.instance.client.auth.updateUser(
          UserAttributes(data: {'avatar_url': avatarUrl}),
        );

        await Supabase.instance.client
            .from('profile')
            .update({'avatar_url': avatarUrl})
            .eq('id', userId);
      } catch (_) {
        // Optional avatar: do not block registration if upload fails.
      }
    }

    await _createProfile(
      id: userId,
      fullName: fullName,
      email: email,
      password: password,
      type: 'cuidador',
      caregiver: null,
    );

    if (cleanedCode != null && cleanedCode.isNotEmpty) {
      final patient = await Supabase.instance.client
          .from('profile')
          .select('id')
          .eq('type', 'paciente')
          .eq('linking_code', cleanedCode)
          .single();

      await Supabase.instance.client
          .from('user_relation')
          .insert({
            'profile_id': patient['id'],
            'profile_id1': userId,
          });
    }

    return AppUser(id: userId, email: email, role: 'cuidador');
  }

  Future<void> _createProfile({
    required String id,
    required String fullName,
    required String email,
    required String password,
    required String type,
    String? caregiver,
  }) async {
    await Supabase.instance.client.from('profile').upsert({
      'id': id,
      'full_name': fullName,
      'email': email,
      'password': password,
      'type': type,
      'linking_code': type == 'paciente' ? _resolveLinkingCode(id) : null,
    }, onConflict: 'id');
  }

  String _resolveLinkingCode(String profileId) {
    final digits = profileId.replaceAll(RegExp(r'\D'), '');
    final codeDigits = digits.isEmpty
        ? '0000'
        : digits.length >= 4
        ? digits.substring(0, 4)
        : digits.padLeft(4, '0');
    return 'MED-$codeDigits';
  }

  Future<void> _ensureEmailAvailable(String email) async {
    final existingProfile = await Supabase.instance.client
        .from('profile')
        .select('id')
        .eq('email', email)
        .maybeSingle();

    if (existingProfile != null) {
      throw Exception('Este correo ya está registrado. Usa otro correo o inicia sesión.');
    }
  }
}
