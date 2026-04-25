import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/ui/screens/login_screen.dart';
import 'features/onboarding/ui/screens/onboarding_screen.dart';
import 'presentation/screens/components_preview_screen.dart';

const _supabaseUrl = 'https://artnzmzycsnixyzdlovq.supabase.co';
const _supabaseAnonKey = 'sb_publishable_ccmij37dGxUjZT3EvxWakw_GJW0CUv3';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);

  final prefs = await SharedPreferences.getInstance();
  if (kDebugMode) await prefs.remove('onboarding_done');
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;

  runApp(MedSyncApp(
    initialRoute: onboardingDone ? '/auth/login' : '/onboarding',
  ));
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
        '/auth/forgot-password': (_) => const Scaffold(
              body: Center(child: Text('Recuperar contraseña')),
            ),
        '/auth/role-selection': (_) => const Scaffold(
              body: Center(child: Text('Selección de rol')),
            ),
        '/rutina': (_) => const Scaffold(
              body: Center(child: Text('Mi Rutina')),
            ),
        '/configurar': (_) => const Scaffold(
              body: Center(child: Text('Configurar Tratamiento')),
            ),
        '/dev': (_) => const ComponentsPreviewScreen(),
      },
    );
  }
}
