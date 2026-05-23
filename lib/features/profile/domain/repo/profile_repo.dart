import '../model/profile_model.dart';

abstract class ProfileRepo {
  Future<ProfileModel> getProfile();
  Future<void> linkPatientToCaregiver(String patientCode);
  Future<void> refreshLinkingCodeIfNeeded();
}
