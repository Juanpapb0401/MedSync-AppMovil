import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/model/treatment_list_model.dart';
import '../../domain/usecases/get_treatments_usecase.dart';

abstract class TreatmentsListEvent {}

class LoadTreatmentsEvent extends TreatmentsListEvent {}

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
  final GetTreatmentsUsecase _usecase = GetTreatmentsUsecase();

  TreatmentsListBloc() : super(TreatmentsListInitialState()) {
    on<LoadTreatmentsEvent>((event, emit) async {
      emit(TreatmentsListLoadingState());
      try {
        final result = await _usecase.execute();
        emit(TreatmentsListLoadedState(result));
      } catch (_) {
        emit(TreatmentsListErrorState('No se pudo cargar los tratamientos'));
      }
    });
  }
}