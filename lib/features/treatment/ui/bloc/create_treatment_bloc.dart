import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/model/treatment_model.dart';
import '../../data/repo/treatment_repo_impl.dart';

// Events
abstract class CreateTreatmentEvent {}

class UpdateMedicineName extends CreateTreatmentEvent {
  final String name;
  UpdateMedicineName(this.name);
}

class UpdateDose extends CreateTreatmentEvent {
  final String dose;
  UpdateDose(this.dose);
}

class UpdateUnit extends CreateTreatmentEvent {
  final String unit;
  UpdateUnit(this.unit);
}

class UpdateFrequency extends CreateTreatmentEvent {
  final String frequency;
  UpdateFrequency(this.frequency);
}

class UpdateStartTime extends CreateTreatmentEvent {
  final String startTime;
  UpdateStartTime(this.startTime);
}

class AddRestriction extends CreateTreatmentEvent {
  final String restriction;
  AddRestriction(this.restriction);
}

class RemoveRestriction extends CreateTreatmentEvent {
  final String restriction;
  RemoveRestriction(this.restriction);
}

class SaveTreatmentRequested extends CreateTreatmentEvent {}

// States
class CreateTreatmentState {
  final String medicineName;
  final String dose;
  final String unit;
  final String frequency;
  final String startTime;
  final List<String> restrictions;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  CreateTreatmentState({
    this.medicineName = '',
    this.dose = '',
    this.unit = 'mg',
    this.frequency = 'Cada 8 horas',
    this.startTime = '',
    this.restrictions = const [],
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  CreateTreatmentState copyWith({
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
    return CreateTreatmentState(
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

// Bloc
class CreateTreatmentBloc extends Bloc<CreateTreatmentEvent, CreateTreatmentState> {
  final _repo = TreatmentRepoImpl();

  CreateTreatmentBloc() : super(CreateTreatmentState()) {
    on<UpdateMedicineName>((event, emit) => emit(state.copyWith(medicineName: event.name)));
    on<UpdateDose>((event, emit) => emit(state.copyWith(dose: event.dose)));
    on<UpdateUnit>((event, emit) => emit(state.copyWith(unit: event.unit)));
    on<UpdateFrequency>((event, emit) => emit(state.copyWith(frequency: event.frequency)));
    on<UpdateStartTime>((event, emit) => emit(state.copyWith(startTime: event.startTime)));
    
    on<AddRestriction>((event, emit) {
      if (!state.restrictions.contains(event.restriction)) {
        emit(state.copyWith(restrictions: [...state.restrictions, event.restriction]));
      }
    });

    on<RemoveRestriction>((event, emit) {
      emit(state.copyWith(
        restrictions: state.restrictions.where((r) => r != event.restriction).toList(),
      ));
    });

    on<SaveTreatmentRequested>((event, emit) async {
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
        
        await _repo.saveTreatment(treatment);
        emit(state.copyWith(isLoading: false, isSuccess: true));
      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Error al guardar: ${e.toString()}',
        ));
      }
    });
  }
}
