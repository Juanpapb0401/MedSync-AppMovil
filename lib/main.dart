import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/ui/screens/login_screen.dart';

import 'features/onboarding/ui/screens/onboarding_screen.dart';
import 'features/auth/ui/screens/forgot_password_screen.dart';
import 'features/auth/ui/screens/forgot_password_sent_screen.dart';
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
        '/auth/forgot-password': (_) => const ForgotPasswordScreen(),
        '/auth/forgot-password-sent': (_) => const ForgotPasswordSentScreen(),
        '/auth/role-selection': (_) =>
            const Scaffold(body: Center(child: Text('Selección de rol'))),
        '/rutina': (_) =>
            const Scaffold(body: Center(child: Text('Mi Rutina'))),
        '/configurar': (_) =>
            const Scaffold(body: Center(child: Text('Configurar Tratamiento'))),
        '/dev': (_) => const ComponentsPreviewScreen(),
      },
    );
  }
}
