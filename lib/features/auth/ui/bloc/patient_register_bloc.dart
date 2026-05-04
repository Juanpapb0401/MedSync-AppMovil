import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/patient_register_usecase.dart';

// Events
abstract class PatientRegisterEvent {}

class PatientRegisterSubmitEvent extends PatientRegisterEvent {
  final String fullName;
  final String email;
  final String password;
  final Uint8List? avatarBytes;
  final String? avatarExt;

  PatientRegisterSubmitEvent({
    required this.fullName,
    required this.email,
    required this.password,
    this.avatarBytes,
    this.avatarExt,
  });
}

// States
abstract class PatientRegisterState {}

class PatientRegisterInitialState extends PatientRegisterState {}

class PatientRegisterLoadingState extends PatientRegisterState {}

class PatientRegisterSuccessState extends PatientRegisterState {}

class PatientRegisterFailState extends PatientRegisterState {
  final String message;
  PatientRegisterFailState(this.message);
}

// BLoC
class PatientRegisterBloc
    extends Bloc<PatientRegisterEvent, PatientRegisterState> {
  final PatientRegisterUsecase _usecase = PatientRegisterUsecase();

  PatientRegisterBloc() : super(PatientRegisterInitialState()) {
    on<PatientRegisterSubmitEvent>((event, emit) async {
      emit(PatientRegisterLoadingState());
      try {
        await _usecase.execute(
          event.fullName,
          event.email,
          event.password,
          avatarBytes: event.avatarBytes,
          avatarExt: event.avatarExt,
        );
        emit(PatientRegisterSuccessState());
      } catch (e) {
        emit(PatientRegisterFailState(_friendlyError(e)));
      }
    });
  }

  String _friendlyError(dynamic e) {
    return e.toString();
  }
}
