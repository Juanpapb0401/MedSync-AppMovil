import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_linking_code_usecase.dart';

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
  late final GetLinkingCodeUsecase _usecase;

  CodeBindingBloc() 
      : super(CodeBindingInitialState()) {
    _usecase = GetLinkingCodeUsecase();
    on<LoadCodeBindingEvent>((event, emit) async {
      emit(CodeBindingLoadingState());
      try {
        final code = await _usecase.execute();
        emit(CodeBindingLoadedState(code));
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