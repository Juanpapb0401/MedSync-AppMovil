import 'dart:typed_data';
import '../../../../core/domain/model/app_user.dart';

abstract class AuthRepo {
  Future<AppUser> login(String email, String password);
  Future<AppUser> registerPatient(
    String fullName,
    String email,
    String password, {
    Uint8List? avatarBytes,
    String? avatarExt,
  });
  Future<AppUser> registerCaregiver(
    String fullName,
    String email,
    String password, {
    Uint8List? avatarBytes,
    String? avatarExt,
    String? patientCode,
  });
}
