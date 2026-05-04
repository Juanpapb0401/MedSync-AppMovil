import '../../domain/model/profile_model.dart';
import '../../domain/repo/profile_repo.dart';
import '../sources/profile_data_source.dart';

class ProfileRepoImpl implements ProfileRepo {
  final _source = ProfileDataSource();

  @override
  Future<ProfileModel> getProfile() => _source.getProfile();
}
