import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/send_reset_email_usecase.dart';

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
  late final SendResetEmailUsecase _usecase;

  ForgotPasswordBloc(this._usecase) : super(ForgotPasswordInitial()) {
    on<ForgotPasswordRequested>((event, emit) async {
      emit(ForgotPasswordLoading());
      try {
        await _usecase.execute(event.email);
        emit(ForgotPasswordSuccess());
      } catch (e) {
        emit(
          ForgotPasswordError('No se pudo enviar el correo. Intenta de nuevo.'),
        );
      }
    });
  }
}
