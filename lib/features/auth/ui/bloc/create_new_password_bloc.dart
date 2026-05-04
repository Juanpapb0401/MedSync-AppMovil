import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/forgot_password_repo.dart';

// Events
abstract class CreateNewPasswordEvent {}

class CreateNewPasswordRequested extends CreateNewPasswordEvent {
  final String newPassword;

  CreateNewPasswordRequested(this.newPassword);
}

// States
abstract class CreateNewPasswordState {}

class CreateNewPasswordInitial extends CreateNewPasswordState {}

class CreateNewPasswordLoading extends CreateNewPasswordState {}

class CreateNewPasswordSuccess extends CreateNewPasswordState {}

class CreateNewPasswordError extends CreateNewPasswordState {
  final String message;

  CreateNewPasswordError(this.message);
}

// Bloc
class CreateNewPasswordBloc
    extends Bloc<CreateNewPasswordEvent, CreateNewPasswordState> {
  final ForgotPasswordRepo _repo = ForgotPasswordRepo();

  CreateNewPasswordBloc() : super(CreateNewPasswordInitial()) {
    on<CreateNewPasswordRequested>((event, emit) async {
      emit(CreateNewPasswordLoading());
      try {
        await _repo.updatePassword(event.newPassword);
        emit(CreateNewPasswordSuccess());
      } catch (e) {
        emit(CreateNewPasswordError('Error al actualizar la contraseña. Intenta de nuevo.'));
      }
    });
  }
}
