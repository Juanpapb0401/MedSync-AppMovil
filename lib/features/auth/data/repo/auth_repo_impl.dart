import 'dart:typed_data';
import '../../../../core/domain/model/app_user.dart';
import '../../domain/repo/auth_repo.dart';
import '../sources/auth_data_source.dart';

class AuthRepoImpl extends AuthRepo {
  final AuthDataSource _source = AuthDataSource();

  @override
  Future<AppUser> login(String email, String password) {
    return _source.login(email, password);
  }

  @override
  Future<AppUser> registerPatient(
    String fullName,
    String email,
    String password, {
    Uint8List? avatarBytes,
    String? avatarExt,
  }) {
    return _source.registerPatient(fullName, email, password, avatarBytes: avatarBytes, avatarExt: avatarExt);
  }
}
