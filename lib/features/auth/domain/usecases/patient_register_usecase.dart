import 'dart:typed_data';
import '../../../../core/domain/model/app_user.dart';
import '../repo/auth_repo.dart';
import '../../data/repo/auth_repo_impl.dart';

class PatientRegisterUsecase {
  final AuthRepo _repo = AuthRepoImpl();

  Future<AppUser> execute(
    String fullName,
    String email,
    String password, {
    Uint8List? avatarBytes,
    String? avatarExt,
  }) {
    return _repo.registerPatient(fullName, email, password, avatarBytes: avatarBytes, avatarExt: avatarExt);
  }
}
