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
    final msg = e.toString().toLowerCase();
    if (msg.contains('over_email_send_rate_limit') ||
        msg.contains('rate limit exceeded') ||
        msg.contains('email rate limit') ||
        msg.contains('429')) {
      return 'Has solicitado demasiados correos para este email. Espera unos minutos o usa otro correo.';
    }
    if (msg.contains('email already') ||
        msg.contains('already registered') ||
        msg.contains('user already exists') ||
        msg.contains('already in use')) {
      return 'Este correo ya está registrado. Inicia sesión o usa otro correo.';
    }
    if (msg.contains('invalid email')) {
      return 'Ingresa un correo electrónico válido.';
    }
    return 'No se pudo crear la cuenta. Inténtalo de nuevo';
  }
}
