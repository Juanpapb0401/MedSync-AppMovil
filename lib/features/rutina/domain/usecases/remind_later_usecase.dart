import '../repo/rutina_repo.dart';

class RemindLaterUsecase {
  final RutinaRepo _repo;

  RemindLaterUsecase(this._repo);

  Future<String> execute(String notificationId) =>
      _repo.remindLater(notificationId);
}
