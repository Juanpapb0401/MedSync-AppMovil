import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../model/rutina_medicamento_model.dart';
import '../usecases/get_daily_rutina_usecase.dart';
import '../usecases/watch_today_rutina_usecase.dart';

const _advanceChannelId = 'medsync_advance_notice';
const _alarmChannelId = 'medsync_alarm';

class LocalNotificationService {
  final WatchTodayRutinaUsecase _watchUsecase;
  final GetDailyRutinaUsecase _getDailyUsecase;

  LocalNotificationService(this._watchUsecase, this._getDailyUsecase);

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  GlobalKey<NavigatorState>? _navigatorKey;
  StreamSubscription<List<RutinaMedicamentoModel>>? _subscription;

  // ────────────────────────────────────────────────────────────────────────
  // Public API
  // ────────────────────────────────────────────────────────────────────────

  Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onTap,
    );

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    final iosPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Subscribes to the rutina stream and reschedules OS notifications on
  /// every emission (after confirm, snooze, or lazy daily generation).
  /// Also primes today's rutina so notifications get scheduled even if the
  /// patient never opens the "Mi Rutina" screen.
  void start() {
    _subscription?.cancel();
    _subscription = _watchUsecase.execute().listen(
      _reschedule,
      onError: (_) {},
    );

    // Fire-and-forget: forces creation of today's notification rows and pushes
    // them to the stream, triggering the initial OS scheduling above.
    _getDailyUsecase.execute(DateTime.now()).catchError(
      (_) => <RutinaMedicamentoModel>[],
    );
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _plugin.cancelAll();
  }

  /// Cancels both the advance-notice and alarm OS notifications for a given
  /// notificationId. Called by InAppNotificationService when it fires the
  /// in-app AlarmDialog so the OS notification doesn't appear simultaneously.
  Future<void> cancelOne(String notificationId) async {
    await _plugin.cancel(id: _advanceId(notificationId));
    await _plugin.cancel(id: _alarmId(notificationId));
  }

  // ────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ────────────────────────────────────────────────────────────────────────

  Future<void> _reschedule(List<RutinaMedicamentoModel> items) async {
    await _plugin.cancelAll();
    final nowUtc = DateTime.now().toUtc();

    for (final item in items) {
      if (!item.isPending) continue;
      final scheduledUtc = item.scheduledDateTime.toUtc();

      // Advance notice: 5 min before scheduled time
      final advanceUtc = scheduledUtc.subtract(const Duration(minutes: 5));
      if (advanceUtc.isAfter(nowUtc)) {
        await _scheduleAdvance(item, advanceUtc);
      }

      // Main alarm: at exact scheduled time
      if (scheduledUtc.isAfter(nowUtc)) {
        await _scheduleAlarm(item, scheduledUtc);
      }
    }
  }

  Future<void> _scheduleAdvance(
    RutinaMedicamentoModel item,
    DateTime whenUtc,
  ) async {
    await _plugin.zonedSchedule(
      id: _advanceId(item.notificationId),
      title: 'Recordatorio de medicamento',
      body: 'En 5 minutos debes tomar ${item.medicineName}',
      scheduledDate: tz.TZDateTime.from(whenUtc, tz.UTC),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _advanceChannelId,
          'Aviso previo de toma',
          channelDescription: 'Aviso 5 minutos antes de la hora de toma',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: _payload(item),
    );
  }

  Future<void> _scheduleAlarm(
    RutinaMedicamentoModel item,
    DateTime whenUtc,
  ) async {
    await _plugin.zonedSchedule(
      id: _alarmId(item.notificationId),
      title: '¡Hora de tu medicamento!',
      body:
          'Es hora de tomar ${item.medicineName} — ${item.dose} ${item.unit}',
      scheduledDate: tz.TZDateTime.from(whenUtc, tz.UTC),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _alarmChannelId,
          'Alarma de toma',
          channelDescription: 'Alarma sonora a la hora exacta de la toma',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          fullScreenIntent: true,
          autoCancel: false,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: _payload(item),
    );
  }

  void _onTap(NotificationResponse response) {
    final raw = response.payload;
    if (raw == null) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final medicamento = RutinaMedicamentoModel(
        notificationId: data['notificationId'] as String,
        medicineName: data['medicineName'] as String,
        dose: data['dose'] as String,
        unit: data['unit'] as String,
        scheduledDateTime: DateTime.parse(data['scheduledDateTime'] as String),
        status: data['status'] as String,
        restrictions: (data['restrictions'] as List).cast<String>(),
      );
      _navigatorKey?.currentState?.pushNamed(
        '/rutina/confirmar-toma',
        arguments: {
          'medicamento': medicamento,
          'currentDate': DateTime.now(),
        },
      );
    } catch (_) {}
  }

  String _payload(RutinaMedicamentoModel item) => jsonEncode({
    'notificationId': item.notificationId,
    'medicineName': item.medicineName,
    'dose': item.dose,
    'unit': item.unit,
    'scheduledDateTime': item.scheduledDateTime.toIso8601String(),
    'status': item.status,
    'restrictions': item.restrictions,
  });

  int _advanceId(String uuid) => '${uuid}a'.hashCode.abs();
  int _alarmId(String uuid) => '${uuid}b'.hashCode.abs();
}
