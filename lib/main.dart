import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:medsync/di/dependency_container.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/ui/screens/login_screen.dart';
import 'features/auth/ui/screens/code_binding_screen.dart';
import 'features/auth/ui/screens/caregiver_register_screen.dart';
import 'features/profile/ui/screens/caregiver_profile_screen.dart';
import 'features/profile/ui/screens/patient_profile_screen.dart';
import 'features/treatment/ui/screens/treatment_home_screen.dart';
import 'features/treatment/ui/screens/treatments_list_screen.dart';
import 'features/treatment/ui/screens/create_treatment_screen.dart';
import 'features/rutina/ui/screens/rutina_screen.dart';
import 'features/rutina/ui/screens/confirmar_toma_screen.dart';
import 'features/rutina/domain/model/rutina_medicamento_model.dart';
import 'features/dashboard/ui/screens/dashboard_screen.dart';

import 'features/onboarding/ui/screens/onboarding_screen.dart';
import 'features/auth/ui/screens/forgot_password_screen.dart';
import 'features/auth/ui/screens/forgot_password_sent_screen.dart';
import 'features/auth/ui/screens/otp_verification_screen.dart';
import 'features/auth/ui/screens/create_new_password_screen.dart';
import 'features/auth/ui/screens/password_updated_screen.dart';
import 'features/auth/ui/screens/patient_register_screen.dart';
import 'features/auth/ui/screens/role_selection_screen.dart';
import 'features/treatment/domain/model/treatment_model.dart';
import 'features/treatment/ui/screens/edit_treatment_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/screens/components_preview_screen.dart';
import 'package:medsync/features/rutina/domain/services/in_app_notification_service.dart';
import 'package:medsync/features/rutina/domain/services/local_notification_service.dart';
import 'package:medsync/features/rutina/ui/bloc/notification_center_cubit.dart';
import 'package:medsync/di/service_locator.dart';
import 'components/global_notification_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize dependencies before running the app (dependency injection setup)
  await initDependencies();

  // Initialize OS notification service (must happen before runApp so that
  // notification taps while the app is closed are handled correctly)
  await sl<LocalNotificationService>().init(navigatorKey);
  sl<LocalNotificationService>().start(sl());
  sl<InAppNotificationService>().start();

  final prefs = await SharedPreferences.getInstance();
  if (kDebugMode) await prefs.remove('onboarding_done');
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;

  runApp(
    MedSyncApp(initialRoute: onboardingDone ? '/auth/login' : '/onboarding'),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MedSyncApp extends StatelessWidget {
  final String initialRoute;

  const MedSyncApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationCenterCubit>(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        builder: (context, child) => GlobalNotificationWrapper(
          navigatorKey: navigatorKey,
          child: child!,
        ),
        title: 'MedSync',
        debugShowCheckedModeBanner: false,
        initialRoute: initialRoute,
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/auth/login': (_) => const LoginScreen(),
        '/auth/register-patient': (_) => const PatientRegisterScreen(),
        '/auth/register-caregiver': (_) => const CaregiverRegisterScreen(),
        '/auth/binding-code': (_) => const CodeBindingScreen(),
        '/auth/forgot-password': (_) => const ForgotPasswordScreen(),
        '/auth/forgot-password-sent': (_) => const ForgotPasswordSentScreen(),
        '/auth/otp-verification': (_) => const OtpVerificationScreen(),
        '/auth/create-new-password': (_) => const CreateNewPasswordScreen(),
        '/auth/password-updated': (_) => const PasswordUpdatedScreen(),
        '/auth/role-selection': (_) => const RoleSelectionScreen(),
        '/code': (_) => const CodeBindingScreen(),
        '/rutina': (_) => const RutinaScreen(),
        '/rutina/confirmar-toma': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map<String, dynamic>) {
            final medicamento = args['medicamento'] as RutinaMedicamentoModel?;
            final currentDate = args['currentDate'] as DateTime?;
            if (medicamento != null && currentDate != null) {
              return ConfirmarTomaScreen(
                medicamento: medicamento,
                currentDate: currentDate,
              );
            }
          }
          return const RutinaScreen();
        },
        '/configurar': (_) => const TreatmentHomeScreen(),
        '/tratamientos/home': (_) => const TreatmentHomeScreen(),
        '/tratamientos/lista': (_) => const TreatmentsListScreen(),
        '/tratamientos/crear': (_) => const CreateTreatmentScreen(),
        '/tratamientos/editar': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;

          if (args is Map<String, dynamic>) {
            final treatmentId = args['treatmentId'] as String?;
            final treatment = args['treatment'];
            final patientName = args['patientName'] as String?;

            if (treatmentId != null && treatment is TreatmentModel && patientName != null) {
              return EditTreatmentScreen(
                treatmentId: treatmentId,
                initialTreatment: treatment,
                patientName: patientName,
              );
            }
          }

          return const EditTreatmentScreen(
            treatmentId: 'demo-treatment-id',
            initialTreatment: TreatmentModel(
              medicineName: 'Metformina',
              dose: '850',
              unit: 'mg',
              frequency: 'Cada 8h',
              startTime: '08:00 AM',
              restrictions: ['Evitar lácteos', 'No alcohol'],
            ),
            patientName: 'María',
          );
        },
        '/dashboard': (_) => const DashboardScreen(),
        '/profile/caregiver': (_) => const CaregiverProfileScreen(),
        '/profile/patient': (_) => const PatientProfileScreen(),
        '/dev': (_) => const ComponentsPreviewScreen(),
      },
    ),
    );
  }
}
