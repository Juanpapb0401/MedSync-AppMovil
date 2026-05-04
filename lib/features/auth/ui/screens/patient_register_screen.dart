import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../components/components.dart';
import '../bloc/patient_register_bloc.dart';
import '../pages/patient_register_page.dart';

class PatientRegisterScreen extends StatelessWidget {
  const PatientRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PatientRegisterBloc(),
      child: const Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: PatientRegisterPage(),
          ),
        ),
      ),
    );
  }
}
