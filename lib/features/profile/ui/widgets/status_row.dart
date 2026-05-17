import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../components/app_colors.dart';

class StatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String badgeText;
  final Color badgeBg;
  final Color badgeTextColor;

  const StatusRow({
    super.key,
    required this.icon,
    required this.label,
    required this.badgeText,
    required this.badgeBg,
    required this.badgeTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF364153),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            badgeText,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: badgeTextColor,
            ),
          ),
        ),
      ],
    );
  }
}