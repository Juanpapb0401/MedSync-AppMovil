import 'dart:typed_data';
import '../../../profile/domain/model/profile_model.dart';

abstract class AuthRepo {
  Future<ProfileModel> login(String email, String password);
  Future<ProfileModel> registerPatient(
    String fullName,
    String email,
    String password, {
    Uint8List? avatarBytes,
    String? avatarExt,
  });
  Future<ProfileModel> registerCaregiver(
    String fullName,
    String email,
    String password, {
    Uint8List? avatarBytes,
    String? avatarExt,
    String? patientCode,
  });
}
