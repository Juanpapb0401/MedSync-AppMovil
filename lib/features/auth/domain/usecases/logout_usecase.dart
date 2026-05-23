import 'package:supabase_flutter/supabase_flutter.dart';

class LogoutUsecase {
  Future<void> execute() async {
    await Supabase.instance.client.auth.signOut();
  }
}