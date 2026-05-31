import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medsync/features/rutina/domain/model/rutina_medicamento_model.dart';
import 'package:medsync/features/rutina/domain/services/in_app_notification_service.dart';

class NotificationCenterState {
  final List<RutinaMedicamentoModel> notifications;
  NotificationCenterState({this.notifications = const []});
}

class NotificationCenterCubit extends Cubit<NotificationCenterState> {
  final InAppNotificationService _notificationService;
  late final StreamSubscription<RutinaMedicamentoModel> _subscription;

  NotificationCenterCubit(this._notificationService) : super(NotificationCenterState()) {
    _subscription = _notificationService.notificationStream.listen((intake) {
      // Avoid inserting duplicates
      final exists = state.notifications.any((n) => n.notificationId == intake.notificationId);
      if (!exists) {
        final updatedList = List<RutinaMedicamentoModel>.from(state.notifications)
          ..insert(0, intake);
        emit(NotificationCenterState(notifications: updatedList));
      }
    });
  }

  void removeNotification(String id) {
    final updatedList = state.notifications.where((n) => n.notificationId != id).toList();
    emit(NotificationCenterState(notifications: updatedList));
  }

  void clearAll() {
    emit(NotificationCenterState(notifications: []));
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
