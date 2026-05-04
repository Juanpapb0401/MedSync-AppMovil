import 'dart:typed_data';

import '../../../../core/domain/model/app_user.dart';
import '../repo/auth_repo.dart';
import '../../data/repo/auth_repo_impl.dart';

class CaregiverRegisterUsecase {
  final AuthRepo _repo = AuthRepoImpl();

  Future<AppUser> execute(
    String fullName,
    String email,
    String password, {
    Uint8List? avatarBytes,
    String? avatarExt,
    String? patientCode,
  }) {
    return _repo.registerCaregiver(
      fullName,
      email,
      password,
      avatarBytes: avatarBytes,
      avatarExt: avatarExt,
      patientCode: patientCode,
    );
  }
}