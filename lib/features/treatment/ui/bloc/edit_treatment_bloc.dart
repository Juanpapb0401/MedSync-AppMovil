import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/model/treatment_model.dart';
import '../../domain/usecases/update_treatment_usecase.dart';

abstract class EditTreatmentEvent {}

class EditUpdateMedicineName extends EditTreatmentEvent {
  final String name;
  EditUpdateMedicineName(this.name);
}

class EditUpdateDose extends EditTreatmentEvent {
  final String dose;
  EditUpdateDose(this.dose);
}

class EditUpdateUnit extends EditTreatmentEvent {
  final String unit;
  EditUpdateUnit(this.unit);
}

class EditUpdateFrequency extends EditTreatmentEvent {
  final String frequency;
  EditUpdateFrequency(this.frequency);
}

class EditUpdateStartTime extends EditTreatmentEvent {
  final String startTime;
  EditUpdateStartTime(this.startTime);
}

class EditAddRestriction extends EditTreatmentEvent {
  final String restriction;
  EditAddRestriction(this.restriction);
}

class EditRemoveRestriction extends EditTreatmentEvent {
  final String restriction;
  EditRemoveRestriction(this.restriction);
}

class EditSaveRequested extends EditTreatmentEvent {}

class EditTreatmentState {
  final String medicineName;
  final String dose;
  final String unit;
  final String frequency;
  final String startTime;
  final List<String> restrictions;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  EditTreatmentState({
    this.medicineName = '',
    this.dose = '',
    this.unit = 'mg',
    this.frequency = 'Cada 8h',
    this.startTime = '',
    this.restrictions = const [],
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  EditTreatmentState copyWith({
    String? medicineName,
    String? dose,
    String? unit,
    String? frequency,
    String? startTime,
    List<String>? restrictions,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return EditTreatmentState(
      medicineName: medicineName ?? this.medicineName,
      dose: dose ?? this.dose,
      unit: unit ?? this.unit,
      frequency: frequency ?? this.frequency,
      startTime: startTime ?? this.startTime,
      restrictions: restrictions ?? this.restrictions,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }
}

class EditTreatmentBloc extends Bloc<EditTreatmentEvent, EditTreatmentState> {
  final UpdateTreatmentUsecase _usecase;
  final String _treatmentId;

  EditTreatmentBloc(this._usecase, this._treatmentId, TreatmentModel initial)
      : super(EditTreatmentState(
          medicineName: initial.medicineName,
          dose: initial.dose,
          unit: initial.unit,
          frequency: initial.frequency,
          startTime: initial.startTime,
          restrictions: List.from(initial.restrictions),
        )) {
    on<EditUpdateMedicineName>((event, emit) => emit(state.copyWith(medicineName: event.name)));
    on<EditUpdateDose>((event, emit) => emit(state.copyWith(dose: event.dose)));
    on<EditUpdateUnit>((event, emit) => emit(state.copyWith(unit: event.unit)));
    on<EditUpdateFrequency>((event, emit) => emit(state.copyWith(frequency: event.frequency)));
    on<EditUpdateStartTime>((event, emit) => emit(state.copyWith(startTime: event.startTime)));

    on<EditAddRestriction>((event, emit) {
      if (!state.restrictions.contains(event.restriction)) {
        emit(state.copyWith(restrictions: [...state.restrictions, event.restriction]));
      }
    });

    on<EditRemoveRestriction>((event, emit) {
      emit(state.copyWith(
        restrictions: state.restrictions.where((r) => r != event.restriction).toList(),
      ));
    });

    on<EditSaveRequested>((event, emit) async {
      if (state.medicineName.isEmpty || state.dose.isEmpty || state.startTime.isEmpty) {
        emit(state.copyWith(errorMessage: 'Por favor, completa todos los campos obligatorios.'));
        return;
      }

      emit(state.copyWith(isLoading: true, errorMessage: null));

      try {
        final treatment = TreatmentModel(
          medicineName: state.medicineName,
          dose: state.dose,
          unit: state.unit,
          frequency: state.frequency,
          startTime: state.startTime,
          restrictions: state.restrictions,
        );

        await _usecase.execute(_treatmentId, treatment);
        emit(state.copyWith(isLoading: false, isSuccess: true));
      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'No se pudo actualizar el tratamiento: ${e.toString()}',
        ));
      }
    });
  }
}
