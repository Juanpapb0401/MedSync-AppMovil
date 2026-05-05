import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/caregiver_register_usecase.dart';

abstract class CaregiverRegisterEvent {}

class CaregiverRegisterSubmitEvent extends CaregiverRegisterEvent {
  final String fullName;
  final String email;
  final String password;
  final Uint8List? avatarBytes;
  final String? avatarExt;
  final String? patientCode;

  CaregiverRegisterSubmitEvent({
    required this.fullName,
    required this.email,
    required this.password,
    this.avatarBytes,
    this.avatarExt,
    this.patientCode,
  });
}

abstract class CaregiverRegisterState {}

class CaregiverRegisterInitialState extends CaregiverRegisterState {}

class CaregiverRegisterLoadingState extends CaregiverRegisterState {}

class CaregiverRegisterSuccessState extends CaregiverRegisterState {}

class CaregiverRegisterFailState extends CaregiverRegisterState {
  final String message;
  CaregiverRegisterFailState(this.message);
}

class CaregiverRegisterBloc
    extends Bloc<CaregiverRegisterEvent, CaregiverRegisterState> {
  final CaregiverRegisterUsecase _usecase = CaregiverRegisterUsecase();

  CaregiverRegisterBloc() : super(CaregiverRegisterInitialState()) {
    on<CaregiverRegisterSubmitEvent>((event, emit) async {
      emit(CaregiverRegisterLoadingState());
      try {
        await _usecase.execute(
          event.fullName,
          event.email,
          event.password,
          avatarBytes: event.avatarBytes,
          avatarExt: event.avatarExt,
          patientCode: event.patientCode,
        );
        emit(CaregiverRegisterSuccessState());
      } catch (e) {
        emit(CaregiverRegisterFailState(_friendlyError(e)));
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
        msg.contains('correo ya está registrado') ||
        msg.contains('user already exists') ||
        msg.contains('already in use')) {
      return 'Este correo ya está registrado. Usa otro correo o inicia sesión.';
    }
    if (msg.contains('código del paciente no existe')) {
      return 'El código del paciente no existe';
    }
    if (msg.contains('ya fue vinculado')) {
      return 'Este código ya fue vinculado a otro cuidador';
    }
    if (msg.contains('no se pudo vincular')) {
      return 'No se pudo vincular al paciente. Inténtalo de nuevo';
    }
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials')) {
      return 'Correo o contraseña incorrectos';
    }
    if (msg.contains('invalid email')) {
      return 'Ingresa un correo electrónico válido.';
    }
    return 'No se pudo crear la cuenta. Inténtalo de nuevo';
  }
}