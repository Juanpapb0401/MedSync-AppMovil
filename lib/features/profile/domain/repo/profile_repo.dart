import '../model/profile_model.dart';

abstract class ProfileRepo {
  Future<ProfileModel> getProfile();
}
