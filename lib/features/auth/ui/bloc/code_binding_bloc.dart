import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../profile/domain/usecases/get_profile_usecase.dart';

abstract class CodeBindingEvent {}

class LoadCodeBindingEvent extends CodeBindingEvent {}

abstract class CodeBindingState {}

class CodeBindingInitialState extends CodeBindingState {}

class CodeBindingLoadingState extends CodeBindingState {}

class CodeBindingLoadedState extends CodeBindingState {
  final String code;

  CodeBindingLoadedState(this.code);
}

class CodeBindingErrorState extends CodeBindingState {
  final String message;

  CodeBindingErrorState(this.message);
}

class CodeBindingBloc extends Bloc<CodeBindingEvent, CodeBindingState> {
  final GetProfileUsecase _usecase = GetProfileUsecase();

  CodeBindingBloc() : super(CodeBindingInitialState()) {
    on<LoadCodeBindingEvent>((event, emit) async {
      emit(CodeBindingLoadingState());
      try {
        final profile = await _usecase.execute();
        if (!profile.isPatient) {
          emit(
            CodeBindingErrorState(
              'No se pudo cargar la información del código de vinculación',
            ),
          );
          return;
        }

        emit(CodeBindingLoadedState(profile.linkingCode));
      } catch (_) {
        emit(
          CodeBindingErrorState(
            'No se pudo cargar la información del código de vinculación',
          ),
        );
      }
    });
  }
}