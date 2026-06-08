import '../../domain/model/rutina_medicamento_model.dart';
import '../../domain/repo/rutina_repo.dart';
import '../sources/rutina_data_source.dart';

class RutinaRepoImpl implements RutinaRepo {
  final RutinaDataSource _dataSource;

  RutinaRepoImpl(this._dataSource);

  @override
  Future<List<RutinaMedicamentoModel>> getDailyRutina(DateTime date) {
    return _dataSource.getDailyRutina(date);
  }

  @override
  Future<void> updateIntakeStatus(String notificationId, String newStatus) {
    return _dataSource.updateIntakeStatus(notificationId, newStatus);
  }

  @override
  Future<String> remindLater(String notificationId) {
    return _dataSource.remindLater(notificationId);
  }

  @override
  Stream<List<RutinaMedicamentoModel>> get todayRutinaStream =>
      _dataSource.todayRutinaStream;
}
