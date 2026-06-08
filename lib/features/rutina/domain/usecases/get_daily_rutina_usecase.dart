import '../model/rutina_medicamento_model.dart';
import '../repo/rutina_repo.dart';

class GetDailyRutinaUsecase {
  final RutinaRepo _repo;

  GetDailyRutinaUsecase(this._repo);

  Future<List<RutinaMedicamentoModel>> execute(DateTime date) => _repo.getDailyRutina(date);
}
