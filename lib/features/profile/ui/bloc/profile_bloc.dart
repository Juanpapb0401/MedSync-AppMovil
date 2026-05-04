import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/model/profile_model.dart';
import '../../domain/usecases/get_profile_usecase.dart';

// Events
abstract class ProfileEvent {}

class LoadProfileEvent extends ProfileEvent {}

// States
abstract class ProfileState {}

class ProfileInitialState extends ProfileState {}

class ProfileLoadingState extends ProfileState {}

class ProfileLoadedState extends ProfileState {
  final ProfileModel profile;
  ProfileLoadedState(this.profile);
}

class ProfileErrorState extends ProfileState {
  final String message;
  ProfileErrorState(this.message);
}

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUsecase _usecase = GetProfileUsecase();

  ProfileBloc() : super(ProfileInitialState()) {
    on<LoadProfileEvent>((event, emit) async {
      emit(ProfileLoadingState());
      try {
        final profile = await _usecase.execute();
        emit(ProfileLoadedState(profile));
      } catch (_) {
        emit(ProfileErrorState('No se pudo cargar el perfil'));
      }
    });
  }
}
