import 'package:flutter/material.dart';
import '../../../../components/components.dart';
import '../pages/onboarding_content.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const SafeArea(child: OnboardingContent()),
    );
  }
}
