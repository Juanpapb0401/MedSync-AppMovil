import 'dart:async';
import '../model/rutina_medicamento_model.dart';
import '../usecases/watch_today_rutina_usecase.dart';

class InAppNotificationService {
  final WatchTodayRutinaUsecase _watchTodayRutinaUsecase;

  Timer? _timer;
  StreamSubscription<List<RutinaMedicamentoModel>>? _rutinaSubscription;
  List<RutinaMedicamentoModel> _cachedRutina = [];

  final Set<String> _notifiedIds = {};
  final Map<String, DateTime> _nextAlarmTime = {};
  bool _isRunning = false;

  final StreamController<RutinaMedicamentoModel> _notificationController =
      StreamController<RutinaMedicamentoModel>.broadcast();
  final StreamController<RutinaMedicamentoModel> _alarmController =
      StreamController<RutinaMedicamentoModel>.broadcast();

  Stream<RutinaMedicamentoModel> get notificationStream =>
      _notificationController.stream;
  Stream<RutinaMedicamentoModel> get alarmStream => _alarmController.stream;

  InAppNotificationService(this._watchTodayRutinaUsecase);

  void start() {
    if (_isRunning) return;
    _isRunning = true;

    // Subscribe to RutinaDataSource stream — cache is updated reactively on every
    // write (confirmation, snooze, lazy generation from getDailyRutina).
    _rutinaSubscription = _watchTodayRutinaUsecase.execute().listen(
      (rutina) {
        _cachedRutina = rutina;
        _checkAlarms();
      },
      onError: (_) {},
    );

    // Periodic timer only evaluates alarm times against the in-memory cache.
    // No DB queries happen here.
    _checkAlarms();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _checkAlarms());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _rutinaSubscription?.cancel();
    _rutinaSubscription = null;
    _cachedRutina = [];
    _isRunning = false;
    _notifiedIds.clear();
    _nextAlarmTime.clear();
  }

  void snooze(String notificationId) {
    _nextAlarmTime[notificationId] =
        DateTime.now().add(const Duration(minutes: 2));
  }

  void clearAlarm(String notificationId) {
    _nextAlarmTime.remove(notificationId);
  }

  void _checkAlarms() {
    for (final intake in _cachedRutina) {
      if (!intake.isPending) {
        _nextAlarmTime.remove(intake.notificationId);
        continue;
      }

      final now = DateTime.now();
      final diff = intake.scheduledDateTime.difference(now).inMinutes;

      if (diff == 5 && !_notifiedIds.contains(intake.notificationId)) {
        _notifiedIds.add(intake.notificationId);
        _notificationController.add(intake);
      }

      if (now.isAfter(intake.scheduledDateTime) ||
          now.isAtSameMomentAs(intake.scheduledDateTime)) {
        final nextAlarm = _nextAlarmTime[intake.notificationId];
        if (nextAlarm == null) {
          _nextAlarmTime[intake.notificationId] =
              now.add(const Duration(minutes: 2));
          _alarmController.add(intake);
        } else if (now.isAfter(nextAlarm) ||
            now.isAtSameMomentAs(nextAlarm)) {
          _nextAlarmTime[intake.notificationId] =
              now.add(const Duration(minutes: 2));
          _alarmController.add(intake);
        }
      }
    }
  }

  void dispose() {
    stop();
    _notificationController.close();
    _alarmController.close();
  }
}
