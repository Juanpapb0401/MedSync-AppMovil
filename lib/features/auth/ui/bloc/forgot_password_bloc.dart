import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/forgot_password_repo.dart';

// Events
abstract class ForgotPasswordEvent {}

class ForgotPasswordRequested extends ForgotPasswordEvent {
  final String email;
  ForgotPasswordRequested(this.email);
}

// States
abstract class ForgotPasswordState {}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordSuccess extends ForgotPasswordState {}

class ForgotPasswordError extends ForgotPasswordState {
  final String message;
  ForgotPasswordError(this.message);
}

// Bloc
class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final ForgotPasswordRepo _repo = ForgotPasswordRepo();

  ForgotPasswordBloc() : super(ForgotPasswordInitial()) {
    on<ForgotPasswordRequested>((event, emit) async {
      emit(ForgotPasswordLoading());
      try {
        await _repo.sendResetEmail(event.email);
        emit(ForgotPasswordSuccess());
      } catch (e) {
        print('DEBUG: Error enviando correo de recuperación: $e');
        emit(
          ForgotPasswordError('No se pudo enviar el correo. Intenta de nuevo.'),
        );
      }
    });
  }
}
