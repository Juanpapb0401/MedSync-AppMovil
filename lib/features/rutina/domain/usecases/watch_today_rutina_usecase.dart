import '../model/rutina_medicamento_model.dart';
import '../repo/rutina_repo.dart';

class WatchTodayRutinaUsecase {
  final RutinaRepo _repo;

  WatchTodayRutinaUsecase(this._repo);

  Stream<List<RutinaMedicamentoModel>> execute() => _repo.todayRutinaStream;
}
