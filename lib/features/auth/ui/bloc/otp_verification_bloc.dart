import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/forgot_password_repo.dart';

// Events
abstract class OtpVerificationEvent {}

class OtpVerificationRequested extends OtpVerificationEvent {
  final String email;
  final String token;

  OtpVerificationRequested(this.email, this.token);
}

// States
abstract class OtpVerificationState {}

class OtpVerificationInitial extends OtpVerificationState {}

class OtpVerificationLoading extends OtpVerificationState {}

class OtpVerificationSuccess extends OtpVerificationState {}

class OtpVerificationError extends OtpVerificationState {
  final String message;

  OtpVerificationError(this.message);
}

// Bloc
class OtpVerificationBloc
    extends Bloc<OtpVerificationEvent, OtpVerificationState> {
  final ForgotPasswordRepo _repo = ForgotPasswordRepo();

  OtpVerificationBloc() : super(OtpVerificationInitial()) {
    on<OtpVerificationRequested>((event, emit) async {
      emit(OtpVerificationLoading());
      try {
        await _repo.verifyOTP(event.email, event.token);
        emit(OtpVerificationSuccess());
      } catch (e) {
        emit(
          OtpVerificationError(
            'Código incorrecto o expirado. Intenta de nuevo.',
          ),
        );
      }
    });
  }
}
