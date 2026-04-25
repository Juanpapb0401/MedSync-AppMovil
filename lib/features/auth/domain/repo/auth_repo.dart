import '../../../../core/domain/model/app_user.dart';

abstract class AuthRepo {
  Future<AppUser> login(String email, String password);
}
