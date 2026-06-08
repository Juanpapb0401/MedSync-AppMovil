import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:medsync/features/rutina/domain/services/in_app_notification_service.dart';
import 'package:medsync/features/rutina/domain/services/local_notification_service.dart';
import '../../domain/usecases/logout_usecase.dart';

// Events
abstract class LogoutEvent {}

class LogoutRequested extends LogoutEvent {}

// States
abstract class LogoutState {}

class LogoutInitial extends LogoutState {}

class LogoutInProgress extends LogoutState {}

class LogoutSuccess extends LogoutState {}

class LogoutFailure extends LogoutState {
  final String message;
  LogoutFailure(this.message);
}

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final LogoutUsecase _logoutUsecase;
  final LocalNotificationService _localNotificationService;
  final InAppNotificationService _inAppNotificationService;

  LogoutBloc(
    this._logoutUsecase,
    this._localNotificationService,
    this._inAppNotificationService,
  ) : super(LogoutInitial()) {
    on<LogoutRequested>((event, emit) async {
      emit(LogoutInProgress());
      try {
        await _logoutUsecase.execute();
        // Stop notification services and clear any cached rutina / pending OS
        // alarms so the next account starts clean.
        _localNotificationService.stop();
        _inAppNotificationService.stop();
        emit(LogoutSuccess());
      } catch (e) {
        emit(LogoutFailure(e.toString()));
      }
    });
  }
}
