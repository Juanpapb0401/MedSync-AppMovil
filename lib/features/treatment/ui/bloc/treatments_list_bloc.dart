import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/model/treatment_list_model.dart';
import '../../domain/usecases/delete_treatment_usecase.dart';
import '../../domain/usecases/get_treatments_usecase.dart';

abstract class TreatmentsListEvent {}

class LoadTreatmentsEvent extends TreatmentsListEvent {}

class DeleteTreatmentEvent extends TreatmentsListEvent {
  final String treatmentId;
  final String medicineName;
  final String patientName;

  DeleteTreatmentEvent({
    required this.treatmentId,
    required this.medicineName,
    required this.patientName,
  });
}

abstract class TreatmentsListState {}

class TreatmentsListInitialState extends TreatmentsListState {}

class TreatmentsListLoadingState extends TreatmentsListState {}

class TreatmentsListLoadedState extends TreatmentsListState {
  final TreatmentListResultModel result;

  TreatmentsListLoadedState(this.result);
}

class TreatmentsListErrorState extends TreatmentsListState {
  final String message;

  TreatmentsListErrorState(this.message);
}

class TreatmentsListBloc extends Bloc<TreatmentsListEvent, TreatmentsListState> {
  final GetTreatmentsUsecase _treatmentsUsecase;
  final DeleteTreatmentUsecase _deleteUsecase;

  TreatmentsListBloc(this._treatmentsUsecase, this._deleteUsecase) : super(TreatmentsListInitialState()) {
    on<LoadTreatmentsEvent>((event, emit) async {
      emit(TreatmentsListLoadingState());
      try {
        final result = await _treatmentsUsecase.execute();
        emit(TreatmentsListLoadedState(result));
      } catch (_) {
        emit(TreatmentsListErrorState('No se pudo cargar los tratamientos'));
      }
    });

    on<DeleteTreatmentEvent>((event, emit) async {
      try {
        await _deleteUsecase.execute(event.treatmentId);
        final result = await _treatmentsUsecase.execute();
        emit(TreatmentsListLoadedState(result));
      } catch (_) {
        emit(TreatmentsListErrorState('No se pudo eliminar el tratamiento'));
      }
    });
  }
}
