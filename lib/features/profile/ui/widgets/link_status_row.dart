import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../components/app_colors.dart';

class LinkStatusRow extends StatelessWidget {
  final String label;
  final bool hasLinked;
  final String linkedStatus;
  final VoidCallback? onTap;

  const LinkStatusRow({
    super.key,
    required this.label,
    required this.hasLinked,
    required this.linkedStatus,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final badgeText = hasLinked ? linkedStatus : 'Sin vincular';
    final badgeBg = hasLinked
        ? const Color(0xFFE7F9F5)
        : const Color(0xFFF3F4F6);
    final badgeTextColor = hasLinked
        ? AppColors.primary
        : const Color(0xFF6B7280);

    return Row(
      children: [
        const Icon(Icons.link, color: AppColors.primary, size: 18),
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
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: hasLinked ? null : onTap,
            borderRadius: BorderRadius.circular(50),
            child: Container(
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
          ),
        ),
      ],
    );
  }
}