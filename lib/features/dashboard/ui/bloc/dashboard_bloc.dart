import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardDateChanged extends DashboardEvent {
  final DateTime date;
  DashboardDateChanged(this.date);
}

class DashboardPreviousDay extends DashboardEvent {}

class DashboardNextDay extends DashboardEvent {}

abstract class DashboardEvent {}

class DashboardState {
  final DateTime selectedDate;
  DashboardState({required this.selectedDate});
}

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc()
      : super(DashboardState(selectedDate: DateTime.now())) {
    on<DashboardPreviousDay>((event, emit) {
      final newDate = DateTime(
        state.selectedDate.year,
        state.selectedDate.month,
        state.selectedDate.day - 1,
      );
      emit(DashboardState(selectedDate: newDate));
    });
    on<DashboardNextDay>((event, emit) {
      final newDate = DateTime(
        state.selectedDate.year,
        state.selectedDate.month,
        state.selectedDate.day + 1,
      );
      final today = DateTime.now();
      if (newDate.isAfter(today)) return;
      emit(DashboardState(selectedDate: newDate));
    });
    on<DashboardDateChanged>((event, emit) {
      emit(DashboardState(selectedDate: event.date));
    });
  }
}
