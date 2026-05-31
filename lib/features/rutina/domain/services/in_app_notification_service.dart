import 'dart:async';
import '../usecases/get_daily_rutina_usecase.dart';
import '../model/rutina_medicamento_model.dart';

class InAppNotificationService {
  final GetDailyRutinaUsecase _getDailyRutinaUsecase;
  
  Timer? _timer;
  final Set<String> _notifiedIds = {};
  bool _isRunning = false;

  final StreamController<RutinaMedicamentoModel> _notificationController =
      StreamController<RutinaMedicamentoModel>.broadcast();

  Stream<RutinaMedicamentoModel> get notificationStream => _notificationController.stream;

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
  }

  Future<void> _checkNotifications() async {
    try {
      final today = DateTime.now();
      // Fetch routine from DB occasionally or directly
      // Since it's every 30 secs, we rely on the cached or direct fetch from the data source
      // For performance in a real app, you'd cache and only refresh on certain actions.
      final routine = await _getDailyRutinaUsecase.execute(today);

      for (final intake in routine) {
        if (!intake.isPending) continue;

        final diff = intake.scheduledDateTime.difference(DateTime.now()).inMinutes;
        
        // If exactly 5 minutes remaining and not yet notified
        if (diff == 5 && !_notifiedIds.contains(intake.notificationId)) {
          _notifiedIds.add(intake.notificationId);
          _notificationController.add(intake);
        }
      }
    } catch (e) {
      // Ignored: usually no active session or network issue
    }
  }

  void dispose() {
    stop();
    _notificationController.close();
  }
}
