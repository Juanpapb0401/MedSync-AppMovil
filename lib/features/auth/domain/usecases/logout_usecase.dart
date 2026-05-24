import '../repo/logout_repo.dart';

class LogoutUsecase {
  final LogoutRepo _repo;
  LogoutUsecase(this._repo);

  Future<void> execute() => _repo.logout();
}