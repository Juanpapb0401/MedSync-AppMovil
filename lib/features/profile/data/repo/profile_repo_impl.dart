import '../../domain/model/profile_model.dart';
import '../../domain/repo/profile_repo.dart';
import '../sources/profile_data_source.dart';

class ProfileRepoImpl implements ProfileRepo {
  final ProfileDataSource _source;

  ProfileRepoImpl(this._source);

  @override
  Future<ProfileModel> getProfile() => _source.getProfile();

  @override
  Future<void> linkPatientToCaregiver(String patientCode) {
    return _source.linkPatientToCaregiver(patientCode);
  }

  @override
  Future<void> refreshLinkingCodeIfNeeded() {
    return _source.refreshLinkingCodeIfNeeded();
  }
}
