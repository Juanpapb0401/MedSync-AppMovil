import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/model/rutina_medicamento_model.dart';
import '../../domain/usecases/get_daily_rutina_usecase.dart';
import '../../domain/usecases/remind_later_usecase.dart';
import '../../domain/usecases/update_intake_status_usecase.dart';
import '../../../profile/domain/usecases/get_profile_usecase.dart';

// Events
abstract class RutinaEvent {}

class LoadRutinaEvent extends RutinaEvent {
  final DateTime date;
  LoadRutinaEvent(this.date);
}

class UpdateStatusEvent extends RutinaEvent {
  final String notificationId;
  final String newStatus;
  final DateTime date;

  UpdateStatusEvent({
    required this.notificationId,
    required this.newStatus,
    required this.date,
  });
}

class RemindLaterEvent extends RutinaEvent {
  final String notificationId;
  final DateTime date;

  RemindLaterEvent({
    required this.notificationId,
    required this.date,
  });
}

// States
abstract class RutinaState {}

class RutinaInitialState extends RutinaState {}

class RutinaLoadingState extends RutinaState {}

class RutinaLoadedState extends RutinaState {
  final String patientName;
  final List<RutinaMedicamentoModel> routine;
  final DateTime currentDate;

  RutinaLoadedState({
    required this.patientName,
    required this.routine,
    required this.currentDate,
  });
}

class RutinaErrorState extends RutinaState {
  final String message;
  RutinaErrorState(this.message);
}

// BLoC
class RutinaBloc extends Bloc<RutinaEvent, RutinaState> {
  final GetDailyRutinaUsecase _getDailyRutinaUsecase;
  final UpdateIntakeStatusUsecase _updateIntakeStatusUsecase;
  final RemindLaterUsecase _remindLaterUsecase;
  final GetProfileUsecase _getProfileUsecase;

  RutinaBloc(
    this._getDailyRutinaUsecase,
    this._updateIntakeStatusUsecase,
    this._remindLaterUsecase,
    this._getProfileUsecase,
  ) : super(RutinaInitialState()) {
    on<LoadRutinaEvent>((event, emit) async {
      emit(RutinaLoadingState());
      try {
        final profile = await _getProfileUsecase.execute();
        final patientName = profile.fullName;

        final routine = await _getDailyRutinaUsecase.execute(event.date);

        // Sort chronologically by scheduled time
        routine.sort(
          (a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime),
        );

        emit(
          RutinaLoadedState(
            patientName: patientName,
            routine: routine,
            currentDate: event.date,
          ),
        );
      } catch (e) {
        emit(
          RutinaErrorState('No se pudo cargar tu rutina. Intenta de nuevo.'),
        );
      }
    });

    on<UpdateStatusEvent>((event, emit) async {
      // Best-effort optimistic UI state could be implemented, but simple load works perfectly here.
      try {
        await _updateIntakeStatusUsecase.execute(
          event.notificationId,
          event.newStatus,
        );

        // Re-load the routine data
        final profile = await _getProfileUsecase.execute();
        final patientName = profile.fullName;
        final routine = await _getDailyRutinaUsecase.execute(event.date);

        routine.sort(
          (a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime),
        );

        emit(
          RutinaLoadedState(
            patientName: patientName,
            routine: routine,
            currentDate: event.date,
          ),
        );
      } catch (_) {
        emit(
          RutinaErrorState('No se pudo actualizar el estado del medicamento.'),
        );
      }
    });

    on<RemindLaterEvent>((event, emit) async {
      try {
        final newStatus = await _remindLaterUsecase.execute(
          event.notificationId,
        );

        if (newStatus == 'sin_confirmar') {
          final profile = await _getProfileUsecase.execute();
          final patientName = profile.fullName;
          final routine = await _getDailyRutinaUsecase.execute(event.date);

          routine.sort(
            (a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime),
          );

          emit(
            RutinaLoadedState(
              patientName: patientName,
              routine: routine,
              currentDate: event.date,
            ),
          );
        }
      } catch (_) {
        emit(
          RutinaErrorState('No se pudo procesar el recordatorio.'),
        );
      }
    });
  }
}
