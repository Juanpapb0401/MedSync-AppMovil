import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';

// Events
abstract class LoginEvent {}

class LoginSubmitEvent extends LoginEvent {
  final String email;
  final String password;
  LoginSubmitEvent({required this.email, required this.password});
}

// States
abstract class LoginState {}

class LoginInitialState extends LoginState {}

class LoginLoadingState extends LoginState {}

class LoginSuccessState extends LoginState {
  final String role;
  LoginSuccessState(this.role);
}

class LoginFailState extends LoginState {
  final String message;
  LoginFailState(this.message);
}

// BLoC
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUsecase _usecase = LoginUsecase();

  LoginBloc() : super(LoginInitialState()) {
    on<LoginSubmitEvent>((event, emit) async {
      emit(LoginLoadingState());
      try {
        final user = await _usecase.execute(event.email, event.password);
        emit(LoginSuccessState(user.role));
      } catch (e) {
        emit(LoginFailState(_friendlyError(e)));
      }
    });
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
