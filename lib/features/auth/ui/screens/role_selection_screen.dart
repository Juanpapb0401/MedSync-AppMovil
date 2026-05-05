import 'package:flutter/material.dart';

import '../../../../components/components.dart';
import '../pages/role_selection_page.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: RoleSelectionPage(),
        ),
      ),
    );
  }
}