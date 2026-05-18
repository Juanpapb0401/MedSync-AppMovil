import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/model/daily_summary_model.dart';
import '../../domain/usecases/get_daily_summary_usecase.dart';

abstract class DashboardEvent {}

class DashboardLoadData extends DashboardEvent {}

class DashboardPreviousDay extends DashboardEvent {}

class DashboardNextDay extends DashboardEvent {}

class DashboardDateChanged extends DashboardEvent {
  final DateTime date;
  DashboardDateChanged(this.date);
}

class DashboardState {
  final DateTime selectedDate;
  final bool isLoading;
  final DailySummaryModel? summary;
  final String? error;

  const DashboardState({
    required this.selectedDate,
    this.isLoading = false,
    this.summary,
    this.error,
  });

  DashboardState copyWith({
    DateTime? selectedDate,
    bool? isLoading,
    DailySummaryModel? summary,
    String? error,
  }) {
    return DashboardState(
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
      error: error ?? this.error,
    );
  }
}

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final _usecase = GetDailySummaryUsecase();

  DashboardBloc()
      : super(DashboardState(selectedDate: DateTime.now())) {
    on<DashboardLoadData>(_onLoad);
    on<DashboardPreviousDay>(_onPreviousDay);
    on<DashboardNextDay>(_onNextDay);
    on<DashboardDateChanged>(_onDateChanged);
  }

  Future<void> _onLoad(
    DashboardLoadData event,
    Emitter<DashboardState> emit,
  ) async {
    await _loadSummary(emit, state.selectedDate);
  }

  Future<void> _onPreviousDay(
    DashboardPreviousDay event,
    Emitter<DashboardState> emit,
  ) async {
    final newDate = DateTime(
      state.selectedDate.year,
      state.selectedDate.month,
      state.selectedDate.day - 1,
    );
    await _loadSummary(emit, newDate);
  }

  Future<void> _onNextDay(
    DashboardNextDay event,
    Emitter<DashboardState> emit,
  ) async {
    final newDate = DateTime(
      state.selectedDate.year,
      state.selectedDate.month,
      state.selectedDate.day + 1,
    );
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    if (newDate.isAfter(todayDate)) return;
    await _loadSummary(emit, newDate);
  }

  Future<void> _onDateChanged(
    DashboardDateChanged event,
    Emitter<DashboardState> emit,
  ) async {
    await _loadSummary(emit, event.date);
  }

  Future<void> _loadSummary(
    Emitter<DashboardState> emit,
    DateTime date,
  ) async {
    emit(DashboardState(selectedDate: date, isLoading: true));
    try {
      final summary = await _usecase.execute(date);
      emit(DashboardState(selectedDate: date, summary: summary));
    } catch (e) {
      emit(DashboardState(
        selectedDate: date,
        error: e.toString(),
      ));
    }
  }
}
