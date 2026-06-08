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
import 'package:medsync/features/auth/ui/bloc/logout_bloc.dart';
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

// ========================== Profile ==========================
// -------------------------- data --------------------------
import 'package:medsync/features/profile/data/repo/profile_repo_impl.dart';
import 'package:medsync/features/profile/data/sources/profile_data_source.dart';

// -------------------------- domain --------------------------
import 'package:medsync/features/profile/domain/repo/profile_repo.dart';
import 'package:medsync/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:medsync/features/profile/domain/usecases/link_patient_usecase.dart';
import 'package:medsync/features/profile/domain/usecases/refresh_linking_code_usecase.dart';

// -------------------------- bloc --------------------------
import 'package:medsync/features/profile/ui/bloc/link_patient_bloc.dart';
import 'package:medsync/features/profile/ui/bloc/profile_bloc.dart';

// ========================== Rutina ==========================
// -------------------------- data --------------------------
import 'package:medsync/features/rutina/data/repo/rutina_repo_impl.dart';
import 'package:medsync/features/rutina/data/sources/rutina_data_source.dart';

// -------------------------- domain --------------------------
import 'package:medsync/features/rutina/domain/repo/rutina_repo.dart';
import 'package:medsync/features/rutina/domain/usecases/get_daily_rutina_usecase.dart';
import 'package:medsync/features/rutina/domain/usecases/remind_later_usecase.dart';
import 'package:medsync/features/rutina/domain/usecases/update_intake_status_usecase.dart';
import 'package:medsync/features/rutina/domain/usecases/watch_today_rutina_usecase.dart';
import 'package:medsync/features/rutina/domain/services/in_app_notification_service.dart';
import 'package:medsync/features/rutina/domain/services/local_notification_service.dart';

// -------------------------- bloc --------------------------
import 'package:medsync/features/rutina/ui/bloc/rutina_bloc.dart';

// ========================== Treatment ==========================
// -------------------------- data --------------------------
import 'package:medsync/features/treatment/data/repo/treatment_repo_impl.dart';
import 'package:medsync/features/treatment/data/sources/treatment_data_source.dart';
// -------------------------- domain --------------------------
import 'package:medsync/features/treatment/domain/repo/treatment_repo.dart';
import 'package:medsync/features/treatment/domain/usecases/delete_treatment_usecase.dart';
import 'package:medsync/features/treatment/domain/usecases/get_treatment_summary_usecase.dart';
import 'package:medsync/features/treatment/domain/usecases/get_treatments_usecase.dart';
import 'package:medsync/features/treatment/domain/usecases/create_treatment_usecase.dart';
import 'package:medsync/features/treatment/domain/usecases/update_treatment_usecase.dart';
// -------------------------- bloc --------------------------
import 'package:medsync/features/treatment/ui/bloc/create_treatment_bloc.dart';
import 'package:medsync/features/treatment/ui/bloc/treatment_summary_bloc.dart';
import 'package:medsync/features/treatment/ui/bloc/treatments_list_bloc.dart';
import 'package:medsync/features/rutina/ui/bloc/notification_center_bloc.dart';

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
    sl.registerFactory<LogoutBloc>(() => LogoutBloc(sl(), sl(), sl()));
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

    // ========================== Profile ==========================
    sl.registerCachedFactory<ProfileRepo>(() => ProfileRepoImpl(sl()));
    sl.registerCachedFactory<ProfileDataSource>(() => ProfileDataSource());
    sl.registerCachedFactory(() => GetProfileUsecase(sl()));
    sl.registerCachedFactory(() => LinkPatientUsecase(sl()));
    sl.registerCachedFactory(() => RefreshLinkingCodeUsecase(sl()));
    sl.registerFactory<LinkPatientBloc>(() => LinkPatientBloc(sl()));
    sl.registerFactory<ProfileBloc>(() => ProfileBloc(sl(), sl()));

    // ========================== Rutina ==========================
    sl.registerLazySingleton<RutinaRepo>(() => RutinaRepoImpl(sl()));
    sl.registerLazySingleton<RutinaDataSource>(() => RutinaDataSource());
    sl.registerLazySingleton(() => GetDailyRutinaUsecase(sl()));
    sl.registerLazySingleton(() => UpdateIntakeStatusUsecase(sl()));
    sl.registerLazySingleton(() => RemindLaterUsecase(sl()));
    sl.registerLazySingleton(() => WatchTodayRutinaUsecase(sl()));
    sl.registerLazySingleton(() => LocalNotificationService(sl(), sl()));
    sl.registerLazySingleton(() => InAppNotificationService(sl(), sl()));
    sl.registerLazySingleton(() => NotificationCenterBloc(sl()));
    sl.registerFactory<RutinaBloc>(() => RutinaBloc(sl(), sl(), sl(), sl()));

    // ========================== Treatment ==========================
    sl.registerLazySingleton<TreatmentRepo>(() => TreatmentRepoImpl(sl()));
    sl.registerLazySingleton<TreatmentDataSource>(() => TreatmentDataSource());
    sl.registerLazySingleton(() => DeleteTreatmentUsecase(sl()));
    sl.registerLazySingleton(() => GetTreatmentSummaryUsecase(sl()));
    sl.registerLazySingleton(() => GetTreatmentsUsecase(sl()));
    sl.registerLazySingleton(() => UpdateTreatmentUsecase(sl()));
    sl.registerLazySingleton(() => CreateTreatmentUsecase(sl()));
    sl.registerFactory<CreateTreatmentBloc>(() => CreateTreatmentBloc(sl()));
    sl.registerFactory<TreatmentSummaryBloc>(() => TreatmentSummaryBloc(sl()));
    sl.registerFactory<TreatmentsListBloc>(() => TreatmentsListBloc(sl(), sl()));

}