import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/model/treatment_summary_model.dart';
import '../../domain/usecases/get_treatment_summary_usecase.dart';
import '../../data/repo/treatment_repo_impl.dart';

// Events
abstract class TreatmentSummaryEvent {}

class LoadTreatmentSummaryEvent extends TreatmentSummaryEvent {}

// States
abstract class TreatmentSummaryState {}

class TreatmentSummaryInitialState extends TreatmentSummaryState {}

class TreatmentSummaryLoadingState extends TreatmentSummaryState {}

class TreatmentSummaryLoadedState extends TreatmentSummaryState {
  final TreatmentSummaryModel summary;
  TreatmentSummaryLoadedState(this.summary);
}

class TreatmentSummaryErrorState extends TreatmentSummaryState {
  final String message;
  TreatmentSummaryErrorState(this.message);
}

// BLoC
class TreatmentSummaryBloc
    extends Bloc<TreatmentSummaryEvent, TreatmentSummaryState> {
  final GetTreatmentSummaryUsecase _usecase = GetTreatmentSummaryUsecase(
    TreatmentRepoImpl(),
  );

  TreatmentSummaryBloc() : super(TreatmentSummaryInitialState()) {
    on<LoadTreatmentSummaryEvent>((event, emit) async {
      emit(TreatmentSummaryLoadingState());
      try {
        final summary = await _usecase.execute();
        emit(TreatmentSummaryLoadedState(summary));
      } catch (_) {
        emit(TreatmentSummaryErrorState('No se pudo cargar los tratamientos'));
      }
    });
  }
}