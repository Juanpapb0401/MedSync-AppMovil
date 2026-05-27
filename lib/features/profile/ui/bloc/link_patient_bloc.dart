import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/link_patient_usecase.dart';

abstract class LinkPatientEvent {}

class SubmitLinkPatientEvent extends LinkPatientEvent {
  final String patientCode;

  SubmitLinkPatientEvent(this.patientCode);
}

abstract class LinkPatientState {}

class LinkPatientInitialState extends LinkPatientState {}

class LinkPatientLoadingState extends LinkPatientState {}

class LinkPatientSuccessState extends LinkPatientState {}

class LinkPatientFailState extends LinkPatientState {
  final String message;

  LinkPatientFailState(this.message);
}

class LinkPatientBloc extends Bloc<LinkPatientEvent, LinkPatientState> {
  final LinkPatientUsecase _usecase;

  LinkPatientBloc(this._usecase) : super(LinkPatientInitialState()) {
    on<SubmitLinkPatientEvent>((event, emit) async {
      emit(LinkPatientLoadingState());
      try {
        await _usecase.execute(event.patientCode);
        emit(LinkPatientSuccessState());
      } catch (e) {
        emit(LinkPatientFailState(_friendlyError(e)));
      }
    });
  }

  String _friendlyError(dynamic e) {
    final msg = e.toString().toLowerCase();

    if (msg.contains('no se pudo cargar el perfil del cuidador')) {
      return 'No se pudo cargar tu perfil. Inténtalo de nuevo';
    }
    if (msg.contains('solo los cuidadores pueden vincular pacientes')) {
      return 'Solo un cuidador puede vincular pacientes';
    }
    if (msg.contains('ingresa el código del paciente')) {
      return 'Ingresa el código del paciente';
    }
    if (msg.contains('código del paciente no existe')) {
      return 'El código del paciente no existe';
    }
    if (msg.contains('ya fue vinculado')) {
      return 'Este código ya fue vinculado a otro cuidador';
    }
    if (msg.contains('ya tienes un paciente vinculado')) {
      return 'Ya tienes un paciente vinculado';
    }
    return 'No se pudo vincular al paciente. Inténtalo de nuevo';
  }
}