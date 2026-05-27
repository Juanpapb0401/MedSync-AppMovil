import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/update_password_usecase.dart';

abstract class CreateNewPasswordEvent {}

class CreateNewPasswordRequested extends CreateNewPasswordEvent {
  final String newPassword;

  CreateNewPasswordRequested(this.newPassword);
}

abstract class CreateNewPasswordState {}

class CreateNewPasswordInitial extends CreateNewPasswordState {}

class CreateNewPasswordLoading extends CreateNewPasswordState {}

class CreateNewPasswordSuccess extends CreateNewPasswordState {}

class CreateNewPasswordError extends CreateNewPasswordState {
  final String message;

  CreateNewPasswordError(this.message);
}

class CreateNewPasswordBloc
    extends Bloc<CreateNewPasswordEvent, CreateNewPasswordState> {
  late final UpdatePasswordUsecase _usecase;

  CreateNewPasswordBloc(this._usecase) : super(CreateNewPasswordInitial()) {
    on<CreateNewPasswordRequested>((event, emit) async {
      emit(CreateNewPasswordLoading());
      try {
        await _usecase.execute(event.newPassword);
        emit(CreateNewPasswordSuccess());
      } catch (_) {
        emit(
          CreateNewPasswordError(
            'Error al actualizar la contraseña. Intenta de nuevo.',
          ),
        );
      }
    });
  }
}
