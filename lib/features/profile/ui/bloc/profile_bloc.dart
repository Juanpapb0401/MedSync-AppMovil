import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/model/profile_model.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/refresh_linking_code_usecase.dart';
import '../../data/repo/profile_repo_impl.dart';

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
  final GetProfileUsecase _getProfileUsecase = GetProfileUsecase();
  late final RefreshLinkingCodeUsecase _refreshLinkingCodeUsecase;

  ProfileBloc()
      : super(ProfileInitialState()) {
    _refreshLinkingCodeUsecase = RefreshLinkingCodeUsecase(ProfileRepoImpl());
    on<LoadProfileEvent>((event, emit) async {
      emit(ProfileLoadingState());
      try {
        await _refreshLinkingCodeUsecase.execute();
        final profile = await _getProfileUsecase.execute();
        emit(ProfileLoadedState(profile));
      } catch (_) {
        emit(ProfileErrorState('No se pudo cargar el perfil'));
      }
    });
  }
}
