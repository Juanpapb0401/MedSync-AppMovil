import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String role;
  LoginSuccess(this.role);
}

class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}

class LoginCubit extends Cubit<LoginState> {
  final LoginUsecase _usecase = LoginUsecase();

  LoginCubit() : super(LoginInitial());

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    try {
      final user = await _usecase.execute(email, password);
      emit(LoginSuccess(user.role));
    } catch (e) {
      emit(LoginError(_friendlyError(e)));
    }
  }

  String _friendlyError(dynamic e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials')) {
      return 'Correo o contraseña incorrectos';
    }
    if (msg.contains('email not confirmed')) {
      return 'Confirma tu correo antes de iniciar sesión';
    }
    return 'Error al iniciar sesión. Inténtalo de nuevo';
  }
}
