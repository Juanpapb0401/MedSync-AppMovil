import '../repo/rutina_repo.dart';

class UpdateIntakeStatusUsecase {
  final RutinaRepo _repo;

  UpdateIntakeStatusUsecase(this._repo);

  Future<void> execute(String notificationId, String newStatus) => 
      _repo.updateIntakeStatus(notificationId, newStatus);
}
