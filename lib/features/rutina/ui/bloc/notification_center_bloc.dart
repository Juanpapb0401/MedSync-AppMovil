import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medsync/features/rutina/domain/model/rutina_medicamento_model.dart';
import 'package:medsync/features/rutina/domain/services/in_app_notification_service.dart';

// Events
abstract class NotificationCenterEvent {}

class NotificationReceived extends NotificationCenterEvent {
  final RutinaMedicamentoModel intake;
  NotificationReceived(this.intake);
}

class RemoveNotification extends NotificationCenterEvent {
  final String id;
  RemoveNotification(this.id);
}

class ClearAllNotifications extends NotificationCenterEvent {}

// State
class NotificationCenterState {
  final List<RutinaMedicamentoModel> notifications;
  NotificationCenterState({this.notifications = const []});
}

// Bloc
class NotificationCenterBloc
    extends Bloc<NotificationCenterEvent, NotificationCenterState> {
  final InAppNotificationService _notificationService;
  late final StreamSubscription<RutinaMedicamentoModel> _subscription;

  NotificationCenterBloc(this._notificationService)
      : super(NotificationCenterState()) {
    on<NotificationReceived>((event, emit) {
      final exists = state.notifications
          .any((n) => n.notificationId == event.intake.notificationId);
      if (exists) return;
      final updatedList =
          List<RutinaMedicamentoModel>.from(state.notifications)
            ..insert(0, event.intake);
      emit(NotificationCenterState(notifications: updatedList));
    });

    on<RemoveNotification>((event, emit) {
      final updatedList = state.notifications
          .where((n) => n.notificationId != event.id)
          .toList();
      emit(NotificationCenterState(notifications: updatedList));
    });

    on<ClearAllNotifications>((event, emit) {
      emit(NotificationCenterState());
    });

    // Forward each in-app notification into the bloc as an event.
    _subscription = _notificationService.notificationStream
        .listen((intake) => add(NotificationReceived(intake)));
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
