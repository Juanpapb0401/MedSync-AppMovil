import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../components/app_colors.dart';
import '../../../../components/main_nav_bar.dart';

class TreatmentsListPlaceholderScreen extends StatelessWidget {
  const TreatmentsListPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ver Tratamientos',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.medication_outlined,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Ver Tratamientos',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Próximamente',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainNavBar(
        userRole: 'cuidador',
        activeIndex: 0,
      ),
    );
  }
}