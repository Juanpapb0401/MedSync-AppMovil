import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class MainNavBar extends StatelessWidget {
  final String userRole;
  final int activeIndex;

  const MainNavBar({
    super.key,
    required this.userRole,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    final items = userRole == 'cuidador'
        ? _caregiverItems
        : _patientItems;

    return Container(
      color: AppColors.navbarBackground,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: userRole == 'paciente' ? 80 : 35,
            vertical: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 0; i < items.length; i++)
                _NavItem(
                  icon: items[i].icon,
                  label: items[i].label,
                  isActive: i == activeIndex,
                  onTap: () => _navigateTo(context, items[i].route),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    if (route.isEmpty) return;
    Navigator.pushReplacementNamed(context, route);
  }

  static const _caregiverItems = [
    _NavBarItem(icon: Icons.tune, label: 'Configurar', route: '/tratamientos/home'),
    _NavBarItem(icon: Icons.grid_view_rounded, label: 'Dashboard', route: ''),
    _NavBarItem(icon: Icons.person, label: 'Perfil', route: '/profile/caregiver'),
  ];

  static const _patientItems = [
    _NavBarItem(icon: Icons.calendar_today_outlined, label: 'Mi Rutina', route: '/rutina'),
    _NavBarItem(icon: Icons.person, label: 'Perfil', route: '/profile/patient'),
  ];
}

class _NavBarItem {
  final IconData icon;
  final String label;
  final String route;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.route,
  });
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