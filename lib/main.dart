import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/ui/screens/login_screen.dart';
import 'features/profile/ui/screens/caregiver_profile_screen.dart';
import 'features/profile/ui/screens/patient_profile_screen.dart';
import 'features/treatment/ui/screens/configurar_screen.dart';
import 'features/rutina/ui/screens/rutina_screen.dart';

import 'features/onboarding/ui/screens/onboarding_screen.dart';
import 'features/auth/ui/screens/forgot_password_screen.dart';
import 'features/auth/ui/screens/forgot_password_sent_screen.dart';
import 'features/auth/ui/screens/otp_verification_screen.dart';
import 'features/auth/ui/screens/create_new_password_screen.dart';
import 'features/auth/ui/screens/password_updated_screen.dart';
import 'features/auth/ui/screens/patient_register_screen.dart';
import 'features/auth/ui/screens/role_selection_screen.dart';
import 'presentation/screens/components_preview_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final prefs = await SharedPreferences.getInstance();
  if (kDebugMode) await prefs.remove('onboarding_done');
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;

  runApp(
    MedSyncApp(initialRoute: onboardingDone ? '/auth/login' : '/onboarding'),
  );
}

class MedSyncApp extends StatelessWidget {
  final String initialRoute;

  const MedSyncApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedSync',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/auth/login': (_) => const LoginScreen(),
        '/auth/register-patient': (_) => const PatientRegisterScreen(),
        '/auth/binding-code': (_) =>
            const Scaffold(body: Center(child: Text('Código de Vinculación'))),
        '/auth/forgot-password': (_) => const ForgotPasswordScreen(),
        '/auth/forgot-password-sent': (_) => const ForgotPasswordSentScreen(),
        '/auth/otp-verification': (_) => const OtpVerificationScreen(),
        '/auth/create-new-password': (_) => const CreateNewPasswordScreen(),
        '/auth/password-updated': (_) => const PasswordUpdatedScreen(),
        '/auth/role-selection': (_) => const RoleSelectionScreen(),
        '/rutina': (_) => const RutinaScreen(),
        '/configurar': (_) => const ConfigurarScreen(),
        '/profile/caregiver': (_) => const CaregiverProfileScreen(),
        '/profile/patient': (_) => const PatientProfileScreen(),
        '/dev': (_) => const ComponentsPreviewScreen(),
      },
    );
  }
}
