import 'package:medsync/di/service_locator.dart';

// ========================== Auth ==========================
// -------------------------- data --------------------------
import 'package:medsync/features/auth/data/repo/auth_repo_impl.dart';
import 'package:medsync/features/auth/data/repo/forgot_password_repo_impl.dart';
import 'package:medsync/features/auth/data/repo/get_linking_code_repo_impl.dart';
import 'package:medsync/features/auth/data/repo/logout_repo_impl.dart';
import 'package:medsync/features/auth/data/sources/auth_data_source.dart';
import 'package:medsync/features/auth/data/sources/forgot_password_data_source.dart';
import 'package:medsync/features/auth/data/sources/get_linking_code_data_source.dart';
import 'package:medsync/features/auth/data/sources/logout_data_source.dart';

// -------------------------- domain --------------------------
import 'package:medsync/features/auth/domain/repo/auth_repo.dart';
import 'package:medsync/features/auth/domain/repo/forgot_password_repo.dart';
import 'package:medsync/features/auth/domain/repo/get_linking_code_repo.dart';
import 'package:medsync/features/auth/domain/repo/logout_repo.dart';
import 'package:medsync/features/auth/domain/usecases/caregiver_register_usecase.dart';
import 'package:medsync/features/auth/domain/usecases/get_linking_code_usecase.dart';
import 'package:medsync/features/auth/domain/usecases/login_usecase.dart';
import 'package:medsync/features/auth/domain/usecases/logout_usecase.dart';
import 'package:medsync/features/auth/domain/usecases/patient_register_usecase.dart';
import 'package:medsync/features/auth/domain/usecases/send_reset_email_usecase.dart';
import 'package:medsync/features/auth/domain/usecases/update_password_usecase.dart';
import 'package:medsync/features/auth/domain/usecases/verify_otp_usecase.dart';

// -------------------------- bloc --------------------------
import 'package:medsync/features/auth/ui/bloc/caregiver_register_bloc.dart';
import 'package:medsync/features/auth/ui/bloc/code_binding_bloc.dart';
import 'package:medsync/features/auth/ui/bloc/create_new_password_bloc.dart';
import 'package:medsync/features/auth/ui/bloc/forgot_password_bloc.dart';
import 'package:medsync/features/auth/ui/bloc/login_bloc.dart';
import 'package:medsync/features/auth/ui/bloc/otp_verification_bloc.dart';
import 'package:medsync/features/auth/ui/bloc/patient_register_bloc.dart';

// ========================== Dashboard ==========================
// -------------------------- data --------------------------
import 'package:medsync/features/dashboard/data/repo/dashboard_repo_impl.dart';
import 'package:medsync/features/dashboard/data/sources/dashboard_data_source.dart';

// -------------------------- domain --------------------------
import 'package:medsync/features/dashboard/domain/repo/dashboard_repo.dart';
import 'package:medsync/features/dashboard/domain/usecases/get_daily_summary_usecase.dart';

// -------------------------- bloc --------------------------
import 'package:medsync/features/dashboard/ui/bloc/dashboard_bloc.dart';

// ========================== Onboarding ==========================

// ========================== Profile ==========================

// ========================== Rutina ==========================

// ========================== Treatment ==========================

Future<void> initDependencies() async {
    // ========================== Auth ==========================
    sl.registerLazySingleton<AuthRepo>(() => AuthRepoImpl(sl()));
    sl.registerLazySingleton<ForgotPasswordRepo>(() => ForgotPasswordRepoImpl(sl()));
    sl.registerLazySingleton<GetLinkingCodeRepo>(() => GetLinkingCodeRepoImpl(sl()));
    sl.registerLazySingleton<LogoutRepo>(() => LogoutRepoImpl(sl()));
    sl.registerLazySingleton<AuthDataSource>(() => AuthDataSource());
    sl.registerLazySingleton<ForgotPasswordDataSource>(() => ForgotPasswordDataSource());
    sl.registerLazySingleton<GetLinkingCodeDataSource>(() => GetLinkingCodeDataSource());
    sl.registerLazySingleton<LogoutDataSource>(() => LogoutDataSource());
    sl.registerLazySingleton(() => CaregiverRegisterUsecase(sl()));
    sl.registerLazySingleton(() => GetLinkingCodeUsecase(sl()));
    sl.registerLazySingleton(() => LoginUsecase(sl()));
    sl.registerLazySingleton(() => LogoutUsecase(sl()));
    sl.registerLazySingleton(() => PatientRegisterUsecase(sl()));
    sl.registerLazySingleton(() => SendResetEmailUsecase(sl()));
    sl.registerLazySingleton(() => UpdatePasswordUsecase(sl()));
    sl.registerLazySingleton(() => VerifyOtpUsecase(sl()));
    sl.registerFactory<CaregiverRegisterBloc>(() => CaregiverRegisterBloc(sl()));
    sl.registerFactory<CodeBindingBloc>(() => CodeBindingBloc(sl()));
    sl.registerFactory<CreateNewPasswordBloc>(() => CreateNewPasswordBloc(sl()));
    sl.registerFactory<ForgotPasswordBloc>(() => ForgotPasswordBloc(sl()));
    sl.registerFactory<LoginBloc>(() => LoginBloc(sl()));
    sl.registerFactory<OtpVerificationBloc>(() => OtpVerificationBloc(sl()));
    sl.registerFactory<PatientRegisterBloc>(() => PatientRegisterBloc(sl()));

    // ========================== Dashboard ==========================
    sl.registerLazySingleton<DashboardRepo>(() => DashboardRepoImpl(sl()));
    sl.registerLazySingleton<DashboardDataSource>(() => DashboardDataSource());
    sl.registerLazySingleton(() => GetDailySummaryUsecase(sl()));
    sl.registerFactory<DashboardBloc>(() => DashboardBloc(sl()));

}