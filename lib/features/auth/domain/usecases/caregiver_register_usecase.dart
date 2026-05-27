import 'dart:typed_data';

import '../../../profile/domain/model/profile_model.dart';
import '../repo/auth_repo.dart';

class CaregiverRegisterUsecase {
  final AuthRepo _repo;

  CaregiverRegisterUsecase(this._repo);

  Future<ProfileModel> execute(
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