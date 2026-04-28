import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/forgot_password_repo.dart';

abstract class ForgotPasswordState {}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordSuccess extends ForgotPasswordState {}

class ForgotPasswordError extends ForgotPasswordState {
  final String message;
  ForgotPasswordError(this.message);
}

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final ForgotPasswordRepo _repo = ForgotPasswordRepo();

  ForgotPasswordCubit() : super(ForgotPasswordInitial());

  Future<void> sendResetEmail(String email) async {
    emit(ForgotPasswordLoading());
    try {
      await _repo.sendResetEmail(email);
      emit(ForgotPasswordSuccess());
    } catch (e) {
      emit(
        ForgotPasswordError('No se pudo enviar el correo. Intenta de nuevo.'),
      );
    }
  }
}
