import 'package:flutter/material.dart';
import '../../../../components/app_colors.dart';
import 'profile_card.dart';
import 'section_label.dart';
import 'status_row.dart';

class EstadoCard extends StatelessWidget {
  final bool hasLinked;
  final String linkedLabel;
  final String linkedStatus;
  final String statusType;

  const EstadoCard({
    super.key,
    required this.hasLinked,
    required this.linkedLabel,
    required this.linkedStatus,
    required this.statusType,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('ESTADO'),
          const SizedBox(height: 12),
          StatusRow(
            icon: Icons.check_circle_outline,
            label: 'Cuenta activa',
            badgeText: 'Activo',
            badgeBg: const Color(0xFFDCFCE7),
            badgeTextColor: const Color(0xFF16A34A),
          ),
          const SizedBox(height: 12),
          StatusRow(
            icon: Icons.link,
            label: linkedLabel,
            badgeText: hasLinked ? linkedStatus : 'Sin vincular',
            badgeBg: hasLinked
                ? const Color(0xFFE7F9F5)
                : const Color(0xFFF3F4F6),
            badgeTextColor: hasLinked
                ? AppColors.primary
                : const Color(0xFF6B7280),
          ),
        ],
      ),
    );
  }
}