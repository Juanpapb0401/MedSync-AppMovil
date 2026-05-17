import 'dart:typed_data';
import '../../../profile/domain/model/profile_model.dart';
import '../../domain/repo/auth_repo.dart';
import '../sources/auth_data_source.dart';

class AuthRepoImpl extends AuthRepo {
  final AuthDataSource _source = AuthDataSource();

  @override
  Future<ProfileModel> login(String email, String password) {
    return _source.login(email, password);
  }

  @override
  Future<ProfileModel> registerPatient(
    String fullName,
    String email,
    String password, {
    Uint8List? avatarBytes,
    String? avatarExt,
  }) {
    return _source.registerPatient(
      fullName,
      email,
      password,
      avatarBytes: avatarBytes,
      avatarExt: avatarExt,
    );
  }

  @override
  Future<ProfileModel> registerCaregiver(
    String fullName,
    String email,
    String password, {
    Uint8List? avatarBytes,
    String? avatarExt,
    String? patientCode,
  }) {
    return _source.registerCaregiver(
      fullName,
      email,
      password,
      avatarBytes: avatarBytes,
      avatarExt: avatarExt,
      patientCode: patientCode,
    );
  }
}
