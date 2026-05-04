import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../components/components.dart';

class PasswordUpdatedScreen extends StatelessWidget {
  const PasswordUpdatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'MedSync',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Contraseña actualizada',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Tu contraseña ha sido restablecida exitosamente. Ahora puedes iniciar sesión con tu nueva contraseña.',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                MedSyncButton(
                  label: 'Ir al inicio de sesión',
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/auth/login');
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}