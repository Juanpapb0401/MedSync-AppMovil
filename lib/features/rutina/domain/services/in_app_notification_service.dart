import 'dart:async';
import '../usecases/get_daily_rutina_usecase.dart';
import '../model/rutina_medicamento_model.dart';

class InAppNotificationService {
  final GetDailyRutinaUsecase _getDailyRutinaUsecase;
  
  Timer? _timer;
  final Set<String> _notifiedIds = {};
  final Map<String, DateTime> _nextAlarmTime = {};
  bool _isRunning = false;

  final StreamController<RutinaMedicamentoModel> _notificationController =
      StreamController<RutinaMedicamentoModel>.broadcast();
  final StreamController<RutinaMedicamentoModel> _alarmController =
      StreamController<RutinaMedicamentoModel>.broadcast();

  Stream<RutinaMedicamentoModel> get notificationStream => _notificationController.stream;
  Stream<RutinaMedicamentoModel> get alarmStream => _alarmController.stream;

  InAppNotificationService(this._getDailyRutinaUsecase);

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _checkNotifications(); // Check immediately
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkNotifications();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _notifiedIds.clear();
    _nextAlarmTime.clear();
  }

  void snooze(String notificationId) {
    _nextAlarmTime[notificationId] = DateTime.now().add(const Duration(minutes: 2));
  }

  void clearAlarm(String notificationId) {
    _nextAlarmTime.remove(notificationId);
  }

  Future<void> _checkNotifications() async {
    try {
      final today = DateTime.now();
      // Fetch routine from DB occasionally or directly
      // Since it's every 30 secs, we rely on the cached or direct fetch from the data source
      // For performance in a real app, you'd cache and only refresh on certain actions.
      final routine = await _getDailyRutinaUsecase.execute(today);

      for (final intake in routine) {
        if (!intake.isPending) {
          _nextAlarmTime.remove(intake.notificationId);
          continue;
        }

        final now = DateTime.now();
        final diff = intake.scheduledDateTime.difference(now).inMinutes;
        
        // If exactly 5 minutes remaining and not yet notified (advance notice)
        if (diff == 5 && !_notifiedIds.contains(intake.notificationId)) {
          _notifiedIds.add(intake.notificationId);
          _notificationController.add(intake);
        }

        // Main alarm: scheduled time has arrived or passed
        if (now.isAfter(intake.scheduledDateTime) || now.isAtSameMomentAs(intake.scheduledDateTime)) {
          final nextAlarm = _nextAlarmTime[intake.notificationId];
          if (nextAlarm == null) {
            // Alarm fires for the first time
            // Automatically set the default snooze for the next check to 2 mins from now
            _nextAlarmTime[intake.notificationId] = now.add(const Duration(minutes: 2));
            _alarmController.add(intake);
          } else if (now.isAfter(nextAlarm) || now.isAtSameMomentAs(nextAlarm)) {
            // Snooze time elapsed, fire alarm again
            _nextAlarmTime[intake.notificationId] = now.add(const Duration(minutes: 2));
            _alarmController.add(intake);
          }
        }
      }
    } catch (e) {
      // Ignored: usually no active session or network issue
    }
  }

  void dispose() {
    stop();
    _notificationController.close();
    _alarmController.close();
  }
}

