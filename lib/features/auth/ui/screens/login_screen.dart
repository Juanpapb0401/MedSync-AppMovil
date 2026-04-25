import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../components/components.dart';
import '../cubit/login_cubit.dart';
import '../pages/login_page.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: const SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: LoginPage(),
          ),
        ),
      ),
    );
  }
}
