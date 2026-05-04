import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/domain/model/app_user.dart';

class AuthDataSource {
  Future<AppUser> login(String email, String password) async {
    // 1. Delegar siempre la seguridad del login a Supabase Auth
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final userId = response.user!.id;

    // 2. Traer la metainformación desde nuestra tabla profile
    final profile = await Supabase.instance.client
        .from('profile')
        .select('type')
        .eq('id', userId)
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
    // 1. Usar Supabase Auth para crear el usuario para manejar tokens jwt/sesiones
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );

    final userId = response.user!.id;
    String? avatarUrl;

    // 2. Hashear el password manualmente si lo vamos a enviar a la tabla profile para respetar tu solicitud
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    // Como tu db dice VARCHAR(30), tomamos un substring para que encaje, o idealmente deberías ponerlo en VARCHAR(255)
    final hashedPassword = digest.toString().substring(0, 30); 

    if (avatarBytes != null && avatarExt != null) {
      try {
        final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$avatarExt';

        await Supabase.instance.client.storage
            .from('avatars')
            .uploadBinary(fileName, avatarBytes);

        avatarUrl = Supabase.instance.client.storage
            .from('avatars')
            .getPublicUrl(fileName);
      } catch (e) {
        // Falló upload imagen
      }
    }

    // 3. EXPLICITAMENTE insertamos el perfil en tu DB para que no falle y aparezca el paciente en Supabase 
    await Supabase.instance.client.from('profile').insert({
      'id': userId, 
      'full_name': fullName,
      'email': email,
      'password': hashedPassword,
      'type': 'paciente',
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    });

    return AppUser(id: userId, email: email, role: 'paciente');
  }
}
