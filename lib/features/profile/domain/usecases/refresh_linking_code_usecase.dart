import '../repo/profile_repo.dart';

class RefreshLinkingCodeUsecase {
  final ProfileRepo _repo;

  RefreshLinkingCodeUsecase(this._repo);

  Future<void> execute() async {
    await _repo.refreshLinkingCodeIfNeeded();
  }
}