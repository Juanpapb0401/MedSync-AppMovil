import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../components/app_colors.dart';

class ConfigurarScreen extends StatelessWidget {
  const ConfigurarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Configurar Tratamiento',
          style: GoogleFonts.poppins(
            fontSize: 16,
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
              Icons.tune,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Configurar Tratamiento',
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
      bottomNavigationBar: const _CaregiverNav(),
    );
  }
}

class _CaregiverNav extends StatelessWidget {
  const _CaregiverNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1C2E),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                icon: Icons.tune,
                label: 'Configurar',
                isActive: true,
                onTap: () {},
              ),
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: 'Dashboard',
                isActive: false,
                onTap: () {},
              ),
              _NavItem(
                icon: Icons.person,
                label: 'Perfil',
                isActive: false,
                onTap: () => Navigator.pushReplacementNamed(
                  context,
                  '/profile/caregiver',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : const Color(0xFF6A7282),
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.white : const Color(0xFF6A7282),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
