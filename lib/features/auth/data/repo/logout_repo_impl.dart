import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repo/logout_repo.dart';

class LogoutRepoImpl implements LogoutRepo {
  @override
  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
  }
}
