import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:medsync/di/service_locator.dart';
import '../../../../components/components.dart';
import '../bloc/caregiver_register_bloc.dart';
import '../pages/caregiver_register_page.dart';

class CaregiverRegisterScreen extends StatelessWidget {
  const CaregiverRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CaregiverRegisterBloc>(),
      child: const Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: CaregiverRegisterPage(),
          ),
        ),
      ),
    );
  }
}