import 'package:get_it/get_it.dart';

// ========================== Auth ==========================
// -------------------------- data --------------------------
import 'package:medsync/features/auth/data/repo/auth_repo_impl.dart';
import 'package:medsync/features/auth/data/repo/forgot_password_repo_impl.dart';
import 'package:medsync/features/auth/data/repo/get_linking_code_repo_impl.dart';
import 'package:medsync/features/auth/data/repo/logout_repo_impl.dart';
import 'package:medsync/features/auth/data/sources/auth_data_source.dart';
import 'package:medsync/features/auth/data/sources/get_linking_code_data_source.dart';

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

// ========================== Dashboard ==========================

// ========================== Onboarding ==========================

// ========================== Profile ==========================

// ========================== Rutina ==========================

// ========================== Treatment ==========================

final sl = GetIt.instance;

Future<void> initDependencies() async {
    // ========================== Auth ==========================
    sl.registerLazySingleton<AuthRepo>(() => AuthRepoImpl());
    sl.registerLazySingleton<ForgotPasswordRepo>(() => ForgotPasswordRepoImpl());
    sl.registerLazySingleton<GetLinkingCodeRepo>(() => GetLinkingCodeRepoImpl());
    sl.registerLazySingleton<LogoutRepo>(() => LogoutRepoImpl());
    sl.registerLazySingleton<AuthDataSource>(() => AuthDataSource());
    sl.registerLazySingleton<GetLinkingCodeDataSource>(() => GetLinkingCodeDataSource());
    sl.registerLazySingleton(() => CaregiverRegisterUsecase());
    sl.registerLazySingleton(() => GetLinkingCodeUsecase(sl()));
    sl.registerLazySingleton(() => LoginUsecase());
    sl.registerLazySingleton(() => LogoutUsecase(sl()));
    sl.registerLazySingleton(() => PatientRegisterUsecase());
    sl.registerLazySingleton(() => SendResetEmailUsecase(sl()));
    sl.registerLazySingleton(() => UpdatePasswordUsecase(sl()));
    sl.registerLazySingleton(() => VerifyOtpUsecase(sl()));

}