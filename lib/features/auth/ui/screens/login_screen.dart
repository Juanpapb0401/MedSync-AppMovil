import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:medsync/di/service_locator.dart'; 
import '../../../../components/components.dart';
import '../bloc/login_bloc.dart';
import '../pages/login_page.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LoginBloc>(),
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccessState) {
            final route = state.role == 'paciente'
                ? '/profile/patient'
                : '/profile/caregiver';
            Navigator.pushReplacementNamed(context, route);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: const SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: LoginPage(),
            ),
          ),
        ),
      ),
    );
  }
}
