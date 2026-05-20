import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../profile/domain/utils/linking_code_generator.dart';

class GetLinkingCodeDataSource {
  final _client = Supabase.instance.client;

  Future<String> execute() async {
    final authUser = _client.auth.currentSession?.user;
    if (authUser == null) throw Exception('No active session');

    final data = await _client
        .from('profile')
        .select('id, type, linking_code')
        .eq('email', authUser.email!)
        .single();

    final profileId = data['id'] as String;
    final type = data['type'] as String;
    final storedLinkingCode = data['linking_code'] as String?;

    if (type != 'paciente') {
      throw Exception('El usuario no es un paciente');
    }

    return LinkingCodeGenerator.resolve(profileId, storedLinkingCode);
  }
}